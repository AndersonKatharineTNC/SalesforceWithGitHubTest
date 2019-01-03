/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Annual_InspectionTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Annual_InspectionTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Annual_Inspection__c());
    }
}