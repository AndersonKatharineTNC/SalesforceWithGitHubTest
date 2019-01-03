@isTest
private class contractListBirdReturnsTest {
	
	@testSetup static void initAcctAndContract() {
		Account a = new Account(Name='Bigger Boat Consulting', Type='Super Friend', Website='http://www.brgrbt.com/');
		insert a;
		Contract c = new Contract(Name='BBC Test Contract', AccountId=a.Id, Description='Test Desc', No_Contract_End_Date__c = true);
		insert c;
	}
	
	@isTest static void test_createSCV() {
		// when createSCV is called with a contract ID
		//   - a SCV is created with today's date for that contract.
		//   - that SCV ID is returned
		// when createSCV is called again
		//   - the first SCV ID is returned

		Contract c = [SELECT Id FROM Contract LIMIT 1][0];
		ID scvId = contractListBirdReturns.createSCV(c.Id);
		System.assertNotEquals(scvId,null);
		ID scvId2 = contractListBirdReturns.createSCV(c.Id);
		System.assertEquals(scvId,scvId2);
	}
	
	@isTest static void test_createStake() {
		// when createStake is called with a contract ID and lat/lng
		//   - a stake is created with that lat/lng pair
		// 	 - that stake has a Name of the next stake in the sequence (max current stakenames + 1)
		//   - calling it again will thusly create a stake with the NEXT sequence name
		Contract c = [SELECT Id FROM Contract LIMIT 1][0];
		ID stakeId = contractListBirdReturns.createStake('49.000', '-89.000',c.Id);
		System.assertNotEquals(stakeId,null);
		Bird_Returns_Stake__c firstStake = [Select Id,Name from Bird_Returns_Stake__c WHERE ID =: stakeId];
		System.assertEquals('1',firstStake.Name);
		ID stakeId2 = contractListBirdReturns.createStake('49.000', '-89.000',c.Id);
		Bird_Returns_Stake__c secondStake = [Select Id,Name from Bird_Returns_Stake__c WHERE ID =: stakeId2];
		System.assertEquals('2',secondStake.Name);
	}

	@isTest static void test_setController() {
		// when the controller is instantiated
		//   - a group of contracts should be selected
		contractListBirdReturns controller = new contractListBirdReturns();
		List<Contract> results = controller.getContracts();
		System.assertEquals(1,results.size());
	}
}