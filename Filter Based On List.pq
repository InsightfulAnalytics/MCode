
//filter based on list

= Table.SelectRows( 
    Source , 
    each (
        List.Contains(
            SKUs,
            [SKU]) = true 
        )
    )

////////

= Table.SelectRows( 
    DateType2 , 
    each (
        List.Contains(
            LedgerList,
            [GL]) = true 
        )
    )


///

= Table.SelectRows(factSales, each List.Contains(requiredProductNumbers, [Product]))