

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