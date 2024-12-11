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


/////////////////

//Expand sharepoint records in a folder with nested table transformations

    let
        Source = SharePoint.Files("https://acurioservices.sharepoint.com/sites/ITS", [ApiVersion = 15]),
        FilterRowsDirectory = Table.SelectRows(Source, each Text.Contains([Folder Path], "https://acurioservices.sharepoint.com/sites/ITS/Shared Documents/Acurio/Analysis/Data/HumanResources/EmployeeCostsData/")),
        KeepOnlyContent = Table.SelectColumns(FilterRowsDirectory, {"Content"}),
        ExpandBinaryContent = Table.AddColumn(KeepOnlyContent, "Convert", each Excel.Workbook([Content])),
        
        // Filter each table within the Convert column to keep only rows where Kind is "Sheet"
        NestedTableAddColumn =  
            Table.AddColumn(
                ExpandBinaryContent, 
                "RenameColumn",
                    each
                        Table.SelectRows( [Convert], each [Kind] = "Sheet")
            ),
        ExpandTables = 
            Table.Combine(
                NestedTableAddColumn[RenameColumn]
            ),
        RemoveFirstRow =
            Table.AddColumn(
                ExpandTables,
                "RemoveRow",
                each
                    Table.RemoveRows( [Data], 0 )
            ),
        PromoteHeaders =
            Table.AddColumn(
                RemoveFirstRow,
                "PromoteHeader",
                each
                    Table.PromoteHeaders( [RemoveRow], [PromoteAllScalars = true])
            ),
        ExpandData = 
            Table.Combine(
                PromoteHeaders[PromoteHeader]
            )
    in
        ExpandTables

////////////////////

// nested transformations, sharepoint files in folder

    let
        // Access the SharePoint folder containing the files
        Source = SharePoint.Files(
            "https://acurioservices.sharepoint.com/sites/ITS",
            [ApiVersion = 15]
        ),

        // Filter the files to include only those in the specified directory
        FilterRowsDirectory = Table.SelectRows(
            Source,
            each Text.Contains(
                [Folder Path],
                "https://acurioservices.sharepoint.com/sites/ITS/Shared Documents/Acurio/Analysis/Data/HumanResources/EmployeeCostsData/"
            )
        ),

        // Keep only the 'Content' column (binary data of files)
        KeepOnlyContent = Table.SelectColumns(
            FilterRowsDirectory,
            {"Content"}
        ),

        // Convert binary content to Excel workbooks
        ExpandBinaryContent = Table.AddColumn(
            KeepOnlyContent,
            "Convert",
            each Excel.Workbook([Content])
        ),

        // Filter each workbook to keep only sheets (where Kind is "Sheet")
        NestedTableAddColumn = Table.AddColumn(
            ExpandBinaryContent,
            "RenameColumn",
            each Table.SelectRows(
                [Convert],
                each [Kind] = "Sheet"
            )
        ),

        // Combine all sheets into one table
        ExpandTables = Table.Combine(
            NestedTableAddColumn[RenameColumn]
        ),

        // Remove the first row if the first cell is null
        RemoveFirstRow = Table.AddColumn(
            ExpandTables,
            "RemoveRow",
            each if Table.IsEmpty([Data]) then
                [Data]
            else
                let
                    FirstRow = [Data]{0},
                    FirstColumnName = Table.ColumnNames([Data]){0},
                    FirstValue = Record.Field(
                        FirstRow,
                        FirstColumnName
                    )
                in
                    if FirstValue = null then
                        Table.Skip([Data], 1)
                    else
                        [Data]
        ),

        // Promote the first row to headers
        PromoteHeaders = Table.AddColumn(
            RemoveFirstRow,
            "PromoteHeader",
            each Table.PromoteHeaders(
                [RemoveRow],
                [PromoteAllScalars = true]
            )
        ),

        // Keep only the table with promoted headers
        KeepOnlyTables = Table.SelectColumns(
            PromoteHeaders,
            {"PromoteHeader"}
        ),

        // Compute the list of all column names across all tables
        AllColumnNames = List.Union(
            List.Transform(
                KeepOnlyTables[PromoteHeader],
                each Table.ColumnNames(_)
            )
        ),

        // Remove any column names that contain "Column" (default names from missing headers)
        FilteredColumnNames = List.RemoveMatchingItems(
            AllColumnNames,
            List.Select(
                AllColumnNames,
                each Text.Contains(_, "Column")
            )
        ),

        // Filter the column names to only include those in ColumnsToKeepList
        FieldNames = List.Buffer(
            List.Intersect({
                FilteredColumnNames,
                ColumnsToKeepList
            })
        ),

        // Expand the tables using the filtered FieldNames
        ExpandData = Table.ExpandTableColumn(
            KeepOnlyTables,
            "PromoteHeader",
            FieldNames
        ),
    ChangeColumnType = Table.TransformColumnTypes(ExpandData, ColumnsToKeepDataTypesList )
    in
        ChangeColumnType

/////////////////


let
    Source = Excel.Workbook(File.Contents("B:\IT & Data\Power BI\Acurio\Working Excel\Profit and LossTGC 12Mth Trend FY 2024.xlsx"), null, true),
    FilterRows = Table.SelectRows(Source, each ([Kind] = "Sheet")),
    SplitCC = Table.SplitColumn(FilterRows, "Item", Splitter.SplitTextByDelimiter("-", QuoteStyle.Csv), {"Item.1", "Item.2"}),
    NestedTableRemoveRows = Table.TransformColumns(
        SplitCC,
        {"Data", each Table.Skip(_, 4)}
    ),
    AddCostCentre = Table.AddColumn(
        NestedTableRemoveRows,
        "Data1",
        (outerRow) => Table.AddColumn(
            outerRow[Data],
            "CostCentre",
            each outerRow[Item.1]
        )
    ),
    NestedPromoteHeaders = Table.AddColumn(
        AddCostCentre, 
        "PromoteHeaders",
            each
                Table.PromoteHeaders(
                    [Data1],
                    [PromoteAllScalars=true]
                )
    )
in
    AddCostCentre






/////////////////