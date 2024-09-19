// Errors Archieve
let
  Source = SharePoint.Tables("https://nswgov.sharepoint.com/sites/SDErrorManagement2.0", [Implementation = null, ApiVersion = 15]),
  #"Navigation 1" = Source{[Id = "0ae2c82b-d424-4f51-976f-70ada3fa349a"]}[Items],
  #"Transform columns" = Table.TransformColumnTypes(#"Navigation 1", {{"FileSystemObjectType", type text}, {"Id", type text}, {"ServerRedirectedEmbedUri", type text}, {"ServerRedirectedEmbedUrl", type text}, {"ContentTypeId", type text}, {"Title", type text}, {"Modified", type text}, {"Created", type text}, {"OData__ColorTag", type text}, {"ComplianceAssetId", type text}, {"Action Taken", type text}, {"Region", type text}, {"Outcome", type text}, {"Action Required", type text}, {"Date Error Received0", type text}, {"JobID", type text}, {"Issue description", type text}, {"Outcome comments", type text}, {"Rating", type text}, {"Priority", type text}, {"Customerimpact", type text}, {"ServiceNSWimpact", type text}, {"Resolutiontype", type text}, {"ErrorManagementType", type text}, {"ActionedById", type text}, {"ActionedByStringId", type text}, {"Issue Status", type text}, {"Verified", type text}, {"Location", type text}, {"Channel", type text}, {"Service type", type text}, {"AnyMissingFields", type text}, {"Reassign", type text}, {"ApprovalStatus", type text}, {"RejectionReason", type text}, {"Reopen", type text}, {"PartnerAgencyError", type text}, {"UrgentEmailSent", type text}, {"FollowUpCount", type text}, {"Issue Type", type text}, {"Partner agency", type text}, {"ReOpenComments", type text}, {"CustomerName", type text}, {"ReferenceNumber", type text}, {"StaffLogin", type text}, {"Dateofoccurrence", type text}, {"privacybreach", type text}, {"SHIFTError", type text}, {"AssignedToId", type text}, {"AssignedToStringId", type text}, {"OverdueDays", type text}, {"DueDate", type text}, {"Team member name", type text}, {"Reassign Reason", type text}, {"Messages", type text}, {"Business Unit", type text}, {"OverDueDays0", type text}, {"Issue categories", type text}, {"Related links", type text}, {"Information Compromised", type text}, {"Number of customers", type text}, {"Exposed to", type text}, {"Has the information_", type text}, {"Additional Comments ", type text}, {"ID", type text}, {"AuthorId", type text}, {"EditorId", type text}, {"OData__UIVersionString", type text}, {"Attachments", type text}, {"GUID", type text}}),
  #"Replace errors" = Table.ReplaceErrorValues(#"Transform columns", {{"FileSystemObjectType", null}, {"Id", null}, {"ServerRedirectedEmbedUri", null}, {"ServerRedirectedEmbedUrl", null}, {"ContentTypeId", null}, {"Title", null}, {"Modified", null}, {"Created", null}, {"OData__ColorTag", null}, {"ComplianceAssetId", null}, {"Action Taken", null}, {"Region", null}, {"Outcome", null}, {"Action Required", null}, {"Date Error Received0", null}, {"JobID", null}, {"Issue description", null}, {"Outcome comments", null}, {"Rating", null}, {"Priority", null}, {"Customerimpact", null}, {"ServiceNSWimpact", null}, {"Resolutiontype", null}, {"ErrorManagementType", null}, {"ActionedById", null}, {"ActionedByStringId", null}, {"Issue Status", null}, {"Verified", null}, {"Location", null}, {"Channel", null}, {"Service type", null}, {"AnyMissingFields", null}, {"Reassign", null}, {"ApprovalStatus", null}, {"RejectionReason", null}, {"Reopen", null}, {"PartnerAgencyError", null}, {"UrgentEmailSent", null}, {"FollowUpCount", null}, {"Issue Type", null}, {"Partner agency", null}, {"ReOpenComments", null}, {"CustomerName", null}, {"ReferenceNumber", null}, {"StaffLogin", null}, {"Dateofoccurrence", null}, {"privacybreach", null}, {"SHIFTError", null}, {"AssignedToId", null}, {"AssignedToStringId", null}, {"OverdueDays", null}, {"DueDate", null}, {"Team member name", null}, {"Reassign Reason", null}, {"Messages", null}, {"Business Unit", null}, {"OverDueDays0", null}, {"Issue categories", null}, {"Related links", null}, {"Information Compromised", null}, {"Number of customers", null}, {"Exposed to", null}, {"Has the information_", null}, {"Additional Comments ", null}, {"ID", null}, {"AuthorId", null}, {"EditorId", null}, {"OData__UIVersionString", null}, {"Attachments", null}, {"GUID", null}}),
  #"Remove columns" = Table.RemoveColumns(#"Replace errors", Table.ColumnsOfType(#"Replace errors", {type table, type record, type list, type nullable binary, type binary, type function})),
  #"Renamed columns" = Table.RenameColumns(#"Remove columns", {{"Additional Comments ", "Additional Comments"}, {"ID", "ID 1"}})
