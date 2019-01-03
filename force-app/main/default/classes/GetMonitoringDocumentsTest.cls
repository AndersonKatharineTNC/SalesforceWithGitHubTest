/*
Written By: Katharine Anderson
Last Updated: 2018-12-18
Purpose: Test 'GetMonitoringDocuments' apex class. For Easement Monitoring - Requirement was to have a list of monitoring documents display on the pdf 
version of the monitoring report. The apex class allows us to pull the list of monitoring documents from Box that were uploaded since the annual 
inspection/monitoring record was created. We then put that list into the Monitoring Documents text field on the annual inspection/monitoring record, which 
allows the monitor to make any necessary changes (i.e. removing documents from the list that don't need to be included in the PDF version of the monitoring 
report.) This field is then pulled into the PDF version of the monitoring report.

Note: The monitor has to manually check the 'Update Monitoring Documentation' checkbox field on the record to initiate the process that calls the apex class.

This test calls 'GetMonitoringDocuments.getAIIDs(ids);' directly rather than depending on the process so that even if it gets deactivated, we still
have full test coverage.
*/

@isTest
private class GetMonitoringDocumentsTest {
   
    static testMethod void runPositiveTestCases() {
        //insert test annual inspection records
        List<Annual_Inspection__c> aiList = TestDataFactory.createAnnualInspections(20, 5, 1);
        List<ID> ids = new List<ID>();
        for(Annual_Inspection__c ai : aiList){
            ids.add(ai.id);
        }
        
        //setup mock callout to Box
        Integer nextYear = (System.Today().year()+1);
        string bodyString = ('{"total_count":3,"entries":[{"type":"file","id":"230638187456","etag":"0","name":"MD_Kern River Preserve preliminary monitoring report 2016.docx","created_at":"'+ nextYear +'-09-27T16:16:20-07:00","created_by":{"type":"user","id":"2652742718","name":"Tester Katharine Anderson","login":"damunchkie5+testbox@gmail.com"},"shared_link":null},{"type":"file","id":"230638184356","etag":"0","name":"MD_Kern River Preserve site visit 28 August 2015.docx","created_at":"'+ nextYear +'-09-27T16:16:19-07:00","created_by":{"type":"user","id":"2652742718","name":"Tester Katharine Anderson","login":"damunchkie5+testbox@gmail.com"},"shared_link":null},{"type":"file","id":"230638059786","etag":"0","name":"Posting Authorship pre-2018.csv","created_at":"'+ nextYear +'-09-27T16:16:19-07:00","created_by":{"type":"user","id":"2652742718","name":"Tester Katharine Anderson","login":"damunchkie5+testbox@gmail.com"},"shared_link":null}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}');
        Blob bodyBlob = Blob.valueOf(bodyString);
        Map<String,String> Header = new Map<String,String>();
        Header.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(200,
                                                                               bodyBlob,
                                                                               Header);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
		
        //run callout and check results
        System.Test.startTest();
        	GetMonitoringDocuments.getAIIDs(ids);
        System.Test.stopTest();
        List<Annual_Inspection__c> aiList2 = [SELECT Monitoring_Documentation__c 
                                              FROM Annual_Inspection__c
                                              WHERE ID IN :aiList];
        String refreshText = 'It can take up to a minute for this field to update. Please refresh the page to see the updated list.';
        For(Annual_Inspection__c ai : aiList2){
            System.assert(ai.Monitoring_Documentation__c != null && ai.Monitoring_Documentation__c != refreshText, 'Monitoring Documentation field should not have the refresh text: '+ai.Monitoring_Documentation__c);
            System.debug('***Positive Test Case Monitoring Documentation field: '+ai.Monitoring_Documentation__c);
        }
    }
    static testMethod void runNegativeTestCases() {
        //insert test annual inspection records
        List<Annual_Inspection__c> aiList = TestDataFactory.createAnnualInspections(20, 5, 1);
        List<ID> ids = new List<ID>();
        for(Annual_Inspection__c ai : aiList){
            ids.add(ai.id);
        }
        
        //setup mock callout to Box
        Integer nextYear = (System.Today().year()+1);
        string bodyString = ('{"total_count":3,"entries":[{"type":"file","id":"230638187456","etag":"0","name":"MD_Kern River Preserve preliminary monitoring report 2016.docx","created_at":"'+ nextYear +'-09-27T16:16:20-07:00","created_by":{"type":"user","id":"2652742718","name":"Tester Katharine Anderson","login":"damunchkie5+testbox@gmail.com"},"shared_link":null},{"type":"file","id":"230638184356","etag":"0","name":"MD_Kern River Preserve site visit 28 August 2015.docx","created_at":"'+ nextYear +'-09-27T16:16:19-07:00","created_by":{"type":"user","id":"2652742718","name":"Tester Katharine Anderson","login":"damunchkie5+testbox@gmail.com"},"shared_link":null},{"type":"file","id":"230638059786","etag":"0","name":"Posting Authorship pre-2018.csv","created_at":"'+ nextYear +'-09-27T16:16:19-07:00","created_by":{"type":"user","id":"2652742718","name":"Tester Katharine Anderson","login":"damunchkie5+testbox@gmail.com"},"shared_link":null}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}');
        Blob bodyBlob = Blob.valueOf(bodyString);
        Map<String,String> Header = new Map<String,String>();
        Header.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(400,
                                                                               bodyBlob,
                                                                               Header);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
		
        //run callout and check results
        System.Test.startTest();
        GetMonitoringDocuments.getAIIDs(ids);
        System.Test.stopTest();
        List<Annual_Inspection__c> aiList2 = [SELECT Monitoring_Documentation__c 
                                              FROM Annual_Inspection__c
                                              WHERE ID IN :aiList];
        String errorText = 'Please contact your Salesforce adminstrator, there has been an issue pulling the list of monitoring documents from Box. Box Callout Response Status Code: 400';
        For(Annual_Inspection__c ai : aiList2){
            System.assert(ai.Monitoring_Documentation__c == errorText, 'Monitoring Documentation field should have the error text: '+ai.Monitoring_Documentation__c);
            System.debug('***Negative Test Case Monitoring Documentation field: '+ai.Monitoring_Documentation__c);
        }
    }
}