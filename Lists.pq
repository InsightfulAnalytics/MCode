
/* working with lists */

//  add cumulative sum column using a list

    = Table.AddColumn(ReorderColumns, "CumulativeSum", each List.Sum(List.FirstN(Table.Column(ReorderColumns, "Amount"), [Index] + 1)), type number)

//





