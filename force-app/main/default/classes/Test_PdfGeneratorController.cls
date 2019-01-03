/*
Written by: Katharine Anderson
Last updated: 12-27-2018
Purpose: Test class to test the insertion of the pdf version of the monitoring report and the upload of that 
attachment to Box. Still need to figure out how to assert that the upload to Box worked...
*/
@isTest
private class Test_PdfGeneratorController {
    static testMethod void testPdfGenerator2() {
        
        //test insert annual inspection records
        List<Annual_Inspection__c> aiList = TestDataFactory.createAnnualInspections(10,10,1);
        
        system.Test.startTest();

        //Loop through annual inspections and add unique ids to list
        Set<ID> setAIIDs = new Set<ID>();
        List<ID> AIIds = new List<ID>();
        for(Annual_Inspection__c AI : aiList){
            setAIIDs.add(AI.id);
        }
        AIIDs.addAll(setAIIDs);
        
        // Because the savePdf() method is a webservices method, we have to use test.setmock to do a mock callout to the webservice
        Test.SetMock(WebServiceMock.class, new WebServiceMockImpl() );
        
        // test method that adds the attachments
        PdfGeneratorController2.getAIIDs(AIIDs);
        System.Test.stopTest(); 
        
        //assert that the attachment insert worked as expected
        System.assert([select count() from attachment] > 0);
    }
}