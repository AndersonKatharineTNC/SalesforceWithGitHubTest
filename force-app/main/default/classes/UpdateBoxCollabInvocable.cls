/*
Written By: Katharine Anderson
Last Updated: 2018-12-19
Purpose: Triggers 'UpdateBoxCollaboration.updateBox(frupIds)'. Originally for Easement Monitoring - Requirement was to be able to control the level of access 
that the monitors have to manage the files in the Property Interest Box Folders. Particularly, only the Monitoring & Oversight Program Director, currently Lynn 
Lozier, and the Salesforce admins, should have full editor access. Everyone else should have the 'Viewer Uploader' collaboration role, so that they cannot delete, 
rename, or move existing files.

However, this code was intentionally written so that all of the business logic (i.e. object, collaboration role, user, etc.) is set by process so that if there are 
changes needed in the future, or if we want to expand this functionality to other objects or set different collaboration roles for other objects, we can easily do 
that declaratively.

Note: The test (UpdatePermissionsTest.apxc) bypasses the two related processes that trigger UpdateBoxCollabInvocable.BoxCallout(ids) so that if they get turned off, 
the test will still have full coverage. Process Builder processes: 'FRUP - Update default collaboration Roles' updates the manually set role field, and 'FRUP - 
Update Box Collaboration via API' triggers the actual callout to Box.
*/

public class UpdateBoxCollabInvocable {
  @InvocableMethod
   public static void BoxCallout(list<ID> frupIDs) {
       UpdateBoxCollaboration.updateBox(frupIDs);
   }
}