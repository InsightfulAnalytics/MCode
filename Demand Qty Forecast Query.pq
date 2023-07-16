
//Demand forecast file Parameter

"\\keypharm.local\keydata\data\Budget & LE's\FAB Tool\Demand Forecast\Demand FC Linked Files\Demand Forecast.xlsx" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

//Demand forecast qty file

let
    Source = Excel.Workbook(File.Contents(DemandForecastFile), null, true),
    Sheet1_Sheet = Source{[Item="Sheet1",Kind="Sheet"]}[Data],
    PromoteHeaders = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    UnpivotOtherColumns = Table.UnpivotOtherColumns(PromoteHeaders, {"Channel", "SKU"}, "Attribute", "Value"),
    ReplaceNullWithZero = Table.ReplaceValue(UnpivotOtherColumns,null,0,Replacer.ReplaceValue,{"Value"}),
    ChangeTypes = Table.TransformColumnTypes(ReplaceNullWithZero,{{"Channel", type text}, {"SKU", type text}, {"Attribute", type date}, {"Value", Int64.Type}}),
    RenameValuesToQty = Table.RenameColumns(ChangeTypes,{{"Value", "Qty"}}),
    MergeBgfAspAcg = Table.NestedJoin(RenameValuesToQty, {"Channel", "SKU"}, #"Brand Group Files ASP ACG", {"Channel", "SKU"}, "Brand Group Files ASP ACG", JoinKind.LeftOuter),
    ExpandBgfAspAcg = Table.ExpandTableColumn(MergeBgfAspAcg, "Brand Group Files ASP ACG", {"ASP", "ACG"}, {"ASP", "ACG"}),
    SalesColumn = Table.AddColumn(
	ExpandBgfAspAcg, 
	"Sales", 
	each
		//  
            [ASP] * [Qty]
		//
	, Number.Type

),
    CostColumn = Table.AddColumn(
	SalesColumn, 
	"Cost", 
	each
		//  
            [ACG] * [Qty]
		//
	, Number.Type

)
in
    CostColumn
