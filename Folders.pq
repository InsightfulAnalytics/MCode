
/*  Expand folder files without helper queries */

    // binary files (json format)
    let
        // Source folder
        Source = Folder.Files("C:\Users\v-tosborn\OneDrive - Microsoft\Power BI\Data Files\Activity Events"),
        //Retain only Content column
        RemoveOtherColumns = Table.SelectColumns(Source,{"Content"}),
        // Add a custom column that converts each binary (JSON) to a table
        AddCustom = Table.AddColumn( RemoveOtherColumns , "Converted", each Json.Document([Content])),
        // Expand the JSON document to new rows
        ExpandListToColumn = Table.ExpandListColumn( AddCustom, "Converted"),
        // Expand the records in the new rows to new columns
        ExpandRecords = Table.ExpandRecordColumn(ExpandListToColumn, "Converted", Record.FieldNames(ExpandListToColumn[Converted]{0})),
        // Remove Content column
        RemoveConentColumn = Table.RemoveColumns(ExpandRecords,{"Content"})
    in
        RemoveConentColumn

//

    //Excel files

    let
        Source = AzureStorage.Blobs("https://timblob.blob.core.windows.net/thetimcontainer/"),
        //Retain only Content column
        RemoveOtherColumns = Table.SelectColumns(Source,{"Content"}),
        // Add a custom column that converts each binary (JSON) to a table
        AddCustom = Table.AddColumn( RemoveOtherColumns , "Converted", each Excel.Workbook([Content])),
        ExpandConverted = Table.ExpandTableColumn(AddCustom, "Converted", {"Name", "Data", "Item", "Kind", "Hidden"}, {"Name", "Data", "Item", "Kind", "Hidden"}),
        KeepOnlyTables = Table.SelectColumns(ExpandConverted,{"Data"}),
        ExpandData = Table.ExpandTableColumn(KeepOnlyTables, "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "OrderDate", "Region", "Rep", "Item", "Units", "Unit Cost", "Total", "things", "other", "and", "another", "and again", "a colunmn", "lots of", "Never", "another2", "one", "so ", "much", "data"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "OrderDate", "Region", "Rep", "Item", "Units", "Unit Cost", "Total", "things", "other", "and", "another", "and again", "a colunmn", "lots of", "Never", "another2", "one", "so ", "much", "data.1"}),
        PromoteHeaders = Table.PromoteHeaders(ExpandData, [PromoteAllScalars=true]),
        ChangeTypes = Table.TransformColumnTypes(PromoteHeaders,{{"OrderDate", type date}, {"Region", type text}, {"Rep", type text}, {"Item", type text}, {"Units", Int64.Type}, {"Unit Cost", type number}, {"Total", type number}, {"things", Int64.Type}, {"other", Int64.Type}, {"and", Int64.Type}, {"another", Int64.Type}, {"and again", Int64.Type}, {"a colunmn", Int64.Type}, {"lots of", Int64.Type}, {"Never", Int64.Type}, {"another2", Int64.Type}, {"one", Int64.Type}, {"so ", Int64.Type}, {"much", Int64.Type}, {"data", Int64.Type}, {"Column21", type any}, {"Column22", type any}, {"Column23", type any}, {"Column24", type any}, {"Column25", type any}, {"Column26", type any}, {"Column27", type any}, {"Column28", type any}, {"Column29", type any}, {"Column30", type any}, {"Column31", type any}, {"Column32", type any}, {"Column33", type any}, {"Column34", type any}, {"Column35", type any}, {"Column36", type any}, {"Column37", type any}, {"Column38", type any}, {"Column39", type any}, {"Column40", type any}}),
        KeepOnlyTableColumns = Table.SelectColumns(ChangeTypes,{"OrderDate", "Region", "Rep", "Item", "Units", "Unit Cost", "Total", "things", "other", "and", "another", "and again", "a colunmn", "lots of", "Never", "another2", "one", "so ", "much", "data"})
    in
        KeepOnlyTableColumns

///

