/*
No longer in use: replaced by Process Builder.
*/

trigger UpdatePermissions on box__FRUP__c (before insert, before update) {
    //Check User ID against Assignee ID. If not in list, change FRUP Role (Box Collaboration) to  'Viewer Uploader' instead of 'Editor'.
        for (box__FRUP__c frup : Trigger.New) {
        system.debug(frup.box__Salesforce_User__c);
        system.debug(frup.Salesforce_User_Profile__c);
            //System Administrators should always be editors
            if(frup.Salesforce_User_Profile__c == 'System Administrator'){
                frup.Manually_Set_Role__c = 'Editor';
            }
            //If Role set manually, set that as the new role.
            if(frup.Manually_Set_Role__c != null && frup.box__Salesforce_User__c != null){
                            //Update the role in Box
                //UpdateBoxCollaboration.updateBox(frup.box__CollaborationID__c,frup.Manually_Set_Role__c );
            }
            }
}