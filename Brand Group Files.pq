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
            , Int64.Type
        ),
    YYYYMMColumnDateType = Table.TransformColumnTypes(YYYYMMColumn,{{"YYYYMM", Int64.Type}}),
    ActualForecastTypeColumn = Table.AddColumn(
	YYYYMMColumnDateType, 
	"Type", 
	each
		//
		if
			[YYYYMM]  < BudYrMth 
		then
			"Actual"
		else
			"Forecast"
		//
	, Text.Type
),
    FilterOutActuals = Table.SelectRows(ActualForecastTypeColumn, each ([Type] = "Forecast")),
    RemoveDateBuildColumns = Table.RemoveColumns(FilterOutActuals,{"Financial Year", "Attribute.1", "Month", "Year"}),
    MergeDemandForecastLeftOuter = Table.NestedJoin(RemoveDateBuildColumns, {"Channel", "SKU", "Date"}, #"Demand Qty Forecast", {"Channel", "SKU", "Attribute"}, "Demand Qty Forecast", JoinKind.LeftOuter),
    ExpandDemandForecastQty = Table.ExpandTableColumn(MergeDemandForecastLeftOuter, "Demand Qty Forecast", {"Qty", "Sales", "Cost"}, {"Demand Qty Forecast.Qty", "Demand Qty Forecast.Sales", "Demand Qty Forecast.Cost"}),
    RenameSalesCostQtyColumns = Table.RenameColumns(ExpandDemandForecastQty,{{"1 Qty", "Qty"}, {"4 Sales", "Sales"}, {"5 Cost", "Cost"}}),
    ConsolidatedQtyColumn = Table.AddColumn(
            RenameSalesCostQtyColumns, 
            "Combined Qty", 
            each
                //  
                if
                    [Demand Qty Forecast.Qty] = null
                then
                    [Qty]
                else
                    [Demand Qty Forecast.Qty]
                //
            , Number.Type
        ),
    ConsolidatedSalesColumn = Table.AddColumn(
            ConsolidatedQtyColumn, 
            "Combined Sales", 
            each
                //  
                if
                    [Demand Qty Forecast.Sales] = null
                then
                    [Sales]
                else
                    [Demand Qty Forecast.Sales]
                //
            , Number.Type
        ),
    ConsolidatedCostColumn = Table.AddColumn(
            ConsolidatedSalesColumn, 
            "Combined Cost", 
            each
                //  
                if
                    [Demand Qty Forecast.Cost] = null
                then
                    [Cost]
                else
                    [Demand Qty Forecast.Cost]
                //
            , Number.Type
        ),
    RemoveColumnsBuildSalesCostQty = Table.RemoveColumns(ConsolidatedCostColumn,{"Qty", "Sales", "Cost", "Demand Qty Forecast.Qty", "Demand Qty Forecast.Sales", "Demand Qty Forecast.Cost"}),
    RenameColumnsSalesCostQty = Table.RenameColumns(RemoveColumnsBuildSalesCostQty,{{"Combined Qty", "Qty"}, {"Combined Sales", "Sales"}, {"Combined Cost", "Cost"}}),
    AppendActuals = Table.Combine({RenameColumnsSalesCostQty, #"Sales Act History"}),
    FilterOutZeroNullQty = Table.SelectRows(AppendActuals, each ([Qty] <> 0 and [Qty] <> null ))
in
    FilterOutZeroNullQty