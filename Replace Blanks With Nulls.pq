
    let
        ReplaceBlanksWithNulls = (inputTable as table) as table =>
            let
                columnNames = Table.ColumnNames(inputTable),
                replaceBlanksInColumn = (table, columnName) => Table.ReplaceValue(table, "", null, Replacer.ReplaceValue, {columnName}),
                transformedTable = List.Accumulate(columnNames, inputTable, (state, current) => replaceBlanksInColumn(state, current))
            in
                transformedTable
    in
        ReplaceBlanksWithNulls

/// even better do it for the whole table
    ReplaceBlankNull =
        Table.ReplaceValue(
            FactAdmissionListing_, 
            "", 
            null, 
            Replacer.ReplaceValue, 
            Table.ColumnNames(FactAdmissionListing_)
        )

    ReplaceZeroNull =
        Table.ReplaceValue(
            FactAdmissionListing_, 
            0, 
            null, 
            Replacer.ReplaceValue, 
            Table.ColumnNames(FactAdmissionListing_)
        )