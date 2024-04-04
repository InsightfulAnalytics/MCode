
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

