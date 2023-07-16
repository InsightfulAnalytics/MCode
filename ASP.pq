=Table.AddColumn(
    ChangeFabColumnTypes,
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

//Divide error handling