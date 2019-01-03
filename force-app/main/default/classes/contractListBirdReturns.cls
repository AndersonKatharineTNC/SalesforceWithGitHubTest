global class contractListBirdReturns {
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, BirdReturns_Bid_Name__r.Name FROM Contract]));
                setCon.setPageSize(1000);
            }
            if(!Test.isRunningTest()){
                setCon.setFilterId(Bird_Returns_Setting__c.getInstance().Contracts_List_View__c);
            }
            return setCon;
        }
        set;
    }
    public List<Contract> getContracts() {
        return (List<Contract>) setCon.getRecords();
    }
    
    @RemoteAction
    global static Id createStake(String lat, String lng, Id contractId) {
        List<Integer> stakeNames = new List<Integer>();
        for(Bird_Returns_Stake__c contractStake : [SELECT Id,Name
                                                      FROM Bird_Returns_Stake__c
                                                      WHERE Contract_Id__c =: contractId]) {
            stakeNames.add(Integer.valueOf(contractStake.Name));
        }

        stakeNames.sort();

        // the index of the last element in the list is size - 1. we then add 1 to THE VALUE to get the new name
        
        Integer newName;

        if(stakeNames.size()==0){
            newName = 1;
        } else {
             newName = stakeNames.get(stakeNames.size() - 1) + 1;
        }
        

        Bird_Returns_Stake__c stake = new Bird_Returns_Stake__c(Contract_Id__c = contractId, Name = String.valueOf(newName));
        stake.Stake_Location__latitude__s = Double.valueOf(lat);
        stake.Stake_Location__longitude__s = Double.valueOf(lng);
        insert stake;
        return stake.Id;
    }

    @RemoteAction
    global static Id createSCV(Id contractId) {
        List<Bird_Returns_Site_Compliance_Visit__c> scvstoday = [Select ID 
                                                                FROM Bird_Returns_Site_Compliance_Visit__c 
                                                                WHERE Bid_Id__c =: contractId
                                                                AND Visit_Date__c = TODAY 
                                                                AND Reporter_Type__c = 'Field Tech reporter'
                                                                LIMIT 1];
        if(scvstoday.size() == 0) {
            Bird_Returns_Site_Compliance_Visit__c scv = new Bird_Returns_Site_Compliance_Visit__c(Bid_Id__c = contractId);
            insert scv;
            return scv.Id;
        }
        return scvstoday[0].Id;
    }
}