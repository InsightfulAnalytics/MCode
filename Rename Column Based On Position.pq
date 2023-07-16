
// Rename a column name based on position { 0 } is the first column

    ReNameColumn=

        Table.RenameColumns( 
            PromoteHeaders,
            {
                { Table.ColumnNames( PromoteHeaders ) {0} ,"Source.Name" }
            }
        )

///////////


let

  Source = 
    Excel.Workbook(Parameter3, null, true), 

  #"Reptos Monthly Claims_Sheet" = 
    Source{[Item = "Reptos Monthly Claims", Kind = "Sheet"]}[Data], 

  PromoteHeaders = 
    Table.PromoteHeaders(#"Reptos Monthly Claims_Sheet", [PromoteAllScalars = true]), 

  ReNameColumn=

    Table.RenameColumns( 
        PromoteHeaders,

        { 
            Table.ColumnNames( PromoteHeaders ) ,
                { {0} ,"Condition Contract"  } ,
                { {1} ,"Supplier Code" }
        } 

    ),

  RemoveColumns = 
    Table.RemoveColumns(
    PromoteHeaders, 
    {"Condition Contract", "Supplier Code", "Supplier Description", "Settlement Document"}
  ),

  ChangeType = 
  Table.TransformColumnTypes(
    RemoveColumns, 
    {
      {"Month & Year Of Settlement", type date}, 
      {"Invoice #", type text}, 
      {"Invoice Date", type date}, 
      {"Account Number", type text}, 
      {"Account Name", type text}, 
      {"Banner Group", type text}, 
      {"State ", type text}, 
      {"Product Code ", type text}, 
      {"Product ", type text}, 
      {"Supplier Product Code ", type text}, 
      {"Shipped Qty", Int64.Type}, 
      {"Wholesale Price ", type number}, 
      {"Supplier Discount %", type number}, 
      {"Claim Amount", type number}, 
      {"Net Sales Value", type number}, 
      {"GST On Net Sales ", type number}, 
      {"Reference No. ", type text}
    }
  ), 
  FilterRows = 
  Table.SelectRows(ChangeType, each [#"Invoice #"] <> null and [#"Invoice #"] <> "")
  

in
  FilterRows


// Rename a column name based on position { 0 } is the first column

    RenameColumnOrderForMonth=

        Table.RenameColumns( 
            PromoteHeaders,
            {
                { Table.ColumnNames( PromoteHeaders ) {0} ,"Orders For Month" }
            }
        )


// Rename a column name based on position { 0 } is the first column

    RenameColumnOrderForMonth=

        Table.RenameColumns( 
            FilterRows,
            {
                { Table.ColumnNames( PromoteHeaders ) {0} ,"Month & Year Of Settlement" }
            }
        )

/////////



=  Table.RenameColumns( 
      FilterRows,
      {
          { Table.ColumnNames( FilterRows ) {0} ,"Condition Contract" },
          { Table.ColumnNames( FilterRows ) {1} ,"Supplier Code" },
          { Table.ColumnNames( FilterRows ) {2} ,"Supplier Description" },
          { Table.ColumnNames( FilterRows ) {3} ,"Month & Year Of Settlement" },
          { Table.ColumnNames( FilterRows ) {4} ,"Settlement Document" },
          { Table.ColumnNames( FilterRows ) {5} ,"Invoice #" },
          { Table.ColumnNames( FilterRows ) {6} ,"Invoice Date" },
          { Table.ColumnNames( FilterRows ) {7} ,"Account Number" },
          { Table.ColumnNames( FilterRows ) {8} ,"Account Name" },
          { Table.ColumnNames( FilterRows ) {9} ,"Banner Group" },
          { Table.ColumnNames( FilterRows ) {10} ,"State" },
          { Table.ColumnNames( FilterRows ) {11} ,"Product Code" },
          { Table.ColumnNames( FilterRows ) {12} ,"Product" },
          { Table.ColumnNames( FilterRows ) {13} ,"Supplier Product Code" },
          { Table.ColumnNames( FilterRows ) {14} ,"Shipped Qty" },
          { Table.ColumnNames( FilterRows ) {15} ,"Wholesale Price" },
          { Table.ColumnNames( FilterRows ) {16} ,"Supplier Discount %" },
          { Table.ColumnNames( FilterRows ) {17} ,"Claim Amount" },
          { Table.ColumnNames( FilterRows ) {18} ,"Net Sales Value" },
          { Table.ColumnNames( FilterRows ) {19} ,"GST On Net Sales" },
          { Table.ColumnNames( FilterRows ) {20} ,"Reference No." }
      }
  )




Invoice Date
Account Number
Account Name
Banner Group
State 
Product Code 
Product 
Supplier Product Code 
Shipped Qty
Wholesale Price 
Supplier Discount %
Claim Amount
Net Sales Value
GST On Net Sales 
Reference No. 