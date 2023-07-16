
// brand group files table - FAB linked file

let
    Source = Folder.Files(BrandGroupFiesFolder),
    #"Filtered Rows" = Table.SelectRows(Source, each not Text.StartsWith([Name], "~$")),
    #"Filtered Rows1" = Table.SelectRows(#"Filtered Rows", each ([Extension] = ".xlsm")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows1",{"Content"}),
    #"Invoked Custom Function" = Table.AddColumn(#"Removed Other Columns", "Budget Model Function", each #"Budget Model Function"([Content])),
    #"Removed Other Columns1" = Table.SelectColumns(#"Invoked Custom Function",{"Budget Model Function"}),
    #"Expanded Budget Model Function" = Table.ExpandTableColumn(#"Removed Other Columns1", "Budget Model Function", {"Channel", "Brand", "SKU", "Description", "Attribute", "Financial Year", "Jun", "May", "Apr", "Mar", "Feb", "Jan", "Dec", "Nov", "Oct", "Sep", "Aug", "Jul"}, {"Channel", "Brand", "SKU", "Description", "Attribute", "Financial Year", "Jun", "May", "Apr", "Mar", "Feb", "Jan", "Dec", "Nov", "Oct", "Sep", "Aug", "Jul"})
in
    #"Expanded Budget Model Function"


    // Unconstrained query

    let
    Source = Excel.CurrentWorkbook(){[Name="tbl_202301"]}[Content] ,
    FilterFYears = Table.SelectRows(Source, each ([Financial Year] = #"FYearOne" or [Financial Year] = #"FYearTwo" or [Financial Year] = #"FYearThree"  )),
    UnpivotMonths = Table.UnpivotOtherColumns(FilterFYears, {"Channel", "Brand", "SKU", "Description"  ,"Attribute", "Financial Year"}, "Attribute.1", "Value"),
    Types = Table.TransformColumnTypes(UnpivotMonths,{{"Channel", type text}, {"Brand", type text}, {"Description" , type text } , {"SKU", Text.Type}, {"Attribute", type text}, {"Financial Year", Int64.Type}, {"Attribute.1", type text}, {"Value", Number.Type}}),
    FilterQtySalesCost = Table.SelectRows(Types, each ([Attribute] <> "2 ASP" and [Attribute] <> "3 ACG")),
    PivotQtySalesCost = Table.Pivot(FilterQtySalesCost, List.Distinct(FilterQtySalesCost[Attribute]), "Attribute", "Value"),
    AddPeriod = Table.AddColumn(PivotQtySalesCost, "Period", each if [Attribute.1] = "Jul" then 1 else if [Attribute.1] = "Aug" then 2 else if [Attribute.1] = "Sep" then 3 else if [Attribute.1] = "Oct" then 4 else if [Attribute.1] = "Nov" then 5 else if [Attribute.1] = "Dec" then 6 else if [Attribute.1] = "Jan" then 7 else if [Attribute.1] = "Feb" then 8 else if [Attribute.1] = "Mar" then 9 else if [Attribute.1] = "Apr" then 10 else if [Attribute.1] = "May" then 11 else if [Attribute.1] = "Jun" then 12 else 13, Number.Type ),
    RemoveMonthName = Table.RemoveColumns(AddPeriod,{"Attribute.1"}),
    MonthNumber = Table.AddColumn(
	RemoveMonthName, 
	"Month", 
	each
		//
	
		if
			[Period] > 6 
		then
			[Period] - 6
		else
			[Period] + 6

		//
	, Number.Type
	),
    Year = Table.AddColumn(
	MonthNumber, 
	"Year", 
	each
		//
		
		if
			[Period] > 6 
		then
			[Financial Year] 
		else
			[Financial Year] - 1
		
		//
	, Number.Type
	),
    Date = Table.AddColumn(
	Year, 
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
	),
    YYYYMM = Table.AddColumn(
	Date, 
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
    ChangeType = Table.TransformColumnTypes(YYYYMM,{{"YYYYMM", Int64.Type}}),
    RenameColumns = Table.RenameColumns(ChangeType,{{"1 Qty", "Qty"}, {"4 Sales", "Sales"}, {"5 Cost", "Cost"}}),
    ReplaceNullZeroQty = Table.ReplaceValue(RenameColumns,null,0,Replacer.ReplaceValue,{"Qty"}),
    Filter0Qty = Table.SelectRows(ReplaceNullZeroQty, each ([Qty] <> 0)),
    AddColumnType = Table.AddColumn(
	Filter0Qty, 
	"Type", 
	each
		//
		
		if
			[YYYYMM] < BudYrMth
		then
			"Actual"
		else
			"Budget"
		
		//
	, Text.Type
),
    AddVersionNumber = Table.AddColumn(AddColumnType, "Version Number", each Number.FromText(FYearPeriod)  , Number.Type),
    AddVersion = Table.AddColumn(AddVersionNumber, "Version", each Date.ToText( LastActDate , [Format="MMM yyy"] ) & " FC" , Text.Type),
    Status = Table.AddColumn(AddVersion, "Status", each "Unconstrained", Text.Type )
in
    Status

