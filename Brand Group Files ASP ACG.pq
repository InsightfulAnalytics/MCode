
// Brand Group Files ASP ACG

let
    Source = Folder.Files(BrandGroupFilesFolder),
    ReplaceValue = Table.ReplaceValue(Source,".xlsm","",Replacer.ReplaceText,{"Name"}),
    FilterOutTempFiles = Table.SelectRows(ReplaceValue, each not Text.Contains([Name], "~$")),
    FilterOutNonXlsmFiles = Table.SelectRows(FilterOutTempFiles, each ([Extension] = ".xlsm")),
    ContentOnlyColumn = Table.SelectColumns(FilterOutNonXlsmFiles,{"Content"}),
    InvokeFunction = Table.AddColumn(ContentOnlyColumn, "Budget Model Function", each #"Budget Model Function"([Content])),
    TableOnlyColumn = Table.SelectColumns(InvokeFunction,{"Budget Model Function"}),
    ExpandFileTables = Table.ExpandTableColumn(TableOnlyColumn, "Budget Model Function", {"Channel", "Brand", "SKU", "Description", "Attribute", "Financial Year", "Jun", "May", "Apr", "Mar", "Feb", "Jan", "Dec", "Nov", "Oct", "Sep", "Aug", "Jul"}, {"Channel", "Brand", "SKU", "Description", "Attribute", "Financial Year", "Jun", "May", "Apr", "Mar", "Feb", "Jan", "Dec", "Nov", "Oct", "Sep", "Aug", "Jul"}),
    UnpivotMonths = Table.UnpivotOtherColumns(ExpandFileTables, {"Channel", "Brand", "SKU", "Description"  ,"Attribute", "Financial Year"}, "Attribute.1", "Value"),
    DataTypes = Table.TransformColumnTypes(UnpivotMonths,{{"Channel", type text}, {"Brand", type text}, {"Description" , type text } , {"SKU", Text.Type}, {"Attribute", type text}, {"Financial Year", Int64.Type}, {"Attribute.1", type text}, {"Value", Number.Type}}),
    FilterOutAspAcg = Table.SelectRows(DataTypes, each ([Attribute] <> "2 ASP" and [Attribute] <> "3 ACG")),
    PivotQtySalesCost = Table.Pivot(FilterOutAspAcg, List.Distinct(FilterOutAspAcg[Attribute]), "Attribute", "Value"),
    MonthColumn = Table.AddColumn(PivotQtySalesCost, "Month", each if [Attribute.1] = "Jul" then 7 else if [Attribute.1] = "Aug" then 8 else if [Attribute.1] = "Sep" then 9 else if [Attribute.1] = "Oct" then 10 else if [Attribute.1] = "Nov" then 11 else if [Attribute.1] = "Dec" then 12 else if [Attribute.1] = "Jan" then 1 else if [Attribute.1] = "Feb" then 2 else if [Attribute.1] = "Mar" then 3 else if [Attribute.1] = "Apr" then 4 else if [Attribute.1] = "May" then 5 else if [Attribute.1] = "Jun" then 6 else 13, Number.Type )
    
    ,YearColumn = 
        Table.AddColumn(
            MonthColumn, 
            "Year", 
            each
                //
                
                if
                    [Month] > 6 
                then
                    [Financial Year] - 1
                else
                    [Financial Year]
                
                //
            , Number.Type
        )
    ,DateColumn = 
        Table.AddColumn(
            YearColumn, 
            "Date", 
            each
                //
            
                #date(
                    [Year],
                    [Month],
                    1
                )

                //
            , Date.Type
        )
        ,YYYYMMColumn = 
            Table.AddColumn(
                DateColumn, 
                "YYYYMM", 
                each
                    //
                    
                    if
                        [Month] < 10
                    then
                        Number.ToText([Year]) & "0" & Number.ToText([Month]) 
                    else
                        Number.ToText([Year])  & Number.ToText([Month]) 
                    
                    //
            , Number.Type
        ),
    RemoveDateBuildColumns = Table.RemoveColumns(YYYYMMColumn,{"Financial Year", "Attribute.1", "Month", "Year"}),
    FilterOutZeroQty = Table.SelectRows(RemoveDateBuildColumns, each [1 Qty] > 0),
    FilterDatesForLast12Months = Table.SelectRows(FilterOutZeroQty, each [Date] > DateOneYearAgo),
    GroupSalesQtyCost = Table.Group(FilterDatesForLast12Months, {"Channel", "Brand", "SKU"}, {{"Qty", each List.Sum([1 Qty]), type nullable number}, {"Sales", each List.Sum([4 Sales]), type nullable number}, {"Cost", each List.Sum([5 Cost]), type nullable number}}),
    ASPColumn = Table.AddColumn(
    GroupSalesQtyCost,
    "ASP", 
    each
    (
    if 		
        (try [Sales] / [Qty]) [HasError] 
    then
        0 
    else
        if 
            [Sales] / [Qty] = null 
        then 
            0 
        else 
            if 
                [Sales] / [Qty] = Number.PositiveInfinity 
            then 
                0 
            else 
                if 
                    [Sales] / [Qty] = Number.NegativeInfinity 
                then 
                    0 
                else 
                    if 
                        Number.IsNaN ([Sales] / [Qty] ) 
                    then 
                        0 
                    else
                        if 		
                            (try [Sales] / [Qty]) [HasError] 
                        then
                            0 
                        else 	
                            [Sales] / [Qty]
        ), 
    Number.Type
),
    ACGColumn = Table.AddColumn(
    ASPColumn,
    "ACG", 
    each
    (
    if 		
        (try [Cost] / [Qty]) [HasError] 
    then
        0 
    else
        if 
            [Cost] / [Qty] = null 
        then 
            0 
        else 
            if 
                [Cost] / [Qty] = Number.PositiveInfinity 
            then 
                0 
            else 
                if 
                    [Cost] / [Qty] = Number.NegativeInfinity 
                then 
                    0 
                else 
                    if 
                        Number.IsNaN ([Cost] / [Qty] ) 
                    then 
                        0 
                    else
                        if 		
                            (try [Cost] / [Qty]) [HasError] 
                        then
                            0 
                        else 	
                            [Cost] / [Qty]
        ), 
    Number.Type
)
in
    ACGColumn