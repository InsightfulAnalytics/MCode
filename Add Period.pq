//Add Period

= Table.AddColumn(Unpivot, "Period", each if [Attribute.1] = "Jul" then 1 else if [Attribute.1] = "Aug" then 2 else if [Attribute.1] = "Sep" then 3 else if [Attribute.1] = "Oct" then 4 else if [Attribute.1] = "Nov" then 5 else if [Attribute.1] = "Dec" then 6 else if [Attribute.1] = "Jan" then 7 else if [Attribute.1] = "Feb" then 8 else if [Attribute.1] = "Mar" then 9 else if [Attribute.1] = "Apr" then 10 else if [Attribute.1] = "May" then 11 else if [Attribute.1] = "Jun" then 12 else 13, Number.Type )

//Month Number

 Table.AddColumn(
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
	)

//Year

//
		
		if
			[Period] > 6 
		then
			[Financial Year] 
		else
			[Financial Year] - 1

//Date

//
	
		#date(
			[Year],
			[Month],
			1
		)

//YYYYMM

= Table.AddColumn(
	RemoveColumns, 
	"YYYYMM", 
	each
		//
		
		if
			[Period] < 10
		then
			Number.ToText([Financial Year]) & "0" & Number.ToText([Period]) 
		else
			Number.ToText([Financial Year])  & Number.ToText([Period]) 
		
		//
	, Number.Type
)



///////////

let
    Source = Excel.Workbook(File.Contents("M:\Budget & LE's\FAB Tool\Linked Files\Consolidate Brand Group LOAD FILE.xlsm"), null, true),
    tbl_202206_Table = Source{[Item="tbl_202206",Kind="Table"]}[Data],
    Types = Table.TransformColumnTypes(tbl_202206_Table,{{"Channel", type text}, {"Brand", type text}, {"SKU", Text.Type}, {"Description", type text}, {"Attribute", type text}, {"Financial Year", Int64.Type}, {"Jun", type number}, {"May", type number}, {"Apr", type number}, {"Mar", type number}, {"Feb", type number}, {"Jan", type number}, {"Dec", type number}, {"Nov", type number}, {"Oct", type number}, {"Sep", type number}, {"Aug", type number}, {"Jul", type number}}),
    FilterYears = Table.SelectRows(Types, each ([Attribute] = "1 Qty") and ([Financial Year] = FirstBudYear or [Financial Year] = SecondBudYear)),
    Unpivot = Table.UnpivotOtherColumns(FilterYears, {"Channel", "Brand", "SKU", "Description", "Attribute", "Financial Year"}, "Attribute.1", "Value"),
    Period = Table.AddColumn(Unpivot, "Period", each if [Attribute.1] = "Jul" then 1 else if [Attribute.1] = "Aug" then 2 else if [Attribute.1] = "Sep" then 3 else if [Attribute.1] = "Oct" then 4 else if [Attribute.1] = "Nov" then 5 else if [Attribute.1] = "Dec" then 6 else if [Attribute.1] = "Jan" then 7 else if [Attribute.1] = "Feb" then 8 else if [Attribute.1] = "Mar" then 9 else if [Attribute.1] = "Apr" then 10 else if [Attribute.1] = "May" then 11 else if [Attribute.1] = "Jun" then 12 else 13, Number.Type ),
    #"Removed Columns" = Table.RemoveColumns(Period,{"Attribute"})
in
    #"Removed Columns"