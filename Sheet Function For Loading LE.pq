// Ops Expense Apr LE

// Sheet Template

let
    Source = Excel.Workbook(File.Contents("M:\Budget & LE's\8. LE 2022 April (9+3)\April LE Cost Centre Expenses.xlsm"), null, true),
    q_Administration_Sheet = Source{[Item="q_Administration",Kind="Sheet"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(q_Administration_Sheet,{"Column2", "Column4", "Column5", "Column6", "Column7", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25"}),
    #"Removed Top Rows" = Table.Skip(#"Removed Other Columns",9),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Filtered Rows" = Table.SelectRows(#"Promoted Headers", each ([Category] <> null)),
    #"Unpivoted Columns" = Table.UnpivotOtherColumns(#"Filtered Rows", {"CC", "Group", "Category", "Channel", "Brand"}, "Attribute", "Value"),
    #"Changed Type" = Table.TransformColumnTypes(#"Unpivoted Columns",{{"CC", type text}, {"Group", type text}, {"Category", type text}, {"Channel", type text}, {"Brand", type text}, {"Attribute", type date}, {"Value", type number}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","*","",Replacer.ReplaceText,{"Channel", "Brand"})
in
    #"Replaced Value"


// Sheet Function

(Sheet)=>

let
    #"Removed Other Columns" = Table.SelectColumns(Sheet,{"Column2", "Column4", "Column5", "Column6", "Column7", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25"}),
    #"Removed Top Rows" = Table.Skip(#"Removed Other Columns",9),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Filtered Rows" = Table.SelectRows(#"Promoted Headers", each ([Category] <> null)),
    #"Unpivoted Columns" = Table.UnpivotOtherColumns(#"Filtered Rows", {"CC", "Group", "Category", "Channel", "Brand"}, "Attribute", "Value"),
    #"Changed Type" = Table.TransformColumnTypes(#"Unpivoted Columns",{{"CC", type text}, {"Group", type text}, {"Category", type text}, {"Channel", type text}, {"Brand", type text}, {"Attribute", type date}, {"Value", type number}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","*","",Replacer.ReplaceText,{"Channel", "Brand"})
in
    #"Replaced Value"


// Apr LE CC Expenses

let
    Source = Excel.Workbook(File.Contents("M:\Budget & LE's\8. LE 2022 April (9+3)\April LE Cost Centre Expenses.xlsm"), null, true),
    #"Filtered Rows" = Table.SelectRows(Source, each Text.StartsWith([Name], "q_")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows",{"Data"}),
    #"Invoked Custom Function" = Table.AddColumn(#"Removed Other Columns", "Sheet Function", each #"Sheet Function"([Data])),
    #"Removed Columns" = Table.RemoveColumns(#"Invoked Custom Function",{"Data"}),
    #"Expanded Sheet Function" = Table.ExpandTableColumn(#"Removed Columns", "Sheet Function", {"CC", "Group", "Category", "Channel", "Brand", "Attribute", "Value"}, {"CC", "Group", "Category", "Channel", "Brand", "Attribute", "Value"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Sheet Function",{{"CC", type text}, {"Group", type text}, {"Category", type text}, {"Channel", type text}, {"Brand", type text}, {"Attribute", type date}, {"Value", type number}})
in
    #"Changed Type"
