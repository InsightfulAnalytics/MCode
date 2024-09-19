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
    KeepOnlyDataColumn, 
    "RenameColumn",
        each
            Table.PromoteHeaders( [Data], [PromoteAllScalars = true])
)

/////

= Table.AddColumn(
    NestedTablePromoteHeaders, 
    "RenameColumn",
        each
            Table.AddColumn([Data], "Custom", each [Item])
)

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

/////////////

let
    Source = #"User Logs",
    GroupRows = Table.Group(Source, {"UserKey", "UserId"}, {{"Count", each Table.RowCount(_), Int64.Type}}),
    RemoveColumns = Table.RemoveColumns(GroupRows,{"Count"}),
    NameFromEmailColumn = Table.AddColumn(
            RemoveColumns, 
            "User Name", 
            each 
                Text.Upper(
                        Text.Start(Text.BeforeDelimiter([UserId], "@"), 1)) & " " & 
                        Text.Middle(Text.BeforeDelimiter([UserId], "@"), 1, 
                        Text.Length(Text.BeforeDelimiter([UserId], "@")) - 1)
        , Text.Type),
    RenameColumn = Table.RenameColumns(NameFromEmailColumn,{{"UserId", "User Email"}})
in
    RenameColumn

////////////////










Table.AddColumn(NestedTablePromoteHeaders, "Custom", each [Item])


//////////


let
  Source = SharePoint.Files("https://acurioservices.sharepoint.com/sites/ITS", [ApiVersion = 15]),
  BudgetFile = Table.SelectRows(Source, each ([Name] = BudgetFileName )),
  DrillDown = BudgetFile{0}[Content],
  ImportExcelWorkbook = Excel.Workbook(DrillDown, null, true),
  KeepOnlyDataColumn = Table.SelectColumns(ImportExcelWorkbook, {"Data", "Item" }),
  NestedTablePromoteHeaders =  Table.AddColumn(
    KeepOnlyDataColumn, 
    "PromoteHeaders",
        each
            Table.PromoteHeaders( [Data], [PromoteAllScalars = true])
),
  NestedTableAddItemColumn =  Table.AddColumn(
    NestedTablePromoteHeaders, 
    "RenameColumn",
        each
            Table.AddColumn([Data], "Custom", each [Item])
)
,
  ExpandTables = Table.Combine(NestedTableAddItemColumn[PromoteHeaders]),
  UnpivotDatesValues = Table.UnpivotOtherColumns(ExpandTables, {"CostCentre", "Type", "Specialization"}, "Attribute", "Value"),
  ChangeColumnTypes = Table.TransformColumnTypes(UnpivotDatesValues, {{"CostCentre", type text}, {"Type", type text}, {"Specialization", type text}, {"Attribute", type date}, {"Value", type number}})
in
  ChangeColumnTypes


