
/* Ways to improve query performance
    1) toggle on/off staging
    1) reduce the amount of steps to minimum
        a) combine steps together
        b) 

*/

// SD error management

    let
            
        Source = SharePoint.Tables(
            "https://nswgov.sharepoint.com/sites/SDErrorManagement2.0", 
            [Implementation = null, ApiVersion = 15]
        ), 
        #"Navigation 1" = Source{[Id = "0ae2c82b-d424-4f51-976f-70ada3fa349a"]}[Items], 
        #"Changed column type" = Table.TransformColumnTypes(
            #"Navigation 1", 
            {{"Created", type datetime}, {"Modified", type datetime}}
        ), 
        
        //how many records are there?
        #"Expanded Issue Type" = Table.ExpandRecordColumn(
            #"Changed column type", 
            "Issue Type", 
            {"TermGuid"}, 
            {"Issue Type.TermGuid"}
        ), 

        //nested record expansion - can potentially split into different DFs
        #"Expanded Partner agency" = Table.ExpandRecordColumn(
            #"Expanded Issue Type", 
            "Partner agency", 
            {"TermGuid"}, 
            {"Partner agency.TermGuid"}
        ), 

        //nested record expansion - can potentially split into different DFs
        #"Expanded AssignedTo" = Table.ExpandRecordColumn(
            #"Expanded Partner agency", 
            "AssignedTo", 
            {"Title"}, 
            {"AssignedTo.Title"}
        ), 

        //suggest removing all columns not needed at this stage
        #"Renamed columns 1" = Table.RenameColumns(
            #"Expanded AssignedTo", 
            {{"StaffLogin", "StaffNumber"}, {"Team member name", "StaffName"}}
        ), 

        //set duplicated column name within query
        #"Duplicated column" = Table.DuplicateColumn(
            #"Renamed columns 1", 
            "StaffNumber", 
            "StaffNumber - Copy"  // replace with below
            //"StaffLogin"
        ), 

        //remove step
        #"Renamed columns 2" = Table.RenameColumns(
            #"Duplicated column", 
            {{"StaffNumber - Copy", "StaffLogin"}}
        ), 

        #"Transform columns" = Table.TransformColumnTypes(
            #"Renamed columns 2", 
            {
            {"FileSystemObjectType", type text}, 
            {"Id", type text}, 
            {"ServerRedirectedEmbedUri", type text}, 
            {"ServerRedirectedEmbedUrl", type text}, 
            {"ContentTypeId", type text}, 
            {"Title", type text}, 
            {"OData__ColorTag", type text}, 
            {"ComplianceAssetId", type text}, 
            {"Action Taken", type text}, 
            {"Region", type text}, 
            {"Outcome", type text}, 
            {"Action Required", type text}, 
            {"Date Error Received0", type text}, 
            {"JobID", type text}, 
            {"Issue description", type text}, 
            {"Outcome comments", type text}, 
            {"Rating", type text}, 
            {"Priority", type text}, 
            {"Customerimpact", type text}, 
            {"ServiceNSWimpact", type text}, 
            {"Resolutiontype", type text}, 
            {"ErrorManagementType", type text}, 
            {"ActionedById", type text}, 
            {"ActionedByStringId", type text}, 
            {"Issue Status", type text}, 
            {"Verified", type text}, 
            {"Location", type text}, 
            {"Channel", type text}, 
            {"Service type", type text}, 
            {"AnyMissingFields", type text}, 
            {"Reassign", type text}, 
            {"StaffNumber", type text}, 
            {"StaffName", type text}, 
            {"ApprovalStatus", type text}, 
            {"RejectionReason", type text}, 
            {"Reopen", type text}, 
            {"PartnerAgencyError", type text}, 
            {"UrgentEmailSent", type text}, 
            {"FollowUpCount", type text}, 
            {"Issue Type.TermGuid", type text}, 
            {"Partner agency.TermGuid", type text}, 
            {"ReOpenComments", type text}, 
            {"CustomerName", type text}, 
            {"ReferenceNumber", type text}, 
            {"StaffLogin", type text}, 
            {"Dateofoccurrence", type text}, 
            {"privacybreach", type text}, 
            {"SHIFTError", type text}, 
            {"AssignedToId", type text}, 
            {"AssignedToStringId", type text}, 
            {"OverdueDays", type text}, 
            {"DueDate", type text}, 
            {"ID", type text}, 
            {"AuthorId", type text}, 
            {"EditorId", type text}, 
            {"OData__UIVersionString", type text}, 
            {"Attachments", type text}, 
            {"GUID", type text}, 
            {"AssignedTo.Title", type text}
            }
        ), 

        // move this up to be after remove columns
        #"Replace errors" = Table.ReplaceErrorValues(
            #"Transform columns", 
            {
            {"FileSystemObjectType", null}, 
            {"Id", null}, 
            {"ServerRedirectedEmbedUri", null}, 
            {"ServerRedirectedEmbedUrl", null}, 
            {"ContentTypeId", null}, 
            {"Title", null}, 
            {"OData__ColorTag", null}, 
            {"ComplianceAssetId", null}, 
            {"Action Taken", null}, 
            {"Region", null}, 
            {"Outcome", null}, 
            {"Action Required", null}, 
            {"Date Error Received0", null}, 
            {"JobID", null}, 
            {"Issue description", null}, 
            {"Outcome comments", null}, 
            {"Rating", null}, 
            {"Priority", null}, 
            {"Customerimpact", null}, 
            {"ServiceNSWimpact", null}, 
            {"Resolutiontype", null}, 
            {"ErrorManagementType", null}, 
            {"ActionedById", null}, 
            {"ActionedByStringId", null}, 
            {"Issue Status", null}, 
            {"Verified", null}, 
            {"Location", null}, 
            {"Channel", null}, 
            {"Service type", null}, 
            {"AnyMissingFields", null}, 
            {"Reassign", null}, 
            {"StaffNumber", null}, 
            {"StaffName", null}, 
            {"ApprovalStatus", null}, 
            {"RejectionReason", null}, 
            {"Reopen", null}, 
            {"PartnerAgencyError", null}, 
            {"UrgentEmailSent", null}, 
            {"FollowUpCount", null}, 
            {"Issue Type.TermGuid", null}, 
            {"Partner agency.TermGuid", null}, 
            {"ReOpenComments", null}, 
            {"CustomerName", null}, 
            {"ReferenceNumber", null}, 
            {"StaffLogin", null}, 
            {"Dateofoccurrence", null}, 
            {"privacybreach", null}, 
            {"SHIFTError", null}, 
            {"OData__ColorTag", null}, 
            {"AssignedToId", null}, 
            {"AssignedToStringId", null}, 
            {"OverdueDays", null}, 
            {"DueDate", null}, 
            {"ID", null}, 
            {"AuthorId", null}, 
            {"EditorId", null}, 
            {"OData__UIVersionString", null}, 
            {"Attachments", null}, 
            {"GUID", null}, 
            {"AssignedTo.Title", null}
            }
        ), 
        // remove columns after Table.ExpandRecordColumn
        #"Remove columns" = 
            Table.RemoveColumns(
                #"Replace errors", 
                Table.ColumnsOfType(
                    #"Replace errors", 
                    {type table, type record, type list, type nullable binary, type binary, type function}
                    )
        ), 
        #"Renamed columns" = Table.RenameColumns(#"Remove columns", {{"ID", "ID 1"}}), 
        
        //combine to be with previous transform column types
        #"Transform columns 1" = Table.TransformColumnTypes(
            #"Renamed columns", 
            {
            {"Reassign Reason", type text}, 
            {"Messages", type text}, 
            {"Business Unit", type text}, 
            {"OverDueDays0", type text}, 
            {"Issue categories", type text}, 
            {"Related links", type text}, 
            {"Information Compromised", type text}, 
            {"Number of customers", type text}, 
            {"Exposed to", type text}, 
            {"Has the information_", type text}, 
            {"Additional Comments ", type text}
            }
        ), 

        //combine with previous replace errors
        #"Replace errors 1" = Table.ReplaceErrorValues(
            #"Transform columns 1", 
            {
            {"Reassign Reason", null}, 
            {"Messages", null}, 
            {"Business Unit", null}, 
            {"OverDueDays0", null}, 
            {"Issue categories", null}, 
            {"Related links", null}, 
            {"Information Compromised", null}, 
            {"Number of customers", null}, 
            {"Exposed to", null}, 
            {"Has the information_", null}, 
            {"Additional Comments ", null}
            }
        ), 

        //ensure all column renaming done in 1 step
        #"Renamed columns 3" = Table.RenameColumns(
            #"Replace errors 1", 
            {{"Additional Comments ", "Additional Comments"}}
        )
    in
        #"Renamed columns 3"



