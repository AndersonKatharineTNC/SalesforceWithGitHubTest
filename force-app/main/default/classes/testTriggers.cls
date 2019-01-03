public class testTriggers {
	public static testmethod void test_UpdateContractEndDate() {
		
		Account a = new Account(Name='Deepak Apex Test Account', Type='Nonprofit', Website='http://www.test.com/');
		insert a;
		Account reta = [select id, Name from Account where id=:a.id][0];
		System.assertEquals(a.Id, reta.id);
		System.assertEquals('Deepak Apex Test Account', reta.Name);

		Contract c = new Contract(Name='Deepak Apex Test Contract', AccountId=a.Id, Description='Test Desc', OwnerExpirationNotice = '60', EndDate = date.newInstance(2006,01,01));
		insert c;
		Contract retc = [select id, Name, ContractNumber from Contract where id=:c.id][0];
		System.assertEquals(c.Id, retc.id);
		System.assertEquals('Deepak Apex Test Contract', retc.Name);
		

		
		Contract_Amendment__c ca = new Contract_Amendment__c(Contract_Number__c=c.Id, Status__c='Approved', Extend_Contract_End_Date__c = 'Yes', New_Contract_End_Date__c = Date.valueOf('2008-12-31'), Operations__c = UserInfo.getUserId() );
		insert ca;
		Contract_Amendment__c retca = [select id, Contract_Number__c from Contract_Amendment__c where id=:ca.id][0];
		System.assertEquals(ca.Id, retca.id);
		System.assertEquals(c.Id, retca.Contract_Number__c);
		
		Set<Id> contractAmendIdSet = new Set<Id>();
		contractAmendIdSet.add(retca.Id);
		

		Map<Id, Contract_Amendment__c> contractAmendMap = new Map<Id, Contract_Amendment__c>(
			[select Id, Contract_Number__c, Status__c, Extend_Contract_End_Date__c, New_Contract_End_Date__c  from Contract_Amendment__c where Id in :contractAmendIdSet]);
		
		Set<Id> contractIdSet = new Set<Id>();
		if (contractAmendMap.containsKey(retca.Id)) {
			Contract_Amendment__c contractAmendObj = contractAmendMap.get(retca.Id);
			// Only if Contract Amendment has Extend Contract End Date = Yes and Status = Approved
			// Then adding it to the list 
			if(contractAmendObj!=null && 
				contractAmendObj.Status__c=='Approved' && 
				contractAmendObj.Extend_Contract_End_Date__c=='Yes') {
				contractIdSet.add(contractAmendObj.Contract_Number__c);
			}
		}
		

		Map<Id, Contract> contractMap = new Map<Id, Contract>(
			[select Id, ContractNumber, EndDate  from Contract where Id in :contractIdSet]);
		
		List<Contract> contractList = new List<Contract>();
		
		if (contractAmendMap.containsKey(retca.Id)) {
			Contract_Amendment__c contractAmendObj = contractAmendMap.get(retca.Id);
			if(contractAmendObj.Contract_Number__c!=null && 
				contractMap.containsKey(contractAmendObj.Contract_Number__c)){
				Contract ct = contractMap.get(contractAmendObj.Contract_Number__c);
				ct.EndDate = contractAmendObj.New_Contract_End_Date__c;
				contractList.add(ct);
			}
		}
		
		if(contractList.size() >0){
			update contractList;
		}		
		
	}
}