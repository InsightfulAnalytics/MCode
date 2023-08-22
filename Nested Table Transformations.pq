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








