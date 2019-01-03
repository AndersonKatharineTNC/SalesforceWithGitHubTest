/*
ConvertToBoxFile no longer in use: replaced by Process Builder/PDFGeneratorController2.apxc.
*/

//Test class that inserts an attachment to an Annual Inspection record

@isTest
public class ConvertToBoxFileTest {
	static testMethod void testMyController() {
        PageReference pageRef = new PageReference('/apex/MonitoringReportPDF?Id=');
        Test.setCurrentPage(pageRef);
        
        // Create new instance of an Annual Inspection        
        Annual_Inspection__c AI = new Annual_Inspection__c(Status__c = 'Draft', RecordTypeID = '012a0000001CH0F');
        insert AI;
        
        // Adds the id of the inserted project to the page
        ApexPages.currentPage().getParameters().put('Id', AI.Id);
        
        // Create attachment
        Attachment attach = new Attachment();
        
        // Set test fields for attachment
        attach.description = 'Test Description';
        attach.Name = 'TestName.txt';
        attach.Body = Blob.valueOf(' ');
        attach.ParentId = AI.Id;
        
        insert attach;
       
    }
}