in
  #"Renamed columns"


/////////////////////////////////

// Errors Archieve

let
  Source = SharePoint.Tables(
    "https://nswgov.sharepoint.com/sites/SDErrorManagement2.0",
    [Implementation = null, ApiVersion = 15]
  ),
  #"Navigation 1" = Source{[Id = "0ae2c82b-d424-4f51-976f-70ada3fa349a"]}[Items],
  #"Transform columns" = Table.TransformColumnTypes(
    #"Navigation 1",
    {
      {"FileSystemObjectType", type text},
      {"Id", type text},
      {"ServerRedirectedEmbedUri", type text},
      {"ServerRedirectedEmbedUrl", type text},
      {"ContentTypeId", type text},
      {"Title", type text},
      {"Modified", type text},
      {"Created", type text},
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
      {"ApprovalStatus", type text},
      {"RejectionReason", type text},
      {"Reopen", type text},
      {"PartnerAgencyError", type text},
      {"UrgentEmailSent", type text},
      {"FollowUpCount", type text},
      {"Issue Type", type text},
      {"Partner agency", type text},
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
      {"Team member name", type text},
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
      {"Additional Comments ", type text},
      {"ID", type text},
      {"AuthorId", type text},
      {"EditorId", type text},
      {"OData__UIVersionString", type text},
      {"Attachments", type text},
      {"GUID", type text}
    }
  ),
  #"Replace errors" = Table.ReplaceErrorValues(
    #"Transform columns",
    {
      {"FileSystemObjectType", null},
      {"Id", null},
      {"ServerRedirectedEmbedUri", null},
      {"ServerRedirectedEmbedUrl", null},
      {"ContentTypeId", null},
      {"Title", null},
      {"Modified", null},
      {"Created", null},
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
      {"ApprovalStatus", null},
      {"RejectionReason", null},
      {"Reopen", null},
      {"PartnerAgencyError", null},
      {"UrgentEmailSent", null},
      {"FollowUpCount", null},
      {"Issue Type", null},
      {"Partner agency", null},
      {"ReOpenComments", null},
      {"CustomerName", null},
      {"ReferenceNumber", null},
      {"StaffLogin", null},
      {"Dateofoccurrence", null},
      {"privacybreach", null},
      {"SHIFTError", null},
      {"AssignedToId", null},
      {"AssignedToStringId", null},
      {"OverdueDays", null},
      {"DueDate", null},
      {"Team member name", null},
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
      {"Additional Comments ", null},
      {"ID", null},
      {"AuthorId", null},
      {"EditorId", null},
      {"OData__UIVersionString", null},
      {"Attachments", null},
      {"GUID", null}
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
    {{"Additional Comments ", "Additional Comments"}, {"ID", "ID 1"}}
  )
in
  #"Renamed columns"

////////////

//Errors

