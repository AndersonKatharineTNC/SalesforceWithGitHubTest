/*
Written By: Katharine Anderson
Last Updated: 2018-12-19
Purpose: For Easement Monitoring - Requirement was to automatically create three standardized folders in Box, and since they are common to all of the 
monitoring reports, they are located on the property interest record rather than the annual inspection/monitoring record. The current names of the folders
are 'Monitoring Documents, Primary References, and Reports Archive'. The IDs of these folders are stored on the property interest record so that we can 
easily access/update them in the future if necessary.

Longterm - To move more of the business logic to the declarative side:
New field: RecordFolderID on record
New object : System Created Box Folders
-parentFolderId
-folderId
-folderName
-parentRecord (Lookup)
-parentObjectName (formula?)
-parentRecordType (formula?) - can we somehow get this value on the FRUP records associated with this folder?

1) Headless Flow: Create System Created Box Folder record
2) Process on PI record: invokes Headless Flow 3 times when property interest record created, once for each folder
3) Process on System Created Box Folder record: invokes apex when System Created Box Folder record is created to create folder and update record with folder
ID from Box. Process also invokes apex when System Created Box Folder record is updated to change the folder name (in case we need to change to folder Names en 
masse).
4) Invocable apex: makes call-out to box to create/update box folder. Returns folder ID. 
5) DLRS Rollup: For monitoring documents folder, rolls up folder ID to property interest record (for 'Get Monitoring Documents' apex class to use in pulling 
down the documents into the monitoring report).

Note: The 'Create Box Folders' field is defaulted to checked on property interest creation. This initiates the process ('Property Interest - Auto-Create Box 
Folders') that calls this code.
*/

public class CreateBoxFoldersPropertyInterest {
    @future (callout = true)
    public static void createFoldersInBox(List<Id> PIIds){
        box.Toolkit boxToolkit = new box.Toolkit();
        LIST<Property_Interest__c> piList = [SELECT ID, PRFolderID__c, MDFolderID__c, MRFolderID__c 
                                             FROM Property_Interest__c 
                                             WHERE ID IN :PIIds];
        Id userId = UserInfo.getUserId();
        for(Property_Interest__c pi : piList){
            // Create a folder and associate it with a Property Interest Record
            String PIFolderId = boxToolkit.createFolderForRecordId(pi.ID, null, true);
            system.debug('new item folder id: ' + PIFolderId);
            
            // Create three sub-folders in the newly created account folder
            String PRFolderId = boxToolkit.createFolder('Primary References', PIFolderId, null);
            system.debug('Primary References Folder id: ' + PRFolderId);
            String MDFolderId = boxToolkit.createFolder('Monitoring Documents', PIFolderId, null);
            system.debug('Monitoring Documents Folder id: ' + MDFolderId);
            String MRFolderId = boxToolkit.createFolder('Reports Archive', PIFolderId, null);
            system.debug('Reports Archive Folder id: ' + MRFolderId);
            
            // Update the folder ID fields 
            pi.PRFolderID__c = PRFolderId;
            pi.MDFolderID__c = MDFolderId;
            pi.MRFolderID__c = MRFolderId;
            pi.Create_Box_Folders__c = False;
            
            // Collaborate the current user on the property interest folder. Note that we're sending false for the optCreateFolder param that shouldn't actually matter since the folder(s) already exists
            box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
            String collabId = boxToolkit.createCollaborationOnRecord(userId, pi.ID, collabType, false);
            system.debug('new collaboration id: ' + collabId);
        }
        // ALWAYS call this method when finished. Since salesforce doesn't allow http callouts after dml operations, we need to commit the pending database inserts/updates or we will lose the associations created
        boxToolkit.commitChanges();
        
        update piList;
    }

	@InvocableMethod(label='Create Folders' description='Creates folders in Box for the Property Interest.')
    public static void getPIIDs(List<ID> ids) {
        CreateBoxFoldersPropertyInterest.createFoldersInBox(ids);
    } 
}