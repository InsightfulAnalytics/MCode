//

= Table.AddColumn(
    KeepOnlyDataColumns, 
    "FilterNulls",
        each
            Table.SelectRows(
                [Data],
                each
                    [Column3] <> null
            )
)

/////

= Table.PromoteHeaders(Custom1, [PromoteAllScalars=true])

///

= Table.AddColumn(
    nt_FilterOutNull, 
    "PromoteHeaders",
        each
            Table.PromoteHeaders(
                [FilterNulls],
                [PromoteAllScalars=true]
            )
)

///

= Table.AddColumn(
    nt_PromoteHeaders, 
    "DeleteColumns",
        each
            Table.RemoveColumns(
                [PromoteHeaders],
                {"Column1" , "Comments"} 
            )
)

//

=  Table.RenameColumns( 
      FilterRows,
      {
          { Table.ColumnNames( FilterRows ) {0} ,"Condition Contract" },

///

= Table.AddColumn(
    nt_DeleteColumns, 
    "RenameColumn",
        each
            Table.RenameColumns( 
                [DeleteColumns] ,
                {
                    { Table.ColumnNames( [DeleteColumns] ) {0} ,"SKU" }
                }
            )
)

/////

= Table.AddColumn(
    KeepOnlyDataColumn, 
    "RenameColumn",
        each
            Table.PromoteHeaders( [Data], [PromoteAllScalars = true])
)

/////

= Table.AddColumn(
    NestedTablePromoteHeaders, 
    "RenameColumn",
        each
            Table.AddColumn([Data], "Custom", each [Item])
)


Table.AddColumn(NestedTablePromoteHeaders, "Custom", each [Item])


//////////


let
  Source = SharePoint.Files("https://acurioservices.sharepoint.com/sites/ITS", [ApiVersion = 15]),
  BudgetFile = Table.SelectRows(Source, each ([Name] = BudgetFileName )),
  DrillDown = BudgetFile{0}[Content],
  ImportExcelWorkbook = Excel.Workbook(DrillDown, null, true),
  KeepOnlyDataColumn = Table.SelectColumns(ImportExcelWorkbook, {"Data", "Item" }),
  NestedTablePromoteHeaders =  Table.AddColumn(
    KeepOnlyDataColumn, 
    "PromoteHeaders",
        each
            Table.PromoteHeaders( [Data], [PromoteAllScalars = true])
),
  NestedTableAddItemColumn =  Table.AddColumn(
    NestedTablePromoteHeaders, 
    "RenameColumn",
        each
            Table.AddColumn([Data], "Custom", each [Item])
)
,
  ExpandTables = Table.Combine(NestedTableAddItemColumn[PromoteHeaders]),
  UnpivotDatesValues = Table.UnpivotOtherColumns(ExpandTables, {"CostCentre", "Type", "Specialization"}, "Attribute", "Value"),
  ChangeColumnTypes = Table.TransformColumnTypes(UnpivotDatesValues, {{"CostCentre", type text}, {"Type", type text}, {"Specialization", type text}, {"Attribute", type date}, {"Value", type number}})
in
  ChangeColumnTypes


