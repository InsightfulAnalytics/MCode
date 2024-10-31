
// replace all values in a  column

    , ReplaceOperatingFinishTime = 
        Table.ReplaceValue(
            KeepOverNightProcedures, 
            each 
                [OperatingFinishTime],  // replace all values in this column
                #time(23, 59, 0),       // replace with with 11:59:00 PM
                Replacer.ReplaceValue,  // use the replace values function
                {"OperatingFinishTime"} // creates a list out of the OperatingFinishTime column
        )


// replace all values in a  column

    , ReplaceValues = 
        Table.ReplaceValue(
            PriorStep, 
            each 
                [Column],  // replace all values in this column
                #time(23, 59, 0),       // replace with with 11:59:00 PM
                Replacer.ReplaceValue,  // use the replace values function
                {"Column"} // creates a list out of the OperatingFinishTime column
        )



// transform the current column to extract the first 2 letters, uses _ to refer to own column
    = Table.TransformColumns(
        SplitByRightSpace,
        {
            {
                "Trx Source", 
                each 
                    Text.Start(_, 2) , 
                    type text
            }
        }
    )

/////////


    = Table.TransformColumns(
        ArApFromTransactionSource,
        {
            {
                "Reference", 
                each 
                    Text.Remove( _, {"0".."9"}),
                    type text
                    
            }
        }
    )

////
    Text.Remove(
            _,
            {"0".."9"}
            )


//Convert YYYYMM to Date

    = Table.TransformColumns(YYYYMtoText,{{"YYYYMM", each Date.FromText(_ & "01")  , type text}})


    = Source{[#"Folder Path"="M:\Finance\Reporting\Power BI\Parcel Buys\Data Files\Sigma\",Name="0061000240.KEY PHARMACEUTICALS PTY LTD.Vendor Claims.July2022.xlsx"]}[Content]

    = Source{[#"Folder Path"="M:\Finance\Reporting\Power BI\Parcel Buys\Data Files\Sigma\",Name="61000240.KEY PHARMACEUTICALS PTY LTD.Vendor Claims.April 2023.xlsx"]}[Content]


/////////


    = Table.TransformColumns(
        ChangeDaysFromToday,
        {
            {
                "DaysFromToday", 
                each 
                    Number.RoundDown( _, 1),
                    type number
                    
            }
        }
    )


// transform the current column to add a "1-" to the column value
    = Table.TransformColumns(
        UnpivotDatesValues,
        {
            {
                "Attribute", 
                each 
                    "1-" & _ , 
                    type date
            }
        }
    )


