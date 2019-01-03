/*
No longer in use: replaced by Process Builder/PDFGeneratorController2.apxc.
*/

//Trigger that converts the attchment into a box file when the attachment is added to the Annual Inspection record. Will add additional filters to make sure that only the right attachments are added once I can verify that it is working at all.

trigger ConvertToBoxFile on Attachment (after insert) {
    For (Attachment ar : Trigger.new){
        string attachmentId = ar.Id;
        if(((String)ar.ParentId).startsWith('a0B')){
            Attachment a = [SELECT Id, Name, Body, ParentId
                         FROM Attachment
                         WHERE Id =:attachmentId];
			box.Toolkit boxToolkit = new box.Toolkit();
/* createFileFromAttachment params:
    Attachment att - required - This is the file to add in Box

    String fileNameOverride - optional/null - If a non-null value is sent, that will be the name of the file in Box (be sure to include the extension)

    String folderIdOverride - optional/null - If a value is sent, the attachment will be uploaded to this folder id.  Otherwise, it is uploaded to the folder associated with this salesforce record.  If no folder exists, one will be created

    String accessToken - optional/null - If a value is sent, this will be used as the accessToken to connect to box.  Otherwise, the service user credentials are used.  Generally this is sent as null.
*/

String fileId = boxToolkit.createFileFromAttachment(a, null, null, null);
system.debug('most recent error: ' + boxToolkit.mostRecentError);
boxToolkit.commitChanges();
    }
// optionally do something with fileId if needed
}
}