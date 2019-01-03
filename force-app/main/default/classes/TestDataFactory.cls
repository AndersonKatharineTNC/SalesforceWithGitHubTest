/*
Written By: Katharine Anderson
Last Updated: 12-19-2018
Purpose: Call these methods from test classes to create records to test against. Best practice as recommended 
by Salesforce. Add methods as needed for records of different objects.
*/

@isTest
public class TestDataFactory {
    
    public static List<Property_Management__c> createPropertyManagement (Integer numPMs){
        List<Property_Management__c> pmList = new List<Property_Management__c>();
        For (integer i=0; i < numPMs; i++){
            Property_Management__c PM = new Property_Management__c();
            PM = new Property_Management__c();
            PM.RecordTypeId = '0120c0000018JQW';
            PM.Name = 'Test' + i;
            PM.Ecoregion__c = 'TEST';
            pmList.add(PM);
        }
        insert pmList;
        system.assert(pmList.size() == numPMs, '***System Assert: ' +pmList.size() + ' records inserted, ' + numPMs + 'records expected.');
        return pmList;
    }
    
    public static List<Property_Interest__c> createPropertyInterests (Integer numPMs, Integer numPIs){
        List<Property_Management__c> pmList = TestDataFactory.createPropertyManagement(numPMs);
        List<Property_Interest__c> piList = new List<Property_Interest__c>();
        for (integer j=0; j < pmList.size(); j++){
            Property_Management__c pmu = pmList[j];
            for (integer k = 0; k < numPIs ; k++) {
                Property_Interest__c PI = new Property_Interest__c();
                PI.RecordTypeID = '012a0000001CGoS';
                PI.MRFolderID__c = '0000000000';
                PI.Property_Interest_Group__c = pmu.id;
                PI.Create_Box_Folders__c = false;
                PI.Name = 'TEST' + k;
                piList.add(PI);
            }
        }
        insert piList;
        system.assert(piList.size() == (numPIs*numPMs), '***System Assert: ' +piList.size() + ' records inserted, ' + (numPIs*numPMs) + 'records expected.');
        return piList;
    }
        
    public static List<Annual_Inspection__c> createAnnualInspections (Integer numPMs, Integer numPIs, Integer numAIs) {
        List<Property_Interest__c> piList = TestDataFactory.createPropertyInterests(numPMs, numPIs);        
        List<Annual_Inspection__c> aiList = new List<Annual_Inspection__c>();
        for (integer l=0; l < piList.size() ; l++ ){
            Property_Interest__c pir = piList[l];
            for(integer m = 0; m < numAIs ; m++){
                Annual_Inspection__c AI = new Annual_Inspection__c();
                AI.Status__c = 'Draft';
                AI.RecordTypeID = '012a0000001CH0F';
                AI.Property_Management_EDR__c = pir.Property_Interest_Group__c;
                AI.Property_Interest__c = pir.id;
                AI.Inspection_Date__c = Date.newInstance(2016, 12, 9);
                aiList.add(AI);
            }      
        }
        insert aiList;
        system.assert(aiList.size() == (numAIs*numPIs*numPMs), '***System Assert: ' +aiList.size() + ' records inserted, ' + (numAIs*numPIs*numPMs) + 'records expected.');
        return aiList;
    }
    public static List<box__FRUP__c> createFRUP (Integer numFRUPs){
        List<box__FRUP__c> frupList = new List<box__FRUP__c>();
        For (integer i=0; i < numFRUPs; i++){
    		box__FRUP__c frup = new box__FRUP__c();
    		frup.box__Object_Name__c = 'Property_Interest__c';
        	frup.box__Permission__c = 'Read/Write';
            frup.Manually_Set_Role__c = 'Viewer Uploader';
            frup.box__CollaborationID__c = '791293';
            frupList.add(frup);
        }
        insert frupList;
        system.assert(frupList.size() == numFRUPs, '***System Assert: ' +frupList.size() + ' records inserted, ' + numFRUPs + 'records expected.');
        return frupList;
    }    

}