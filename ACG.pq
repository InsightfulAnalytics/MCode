=Table.AddColumn(
    ASP,
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

//Divide error handling