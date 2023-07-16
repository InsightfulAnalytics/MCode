= Table.AddColumn(
    ReplaceValue, 
    "Constrained Qty",
        each 
            if
                [Qty] = null
            then
                0
            else 
                if
                    [Type] = "Actual"
                then
                    [Qty]
                else
                    if
                        [Type] = "Budget" and
                        [Qty] - [Qty Constraints] < 0 
                    then
                        0
                    else
                        [Qty] - [Qty Constraints]
                
    , Number.Type
)


