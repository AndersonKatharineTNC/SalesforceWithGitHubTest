/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_WE_FW8_NP_WESearchResultTest
{
    private static testmethod void testTrigger()
    {
        // Force the dlrs_WE_FW8_NP_WESearchResultTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new WE_FW8_NP__WESearchResult__c());
    }
}