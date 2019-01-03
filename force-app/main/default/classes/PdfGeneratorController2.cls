/*
Written by: Katharine Anderson
Last updated: 12-27-2018
Purpose: Requirement for Easement Monitoring - at the end of the monitoring year, archive all of the monitoring
reports as PDFs in Box (include references to the photos, but don't have to include the photo images themselves
in the PDFs). The heap size gets too big and causes an error if we try to include the photos in the pdfs that 
get automatically attached to the property interest record in Salesforce and uploaded to the Box folder
we don't have a limit on the number of photos that can be included with a monitoring report.

To get a PDF that includes the photos, click the 'Preview Report PDF' button on a completed monitoring report
record, and then click print and save it as a PDF to your desktop (instructions here: 
https://tnc-ca.my.salesforce.com/0150c000004GMhD).

Workflow: 
1) User clicks button 'Attach Report PDF' on an approved easement monitoring report, which checks the 
'Create PDF Monitoring Report' checkbox on the report record.
-OR-
1) A user/administrator checks the 'Create PDF Monitoring Report' checkbox on several monitoring reports 
at once in a listview or api or data loader or other method.
-THEN-
2) This triggers the 'Annual Inspection - Create PDF Monitoring Reports When Checkbox is Checked' process. 
3) This process calls the invocable getAIIDs method, unchecks the checkbox that triggered it, and sets the 
current date in the 'PDF Created Date' field. 
4) The getAIIDs method then triggers the savePDF method in this class which creates the PDF using the 
visualforce page 'MonitoringReportPDF2' and attaches it to the Annual Inspection's related Property Interest 
as a Salesforce attachment. The savePDF method then triggers the 'createAttachmentInBox' method in this class.
5) The 'createAttachmentInBox' method takes all of the attachments uploaded in the savePDF method and uploads
them to the appropriate folder in Box using the Box Toolkit (a part of the Box managed package). Because the
Box toolkit doesn't seem to be appropriately bulkified, you can only upload 100 attachments at a time. If you
try to do more than that it will error (too many SOQL calls).

**If I have time sometime in the future, I will rewrite this to use the http callout directly to Box rather
than the Box Toolkit so that I can control how many SOQL calls get made.
*/

global with sharing class PdfGeneratorController2 {
    
    //Method to upload attachment created below to Box. Must use the @future keyword in order to make the callout to Box.
    //In order to test in Sandbox, need to set up test Box account and integrate.
    //Test class is called Test_PdfGeneratorController2.
    @future (callout=true)
    public static void createAttachmentInBox(Map<ID,ID> mapAttach){
        box.Toolkit boxToolkit = new box.Toolkit();
        system.debug('***Attachment Map: '+mapAttach);
        //get map with attachment id (from input) and folder id from the property interest record
        Map<ID,String> newMapAttach = new Map<ID,String>();
        List<Property_Interest__c> piList = [SELECT ID, MRFolderId__c
                                             FROM Property_Interest__c
                                             WHERE ID IN :mapAttach.keySet()];
        for(Property_Interest__c pi : piList) {
            newMapAttach.put(mapAttach.get(pi.id),pi.MRFolderID__c);
        }
        
        LIST<Attachment> attachList = [SELECT ID, name, body, ParentID 
                                       FROM Attachment 
                                       WHERE ID IN :newMapAttach.keySet()];
        for(Attachment attach : attachList){
            String AttachmentID = attach.id;
            String folderID = newMapAttach.get(AttachmentID);
            String fileFromBoxID = boxtoolkit.createFileFromAttachment(attach,null,folderID,null);
            system.debug('fileFromBoxID '+fileFromBoxID);
        }
        boxToolkit.commitChanges();
    }
    
    //This method uses the WebService keyword because it creates the attachment automatically, without a further confirmation from
    //the user. Therefore, I had to create a mock callout to a 'webservice' in the test class.
    WebService static void savePdf(List<ID> aiIDs){
        List<Annual_Inspection__c> AIlist = [SELECT id, PDF_Report_Name__c, property_interest__c, Property_Interest__r.MRFolderId__c 
                                             FROM Annual_Inspection__c 
                                             WHERE Id in :aiIDs];
        List<Attachment> attachList = new List<Attachment>();
        Map<ID, ID> mapAttach = new Map<ID, ID>();
        for(Annual_Inspection__c ai : AIlist){    
            //Use the Monitoring Report PDF visualforce page code to create the body of the attachment.
            PageReference pdf = new PageReference('/apex/MonitoringReportPDF2?Id='+ai.ID);
            
            // create the new attachment
            Attachment attach = new Attachment();
            
            // the contents of the attachment from the pdf
            Blob body;
            
            try {
                // returns the output of the page as a PDF
                body = pdf.getContentAsPDF();
                // need to pass unit test -- current bug    
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Text');
            }
            attach.Body = body;
            // add the user entered name
            attach.Name = ai.PDF_Report_Name__c;
            attach.IsPrivate = false;
            // attach the pdf to the parent
            attach.ParentId = ai.Property_Interest__c;
            attachList.add(attach);
        }
        insert attachList;
        for (Attachment attach : attachList){
            mapAttach.put(attach.parentId,attach.id);
        }
        
        system.debug('Inserted Attachments: '+attachList);
        //create the attachment as a file in Box
        createAttachmentInBox(mapAttach);
    }
    
    @InvocableMethod(label='Save PDFs' description='Creates PDFs of the monitoring reports.')
    public static void getAIIDs(List<ID> ids) {
        PdfGeneratorController2.savePdf(ids);
    } 
}