let
  Source = SharePoint.Tables(
    "https://nswgov.sharepoint.com/sites/SDErrorManagement2.0",
    [Implementation = null, ApiVersion = 15]
  ),
  Navigation = Source{[Id = "846c7b70-9c99-4e42-9908-54aeed296ed0"]}[Items],
  #"Transform columns" = Table.TransformColumnTypes(
    Navigation,
    {
      {"FileSystemObjectType", type text},
      {"Id", type text},
      {"ServerRedirectedEmbedUri", type text},
      {"ServerRedirectedEmbedUrl", type text},
      {"ID", type text},
      {"ContentTypeId", type text},
      {"Title", type text},
      {"Modified", type text},
      {"Created", type text},
      {"AuthorId", type text},
      {"EditorId", type text},
      {"OData__UIVersionString", type text},
      {"Attachments", type text},
      {"GUID", type text},
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
      {"OverdueDays", type text},
      {"StaffName", type text},
      {"ApprovalStatus", type text},
      {"RejectionReason", type text},
      {"Reopen", type text},
      {"PartnerAgencyError", type text},
      {"UrgentEmailSent", type text},
      {"FollowUpCount", type text},
      {"Issue Type", type text},
      {"Partner agency", type text},
      {"ReOpenComments", type text},
      {"CustomerName", type text},
      {"ReferenceNumber", type text},
      {"StaffLogin", type text},
      {"Dateofoccurrence", type text},
      {"DueDate", type text},
      {"privacybreach", type text},
      {"SHIFTError", type text},
      {"OData__ColorTag", type text},
      {"AssignedToId", type text},
      {"AssignedToStringId", type text},
      {"ReAssignReason", type text},
      {"Messages", type text},
      {"BusinessUnit", type text},
      {"DueDays", type text},
      {"Issuecategories", type text},
      {"Relatedlinks", type text},
      {"InformationCompromised", type text},
      {"Numberofcustomers", type text},
      {"Exposedto", type text},
      {"Hastheinformationbeenrecoveredor", type text},
      {"AdditionalCommentsHastheinformat", type text}
    }
  ),
  #"Replace errors" = Table.ReplaceErrorValues(
    #"Transform columns",
    {
      {"FileSystemObjectType", null},
      {"Id", null},
      {"ServerRedirectedEmbedUri", null},
      {"ServerRedirectedEmbedUrl", null},
      {"ID", null},
      {"ContentTypeId", null},
      {"Title", null},
      {"Modified", null},
      {"Created", null},
      {"AuthorId", null},
      {"EditorId", null},
      {"OData__UIVersionString", null},
      {"Attachments", null},
      {"GUID", null},
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
      {"OverdueDays", null},
      {"StaffName", null},
      {"ApprovalStatus", null},
      {"RejectionReason", null},
      {"Reopen", null},
      {"PartnerAgencyError", null},
      {"UrgentEmailSent", null},
      {"FollowUpCount", null},
      {"Issue Type", null},
      {"Partner agency", null},
      {"ReOpenComments", null},
      {"CustomerName", null},
      {"ReferenceNumber", null},
      {"StaffLogin", null},
      {"Dateofoccurrence", null},
      {"DueDate", null},
      {"privacybreach", null},
      {"SHIFTError", null},
      {"OData__ColorTag", null},
      {"AssignedToId", null},
      {"AssignedToStringId", null},
      {"ReAssignReason", null},
      {"Messages", null},
      {"BusinessUnit", null},
      {"DueDays", null},
      {"Issuecategories", null},
      {"Relatedlinks", null},
      {"InformationCompromised", null},
      {"Numberofcustomers", null},
      {"Exposedto", null},
      {"Hastheinformationbeenrecoveredor", null},
      {"AdditionalCommentsHastheinformat", null}
    }
  ),
  #"Remove columns" = Table.RemoveColumns(
    #"Replace errors",
    Table.ColumnsOfType(
      #"Replace errors",
      {type table, type record, type list, type nullable binary, type binary, type function}
    )
  ),
  #"Renamed columns" = Table.RenameColumns(#"Remove columns", {{"ID", "ID 1"}})
in
  #"Renamed columns"


//////

let
  Source = CommonDataService.Database("orgfd335678.crm6.dynamics.com", [CreateNavigationProperties = null]),
  Navigation = Source{[Schema = "dbo", Item = "cr787_auditlog"]}[Data],
  #"Remove columns" = Table.RemoveColumns(Navigation, Table.ColumnsOfType(Navigation, {type table, type record, type list, type nullable binary, type binary, type function}))
in
  #"Remove columns"

///

//

Data source error: The 'StaffNumber' column does not exist in the rowset. Table: Errors Archive.
Cluster URI: WABI-AUSTRALIA-SOUTHEAST-redirect.analysis.windows.net
Activity ID: 030e0df6-d84f-4f3d-90c6-fa5c22c3278c
Request ID: 82a9a041-5f06-440e-a057-aca2deb69624
Time: 2024-04-10 20:05:46Z

///Team Member Name








///