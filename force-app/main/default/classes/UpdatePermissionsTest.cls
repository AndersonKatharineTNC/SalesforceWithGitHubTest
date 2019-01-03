/*
Written By: Katharine Anderson
Last Updated: 2018-12-19
Purpose: Tests 'UpdateBoxCollabInvocable.apxc' and 'UpdateBoxCollaboration.apxc'. Originally for Easement Monitoring - Requirement was to be able to control the 
level of access that the monitors have to manage the files in the Property Interest Box Folders. Particularly, only the Monitoring & Oversight Program Director, 
currently Lynn Lozier, and the Salesforce admins, should have full editor access. Everyone else should have the 'Viewer Uploader' collaboration role, so that they
cannot delete, rename, or move existing files.

However, this code was intentionally written so that all of the business logic (i.e. object, collaboration role, user, etc.) is set by process so that if there are 
changes needed in the future, or if we want to expand this functionality to other objects or set different collaboration roles for other objects, we can easily do 
that declaratively.

Note: This test bypasses the two related processes that trigger UpdateBoxCollabInvocable.BoxCallout(ids) so that if they get turned off, the test will still
have full coverage. Process Builder processes: 'FRUP - Update default collaboration Roles' updates the manually set role field, and 'FRUP - Update Box 
Collaboration via API' triggers the actual callout to Box.
*/

@isTest
private class UpdatePermissionsTest {
        static testMethod void runPositiveTestCases() {
        //insert test annual inspection records
        List<box__FRUP__c> frupList = testDataFactory.createFRUP(100);
        List<ID> ids = new List<ID>();
        for(box__FRUP__c frup : frupList){
            ids.add(frup.id);
        }
        
        //setup mock callout to Box
        string bodyString = ('{"type": "collaboration","id": "791293","created_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"created_at": "2017-12-12T10:54:37-08:00","modified_at": "2017-12-12T11:30:43-08:00","expires_at": null,"status": "accepted","accessible_by": {"type": "user","id": "18203124","name": "sean","login": "sean+test@box.com"},"role": "viewer","acknowledged_at": "2017-12-12T11:30:43-08:00","item": {"type": "folder","id": "11446500","sequence_id": "0","etag": "0","name": "Shared Pictures"}}');
        Blob bodyBlob = Blob.valueOf(bodyString);
        Map<String,String> Header = new Map<String,String>();
        Header.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(200,
                                                                               bodyBlob,
                                                                               Header);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
		
        //run callout and check results
        System.Test.startTest();
        	UpdateBoxCollabInvocable.BoxCallout(ids);
        System.Test.stopTest();
        List<box__FRUP__c> frupList2 = [SELECT Manually_Set_Role__c, Box_Update_Response__c
                                        FROM box__FRUP__c
                                        WHERE ID IN :frupList];
        For(box__FRUP__c frup : frupList2){
            String expectedResponse = 'Box updated, new collaboration role: Viewer Uploader';
            System.assert(frup.Box_Update_Response__c == expectedResponse, 'Box Response: '+frup.Box_Update_Response__c);
            System.debug('***Positive Test Case Manually Set Role field: '+frup.Box_Update_Response__c);
        }
    }
    static testMethod void runNegativeTestCases() {
        //insert test annual inspection records
        List<box__FRUP__c> frupList = testDataFactory.createFRUP(100);
        List<ID> ids = new List<ID>();
        for(box__FRUP__c frup : frupList){
            ids.add(frup.id);
        }
        
        //setup mock callout to Box
        string bodyString = ('{"type": "collaboration","id": "791293","created_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"created_at": "2017-12-12T10:54:37-08:00","modified_at": "2017-12-12T11:30:43-08:00","expires_at": null,"status": "accepted","accessible_by": {"type": "user","id": "18203124","name": "sean","login": "sean+test@box.com"},"role": "viewer","acknowledged_at": "2017-12-12T11:30:43-08:00","item": {"type": "folder","id": "11446500","sequence_id": "0","etag": "0","name": "Shared Pictures"}}');
        Blob bodyBlob = Blob.valueOf(bodyString);
        Map<String,String> Header = new Map<String,String>();
        Header.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(400,
                                                                               bodyBlob,
                                                                               Header);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
		
        //run callout and check results
        System.Test.startTest();
        	UpdateBoxCollabInvocable.BoxCallout(ids);
        System.Test.stopTest();
        List<box__FRUP__c> frupList2 = [SELECT Manually_Set_Role__c, Box_Update_Response__c  
                                        FROM box__FRUP__c
                                        WHERE ID IN :frupList];
        For(box__FRUP__c frup : frupList2){
            String expectedResponse = 'Box not updated, response code: 400';
            System.assert(frup.Box_Update_Response__c == expectedResponse, 'Box Response: '+frup.Box_Update_Response__c);
            System.debug('***Negative Test Case Manually Set Role field: '+frup.Box_Update_Response__c);
        }
    }
}