let
    Source = Excel.Workbook(File.Contents("M:\Finance\Rebates\7 Eleven Posting.xlsx"), null, true),
    FilterRows = Table.SelectRows(Source, each ([Name] = "Data")),
    RemoveOtherColumns = Table.SelectColumns(FilterRows,{"Data"}),
    ExpandData = Table.ExpandTableColumn(RemoveOtherColumns, "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19"}),
    FilterRows1 = Table.SelectRows(ExpandData, each ([Column3] <> null)),
    PromoteHeaders = Table.PromoteHeaders(FilterRows1, [PromoteAllScalars=true]),
    RemoveOtherColumns1 = Table.SelectColumns(PromoteHeaders,{"Invoice Date", "Article Number", "Article Description", "Invoice Amount", "Deal", "Claim", "Settl.Month"}),
    ChangeType = Table.TransformColumnTypes(RemoveOtherColumns1,{{"Invoice Date", type date}, {"Article Number", type text}, {"Article Description", type text}, {"Invoice Amount", type number}, {"Deal", type number}, {"Claim", type number}, {"Settl.Month", Int64.Type}}),
    SplitColumnByDelimiter = Table.SplitColumn(ChangeType, "Article Description", Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, false), {"Article Description.1", "Article Description.2"}),
    CalculateStartOfMonth = Table.TransformColumns(SplitColumnByDelimiter,{{"Invoice Date", Date.StartOfMonth, type date}}),
    GroupRows = Table.Group(CalculateStartOfMonth, {"Invoice Date", "Article Description.1"}, {{"Invoice Amount", each List.Sum([Invoice Amount]), type nullable number}, {"Claim", each List.Sum([Claim]), type nullable number}}),
    FilterRows2 = Table.SelectRows(GroupRows, each ([Invoice Amount] <> 0)),
    AddCustom = Table.AddColumn(FilterRows2, "Claim %", each [Claim] / [Invoice Amount] , Number.Type),
    SortRows = Table.Sort(AddCustom,{{"Invoice Date", Order.Ascending}}),
    ReplaceValue = Table.ReplaceValue(SortRows,"-"," ",Replacer.ReplaceText,{"Article Description.1"}),
    MergeQueries = Table.NestedJoin(ReplaceValue, {"Article Description.1"}, #"GL Groups", {"Brand"}, "GL Groups", JoinKind.LeftOuter),
    ExpandGlGroups = Table.ExpandTableColumn(MergeQueries, "GL Groups", {"GL", "CC"}, {"GL", "CC"}),
    AddGlDebit = Table.AddColumn(ExpandGlGroups, "Debit", each Number.Round ([Claim] , 2) , Number.Type),
    
    // Define GrandTotalRow as a table
    DebitList = AddGlDebit[Debit],
    GrandTotalRow = #table(type table [Credit=Number.Type, GL=Text.Type], {{List.Sum(DebitList) , "00810" }}),

    // Append GrandTotalRow to the AddCustom1 table
    AppendGrandTotal = Table.Combine({AddGlDebit, GrandTotalRow}),
    AddReferenceColumn = Table.AddColumn(
    AppendGrandTotal , 
    "Reference",
        each

        if
            [Invoice Date] = null
        then
            "7-Eleven Stores"
        else
            "7-Eleven Rebate " & Date.ToText([Invoice Date] , "MMM-yyyy" )

    , Text.Type
)
in
    AddReferenceColumn