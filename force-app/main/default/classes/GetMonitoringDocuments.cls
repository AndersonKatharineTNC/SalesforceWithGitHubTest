/*
Written By: Katharine Anderson
Last Updated: 2018-12-18
Purpose: For Easement Monitoring - Requirement was to have a list of monitoring documents display on the pdf version of the monitoring report. This
Code allows us to pull the list of monitoring documents from Box that were uploaded since the annual inspection/monitoring record was created. 
We then put that list into the Monitoring Documents text field on the annual inspection/monitoring record, which allows the monitor to make any necessary
changes (i.e. removing documents from the list that don't need to be included in the PDF version of the monitoring report.) This field is then pulled into
the PDF version of the monitoring report.

Note: The monitor has to manually check the 'Update Monitoring Documentation' checkbox field on the record to initiate the process that calls this code.
*/


public with sharing class GetMonitoringDocuments {
    
    public static void refreshField (List<ID> ids){
        List<Annual_Inspection__c> AIlist = [SELECT ID, Monitoring_Documentation__c, Update_Monitoring_Documentation__c
                                             FROM Annual_Inspection__c 
                                             WHERE ID =: ids];
        for(Annual_Inspection__c ai : AIlist){
            AI.Update_Monitoring_Documentation__c = False;
            AI.Monitoring_Documentation__c = 'It can take up to a minute for this field to update. Please refresh the page to see the updated list.';          
        }
        update AIlist;
    }
    
    //future necessary because it's an http callout to Box using Named Credentials
    @future (callout=true)
    public static void getFolderItems(List<ID> ids){
        List<Annual_Inspection__c> AIlist = [SELECT id, property_interest__c, Property_Interest__r.MDFolderId__c,Monitoring_Documentation__c, Update_Monitoring_Documentation__c, CreatedDate
                                             FROM Annual_Inspection__c
                                             WHERE Id in :ids];
        for(Annual_Inspection__c ai : AIlist){
            string folderid = ai.Property_Interest__r.MDFolderId__c;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('callout:BoxForSalesforce/folders/' + folderId + '/items?fields=name,created_at,created_by,shared_link');
            HttpResponse response = http.send(req);
            system.debug('***HttpResponse=>' + response);
            system.debug('***HttpResponseBody=>' + response.getBody());
            
            if(response.getStatusCode() == 200){
                // Update the monitoring documentation field with the Parsed JSON
                string jsonString = response.getBody();
                BoxFolderItemsJSON2Apex myClass = BoxFolderItemsJSON2Apex.parse(jsonString);
                String parsedJsonList = '';
                
                // Deserialize the list of folder items from the JSON string.
                integer i = 1;
                for(BoxFolderItemsJSON2Apex.Entries entries: myClass.entries) {
                    string date_uploaded = entries.created_at_Z.substring(0,10);
                    date created_date = date.valueOf(date_uploaded);
                    if(created_date >= AI.CreatedDate){
                        parsedJsonList+=i+'. ';
                        parsedJsonList+=entries.name;
                        parsedJsonList+='\n';
                        parsedJsonList+='Uploaded by: ';
                        parsedJsonList+=entries.created_by_Z.name;
                        parsedJsonList+='\n';
                        parsedJsonList+='Date uploaded: ';
                        parsedJsonList+=date_uploaded;
                        parsedJsonList+='\n';
                        parsedJsonList+='\n';
                        i++;
                    }
                }
                    ai.Monitoring_Documentation__c = parsedJsonList;
                    system.debug('***Parsed Json List: '+parsedJsonList);
                    //Example of the output on the field:
                    //1. MD_Kern River Preserve preliminary monitoring report 2016.docx, Uploaded by: Tester Katharine Anderson, Date uploaded: 2017-09-27
                    //2. MD_Kern River Preserve site visit 28 August 2015.docx, Uploaded by: Tester Katharine Anderson, Date uploaded: 2017-09-27
                    //3. Posting Authorship pre-2018.csv, Uploaded by: Tester Katharine Anderson, Date uploaded: 2017-09-27
                    //4. Upload.csv, Uploaded by: Tester Katharine Anderson, Date uploaded: 2018-04-04
            } else {
                system.debug('***Response Status code: '+response.getStatusCode());
                ai.Monitoring_Documentation__c = ('Please contact your Salesforce adminstrator, there has been an issue pulling the list of monitoring documents from Box. Box Callout Response Status Code: '+ response.getStatusCode()); 
            }            
        }
        //Commit the changes.
        update AIlist;
    }
    
    //Make it an invocable method so that it can be called by process builder. The code is then run when a checkbox is checked on the record.
    @InvocableMethod(label='Get Folder Items' description='Returns the list of folder items.')
    public static void getAIIDs(List<ID> ids) {
        GetMonitoringDocuments.refreshField(ids);
        GetMonitoringDocuments.getFolderItems(ids);
    } 
}