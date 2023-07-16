
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
    SortByDate , 
    each (
        List.Contains(
            SkuList,
            [SKU]) = true 
        )
    )
