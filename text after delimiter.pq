



// Text after delimiter 

Text.AfterDelimiter("111-222-333", "-")


////////// add a column

= Table.AddColumn(
    AddColumnSales, 
    "Cost", 
    each [Constrained Qty] * [ACG],
    Number.Type
)



// add column with text after delimiter

FileDateText = 

    Table.AddColumn(
        ChangeType, 
        "File Date", 
        each 
        Text.Start(
            Text.AfterDelimiter(
                [Source.Name], "_"
            ) ,
            6
        ) & "01",
        Text.Type
    )
    
///////////

= 

    Text.Start(
        Text.AfterDelimiter(
            Sheet1_Sheet{7}[Column1] , ":"
        ), 8
    )

//////

Text.Trim(
    Text.AfterDelimiter(
        ExpandData {7}[Column1] , ":"
    )
)

= Sheet1_Sheet{7}[Column1]



/////////


= Table.SplitColumn( ExpandTableColumn , "Source.Name", Splitter.SplitTextByDelimiter("_", QuoteStyle.Csv), {"Source.Name.1", "Source.Name.2", "Source.Name.3"})

= Table.AddColumn(
    AddColumnSales, 
    "Cost", 
    each [Constrained Qty] * [ACG],
    Number.Type
)





= 
Table.AddColumn( 
    ExpandTableColumn ,
    "File Date",
    each Text.Start(
        Text.AfterDelimiter(
            [Source.Name] , "_"
        ),
        6
    ) & "01",
    Text.Type
) 