// NSW Service ErrorCaptureForms

    // ErrorCaptureForms

    let
        Source = SharePoint.Tables(
            "https://nswgov.sharepoint.com/sites/ErrorCaptureForms", 
            [ApiVersion = 15]
        ), 
        #"e44c03c3-e5ae-42fb-a483-06b108751186" = Source
            {[Id = "e44c03c3-e5ae-42fb-a483-06b108751186"]}
            [Items], 
        #"Changed column type 1" = Table.TransformColumnTypes(
            #"e44c03c3-e5ae-42fb-a483-06b108751186", 
            {{"Days", Int64.Type}}
        ), 
        #"Renamed Columns" = Table.RenameColumns(#"Changed column type 1", {{"ID", "ID.1"}}), 
        #"Replaced errors 1" = Table.ReplaceErrorValues(#"Renamed Columns", {{"Days", 0}}), 
        #"Duplicated Column" = Table.DuplicateColumn(
            #"Replaced errors 1", 
            "FieldValuesAsText", 
            "FieldValuesAsText - Copy"
        ), 
        #"Replaced errors" = Table.ReplaceErrorValues(#"Duplicated Column", {{"Ticket Age", 0}}), 
        #"Changed Type" = Table.TransformColumnTypes(#"Replaced errors", {{"Ticket Age", Int64.Type}}), 
        #"Duplicated Column1" = Table.DuplicateColumn(
            #"Changed Type", 
            "FieldValuesAsText - Copy", 
            "FieldValuesAsText - Copy - Copy"
        ), 
        #"Expanded FieldValuesAsText - Copy" = Table.ExpandRecordColumn(
            #"Duplicated Column1", 
            "FieldValuesAsText - Copy", 
            {"Partner_x0020_Agency"}, 
            {"FieldValuesAsText - Copy.Partner_x0020_Agency"}
        ), 
        #"Renamed Columns1" = Table.RenameColumns(
            #"Expanded FieldValuesAsText - Copy", 
            {{"FieldValuesAsText - Copy.Partner_x0020_Agency", "Agency1"}}
        ), 
        #"Duplicated Column2" = Table.DuplicateColumn(
            #"Renamed Columns1", 
            "FieldValuesAsText - Copy - Copy", 
            "FieldValuesAsText - Copy - Copy - Copy"
        ), 
        #"Expanded FieldValuesAsText - Copy - Copy" = Table.ExpandRecordColumn(
            #"Duplicated Column2", 
            "FieldValuesAsText - Copy - Copy", 
            {"Author"}, 
            {"FieldValuesAsText - Copy - Copy.Author"}
        ), 
        #"Renamed Columns2" = Table.RenameColumns(
            #"Expanded FieldValuesAsText - Copy - Copy", 
            {{"FieldValuesAsText - Copy - Copy.Author", "Author1"}, {"Agency1", "Agency0"}}
        ), 
        #"Expanded FieldValuesAsText - Copy - Copy - Copy" = Table.ExpandRecordColumn(
            #"Renamed Columns2", 
            "FieldValuesAsText - Copy - Copy - Copy", 
            {"Agency"}, 
            {"FieldValuesAsText - Copy - Copy - Copy.Agency"}
        ), 
        #"Renamed Columns3" = Table.RenameColumns(
            #"Expanded FieldValuesAsText - Copy - Copy - Copy", 
            {{"Agency0", "Agency1"}}
        ), 
        #"Split Column by Delimiter" = Table.SplitColumn(
            #"Renamed Columns3", 
            "FieldValuesAsText - Copy - Copy - Copy.Agency", 
            Splitter.SplitTextByDelimiter(":", QuoteStyle.None), 
            {
            "FieldValuesAsText - Copy - Copy - Copy.Agency.1", 
            "FieldValuesAsText - Copy - Copy - Copy.Agency.2"
            }
        ), 
        #"Changed Type1" = Table.TransformColumnTypes(
            #"Split Column by Delimiter", 
            {
            {"FieldValuesAsText - Copy - Copy - Copy.Agency.1", type text}, 
            {"FieldValuesAsText - Copy - Copy - Copy.Agency.2", type text}
            }
        ), 
        #"Renamed Columns4" = Table.RenameColumns(
            #"Changed Type1", 
            {
            {"FieldValuesAsText - Copy - Copy - Copy.Agency.1", "Cluster"}, 
            {"FieldValuesAsText - Copy - Copy - Copy.Agency.2", "Agency0"}
            }
        ), 
        #"Expanded FieldValuesAsText" = Table.ExpandRecordColumn(
            #"Renamed Columns4", 
            "FieldValuesAsText", 
            {"Staff_x0020_Name"}, 
            {"FieldValuesAsText.Staff_x0020_Name"}
        ), 
        #"Transform columns" = Table.TransformColumnTypes(
            #"Expanded FieldValuesAsText", 
            {
            {"FileSystemObjectType", type text}, 
            {"Id", type text}, 
            {"ServerRedirectedEmbedUri", type text}, 
            {"ServerRedirectedEmbedUrl", type text}, 
            {"ContentTypeId", type text}, 
            {"Title", type text}, 
            {"ComplianceAssetId", type text}, 
            {"Action Taken", type text}, 
            {"AssignedToId", type text}, 
            {"AssignedToStringId", type text}, 
            {"Completed Date", type text}, 
            {"Error Status", type text}, 
            {"Issue", type text}, 
            // ... (Other columns' types to be transformed) ...
            {"Agency1", type text}, 
            {"Author1", type text}
            }
        ), 
        #"Replace errors" = Table.ReplaceErrorValues(
            #"Transform columns", 
            {
            {"FileSystemObjectType", "0"}, 
            {"Id", "0"}, 
            // ... (Other columns' error values to be replaced) ...
            {"GUID", "0"}, 
            {"Agency1", "0"}, 
            {"Author1", "0"}
            }
        ), 
        #"Remove columns" = Table.RemoveColumns(
            #"Replace errors", 
            Table.ColumnsOfType(
            #"Replace errors", 
            {type table, type record, type list, type nullable binary, type binary, type function}
            )
        ), 
        #"Renamed columns" = Table.RenameColumns(
            #"Remove columns", 
            {{"Action Verification ", "Action Verification"}}
        ), 
        #"Changed column type" = Table.TransformColumnTypes(
            #"Renamed columns", 
            {{"Completed Date", type datetime}, {"Modified", type datetime}}
        ), 
        #"Removed columns" = Table.RemoveColumns(
            #"Changed column type", 
            {"AssignedToStringId", "AssignedToId"}
        ), 
        #"Added custom" = Table.AddColumn(#"Removed columns", "AssignedToId", each [Service Center]), 
        #"Transform columns 1" = Table.TransformColumnTypes(
            #"Added custom", 
            {{"AssignedToId", type text}}
        ), 
        #"Filtered rows" = Table.SelectRows(#"Transform columns 1", each [Days] <> null), 
        #"Replace errors 1" = Table.ReplaceErrorValues(#"Filtered rows", {{"AssignedToId", null}}), 
        #"Duplicated column" = Table.DuplicateColumn(
            #"Replace errors 1", 
            "AssignedToId", 
            "AssignedToId - Copy"
        ), 
        #"Renamed columns 1" = Table.RenameColumns(
            #"Duplicated column", 
            {{"AssignedToId - Copy", "AssignedToStringId"}}
        ), 
        #"Transform columns 2" = Table.TransformColumnTypes(
            #"Renamed columns 1", 
            {{"Business Unit Report", type text}}
        ), 
        #"Transform columns 3" = Table.TransformColumnTypes(
            #"Transform columns 2", 
            {
            {"ErrorPartnerID", type text}, 
            {"PreviousErrorStatus", type text}, 
            {"MaritimeCombineApprovedEmailSent", type text}, 
            {"Custattendancerequired", type text}, 
            {"FieldValuesAsText.Staff_x0020_Name", type text}
            }
        ), 
        #"Replace errors 2" = Table.ReplaceErrorValues(
            #"Transform columns 3", 
            {
            {"ErrorPartnerID", null}, 
            {"PreviousErrorStatus", null}, 
            {"MaritimeCombineApprovedEmailSent", null}, 
            {"Custattendancerequired", null}, 
            {"FieldValuesAsText.Staff_x0020_Name", null}
            }
        ), 
        #"Changed column type 2" = Table.TransformColumnTypes(
            #"Replace errors 2", 
            {{"Ticket Age", type text}, {"Days", type text}}
        ), 
        #"Transform columns 4" = Table.TransformColumnTypes(
            #"Changed column type 2", 
            {{"Sign-off status", type text}, {"OData__ColorTag", type text}}
        ), 
        #"Replace errors 3" = Table.ReplaceErrorValues(
            #"Transform columns 4", 
            {{"Sign-off status", null}, {"OData__ColorTag", null}}
        )
    in
        #"Replace errors 3"
        
//
