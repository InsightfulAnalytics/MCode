//

= Table.AddColumn(
    KeepOnlyDataColumns, 
    "FilterNulls",
        each
            Table.SelectRows(
                [Data],
                each
                    [Column3] <> null
            )
)

/////

= Table.PromoteHeaders(Custom1, [PromoteAllScalars=true])

///

= Table.AddColumn(
    nt_FilterOutNull, 
    "PromoteHeaders",
        each
            Table.PromoteHeaders(
                [FilterNulls],
                [PromoteAllScalars=true]
            )
)

///

= Table.AddColumn(
    nt_PromoteHeaders, 
    "DeleteColumns",
        each
            Table.RemoveColumns(
                [PromoteHeaders],
                {"Column1" , "Comments"} 
            )
)

//

=  Table.RenameColumns( 
      FilterRows,
      {
          { Table.ColumnNames( FilterRows ) {0} ,"Condition Contract" },

///

= Table.AddColumn(
    nt_DeleteColumns, 
    "RenameColumn",
        each
            Table.RenameColumns( 
                [DeleteColumns] ,
                {
                    { Table.ColumnNames( [DeleteColumns] ) {0} ,"SKU" }
                }
            )
)

/////


= Table.AddColumn(
    AddTableColumn, 
    "PromoteHeaders",
        each
            Table.PromoteHeaders(
                [AddTableColumn],
                [PromoteAllScalars=true]
            )
)
/////////////////// Me

let
    Source = SharePoint.Files("https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/", [ApiVersion = 15]),
    FilterLogFilesOnly = Table.SelectRows(Source, each ([Folder Path] = "https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/Shared Documents/PbiLogs/")),
    KeepContentColumnOnly = Table.SelectColumns(FilterLogFilesOnly,{"Content"}),
    AddTableColumn = Table.AddColumn(KeepContentColumnOnly, "Custom", each Csv.Document([Content])),
    Custom1 = Table.AddColumn(
    AddTableColumn, 
    "PromoteHeaders",
        each
            Table.PromoteHeaders(
                [AddTableColumn],
                [PromoteAllScalars=true]
            )
)
in
    Custom1

//////////////////// GPT

let
    Source = SharePoint.Files("https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/", [ApiVersion = 15]),
    FilterLogFilesOnly = Table.SelectRows(Source, each ([Folder Path] = "https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/Shared Documents/PbiLogs/")),
    KeepContentColumnOnly = Table.SelectColumns(FilterLogFilesOnly,{"Content"}),
    AddTableColumn = Table.AddColumn(KeepContentColumnOnly, "Custom", each Csv.Document([Content])),
    Custom1 = 
    
    Table.AddColumn(
        AddTableColumn, 
        "PromoteHeaders",
        each Table.PromoteHeaders(
            [Custom],  // Use the "Custom" column here
            [PromoteAllScalars=true]
        )
    )
in
    Custom1




