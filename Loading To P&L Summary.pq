// Loading from "P&L Loading" file to P&L Summary - A&P

let
    Source = Excel.Workbook(File.Contents("M:\Finance\Reporting\Custom\Linked Files\P&L Loading.xlsx"), null, true),
    Fy23_LE_A_P_Table = Source{[Item="Fy23_LE_A_P",Kind="Table"]}[Data],
    ChangeType = Table.TransformColumnTypes(Fy23_LE_A_P_Table,{{"Group", type text}, {"Category", type text}, {"Channel", type text}, {"Brand", type text}, {"Amount", type number}, {"Month", Int64.Type}, {"Year", Int64.Type}, {"Financial Year", Int64.Type}, {"Period", Int64.Type}} ),
    FilterRows = Table.SelectRows( ChangeType , each ([Group] <> "Operating Expenses")),
    MergeQueryRSGroup = Table.NestedJoin(FilterRows, {"Group", "Category"}, #"RS Group List", {"Group", "Category"}, "RS Group List", JoinKind.LeftOuter),
    ExpandRSGroupList = Table.ExpandTableColumn( MergeQueryRSGroup , "RS Group List", {"RS Group"}, {"RS Group"}),
    TypeColumn = 
        Table.AddColumn(
            ExpandRSGroupList, 
            "Type", 
            each "Nov LE",
            Text.Type
        )
    
in
    TypeColumn