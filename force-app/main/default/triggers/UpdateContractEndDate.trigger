trigger UpdateContractEndDate on Contract_Amendment__c (after insert, after update) {
    try
    {
        Set<Id> contractAmendIdSet = new Set<Id>();
        for (Contract_Amendment__c i: Trigger.new) {
            contractAmendIdSet.add(i.Id);
        }

        Map<Id, Contract_Amendment__c> contractAmendMap = new Map<Id, Contract_Amendment__c>(
            [select Id, Contract_Number__c, Status__c, Extend_Contract_End_Date__c, New_Contract_End_Date__c  from Contract_Amendment__c where Id in :contractAmendIdSet]);
        
        Set<Id> contractIdSet = new Set<Id>();
        for (Contract_Amendment__c i: Trigger.new) {
            if (contractAmendMap.containsKey(i.Id)) {
                Contract_Amendment__c contractAmendObj = contractAmendMap.get(i.Id);
                // Only if Contract Amendment has Extend Contract End Date = Yes and Status = Approved
                // Then adding it to the list 
                if(contractAmendObj!=null && 
                    contractAmendObj.Status__c=='Approved' && 
                    contractAmendObj.Extend_Contract_End_Date__c=='Yes') {
                    contractIdSet.add(contractAmendObj.Contract_Number__c);
                }
            }
        }

        Map<Id, Contract> contractMap = new Map<Id, Contract>(
            [select Id, ContractNumber, EndDate  from Contract where Id in :contractIdSet]);
        
        List<Contract> contractList = new List<Contract>();
        for (Contract_Amendment__c i: Trigger.new) {
            if (contractAmendMap.containsKey(i.Id)) {
                Contract_Amendment__c contractAmendObj = contractAmendMap.get(i.Id);
                if(contractAmendObj.Contract_Number__c!=null && 
                    contractMap.containsKey(contractAmendObj.Contract_Number__c)){
                    Contract c = contractMap.get(contractAmendObj.Contract_Number__c);
                    c.EndDate = contractAmendObj.New_Contract_End_Date__c;
                    contractList.add(c);
                }
            }
        }
        if(contractList.size() >0){
            update contractList;
        }
    }
    catch (System.DmlException e) {
        System.debug(e.getDmlMessage(0));
    }   
}