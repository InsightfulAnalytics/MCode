
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