
/* working with lists */

//  add cumulative sum column using a list

    = Table.AddColumn(ReorderColumns, "CumulativeSum", each List.Sum(List.FirstN(Table.Column(ReorderColumns, "Amount"), [Index] + 1)), type number)

//


    = 
    Table.AddColumn(
        ReorderColumns,
        "Remove24Bud",
        each 
            List.ContainsAny(
                {}
                
            )
    )

/////////

// Change all column types to text
    ChangeColumnTypes =
        Table.TransformColumnTypes(
            SheetData,
            List.Transform(
                Table.ColumnNames(SheetData),  
            each {_, Text.Type}
            )
        ),




//////
