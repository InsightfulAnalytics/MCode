= Table.AddColumn(
    #"Sorted Rows",
    "ASP", 
    each
    (
    if 		
        (try [Sales] / [Qty]) [HasError] 
    then
        0 
    else
        if 
            [Sales] / [Qty] = null 
        then 
            0 
        else 
            if 
                [Sales] / [Qty] = Number.PositiveInfinity 
            then 
                0 
            else 
                if 
                    [Sales] / [Qty] = Number.NegativeInfinity 
                then 
                    0 
                else 
                    if 
                        Number.IsNaN ([Sales] / [Qty] ) 
                    then 
                        0 
                    else
                        if 		
                            (try [Sales] / [Qty]) [HasError] 
                        then
                            0 
                        else 	
                            [Sales] / [Qty]
        ), 
    Number.Type
)

///  ASP

= Table.AddColumn(
    // ASP with error handling
    FilterOutZero ,
    "ASP", 
    each
    (
    if 		
        (try [Sales] / [Qty]) [HasError] 
    then
        0 
    else
        if 
            [Sales] / [Qty] = null 
        then 
            0 
        else 
            if 
                [Sales] / [Qty] = Number.PositiveInfinity 
            then 
                0 
            else 
                if 
                    [Sales] / [Qty] = Number.NegativeInfinity 
                then 
                    0 
                else 
                    if 
                        Number.IsNaN ([Sales] / [Qty] ) 
                    then 
                        0 
                    else
                        if 		
                            (try [Sales] / [Qty]) [HasError] 
                        then
                            0 
                        else 	
                            [Sales] / [Qty]
        ), 
    Number.Type
)

///////////////////

= Table.AddColumn(
    // ACG with error handling
    GroupRows ,
    "ACG", 
    each
    (
    if 		
        (try [Cost] / [Qty]) [HasError] 
    then
        0 
    else
        if 
            [Cost] / [Qty] = null 
        then 
            0 
        else 
            if 
                [Cost] / [Qty] = Number.PositiveInfinity 
            then 
                0 
            else 
                if 
                    [Cost] / [Qty] = Number.NegativeInfinity 
                then 
                    0 
                else 
                    if 
                        Number.IsNaN ([Cost] / [Qty] ) 
                    then 
                        0 
                    else
                        if 		
                            (try [Cost] / [Qty]) [HasError] 
                        then
                            0 
                        else 	
                            [Cost] / [Qty]
        ), 
    Number.Type
)