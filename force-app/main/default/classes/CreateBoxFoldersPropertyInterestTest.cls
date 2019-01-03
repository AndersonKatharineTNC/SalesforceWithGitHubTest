/*
Written By: Katharine Anderson
Last Updated: 2018-12-19
Purpose: Test 'CreateBoxFoldersPropertyInterest.apxc' apex class. For Easement Monitoring - Requirement was to automatically create three standardized folders
in Box, and since they are common to all of the monitoring reports, they are located on the property interest record rather than the annual 
inspection/monitoring record. The current names of the folders are 'Monitoring Documents, Primary References, and Reports Archive'. The IDs of these folders 
are stored on the property interest record so that we can easily access/update them in the future if necessary.

Note: The 'Create Box Folders' field is defaulted to checked on property interest creation. This initiates the process ('Property Interest - Auto-Create Box 
Folders') that calls this code.

This test calls 'CreateBoxFoldersPropertyInterest.getPIIDs(PIIDs);' directly rather than depending on the process so that even if it gets deactivated, we still
have full test coverage.
*/

@isTest
private class  CreateBoxFoldersPropertyInterestTest {
    //Test class to test the creation of box folders.
    static testMethod void testInsertPI() {
        
        List<Property_Interest__c> piList = TestDataFactory.createPropertyInterests(10, 10);
        
        System.Test.startTest();
        Set<ID> setPIIDs = new Set<ID>();
        List<ID> PIIds = new List<ID>();
        for(Property_Interest__c PI : piList){
            setPIIDs.add(PI.id);
        }
        PIIDs.addAll(setPIIDs);
        	CreateBoxFoldersPropertyInterest.getPIIDs(PIIDs);
        System.Test.stopTest();
        List<Property_Interest__c> piList2 = new List<Property_Interest__c>();
        piList2 = [SELECT PRFolderID__c,MDFolderID__c,MRFolderID__c 
                   FROM Property_Interest__c
                   WHERE ID IN :piList];
        For (Property_Interest__c pi : piList2){
            System.debug('***PR Folder ID: '+ pi.PRFolderID__c + ' MD Folder ID: '+ pi.MDFolderID__c + ' MR Folder ID: ' + pi.MRFolderID__c);
            System.assert(pi.PRFolderID__c != null, '***PR folder: '+pi.PRFolderID__c);
            System.assert(pi.MDFolderID__c != null, '***MD folder: '+pi.MDFolderID__c);
            System.assert(pi.MRFolderID__c != null, '***MR folder: '+pi.MRFolderID__c);
        }
    }
}