//////

// my adjusted code for date time

    let
        Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("dc7LDcAgDAPQVSrOlchXgqyC2H+NRj0Sc31y7KzVmDtpFxJ7Rii1/aZ5NQE5GcAm6Mtbu9sM9dOYwipyeEUNKpWJjFAQ1o8SraKhIf9xfw==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [#"date & time" = _t]),
        #"Changed Type with Locale" = Table.TransformColumnTypes(Source, {{"date & time", type datetime}}, "en-AU"),
        RenameDateColumn = Table.RenameColumns(#"Changed Type with Locale",{{"date & time", "EstimatedCloseDate"}}),

        RenameColumn = Table.RenameColumns(RenameDateColumn,{{"EstimatedCloseDate", "Date modified"}}),
        AddDatestamp = Table.DuplicateColumn( RenameColumn , "Date modified", "Datestamp"),
        TodayFunction = DateTime.FixedLocalNow,    
        AddToday = Table.AddColumn(AddDatestamp, "Today", each TodayFunction() ,type datetime),
        ChangeTodayType = Table.TransformColumnTypes(AddToday,{{"Today", type datetime}}),
        AddDaysFromToday = Table.AddColumn(ChangeTodayType, "DaysFromToday", each [Datestamp]-[Today]),
        ChangeDaysFromToday =  Table.TransformColumnTypes(AddDaysFromToday,{{"DaysFromToday",  Number.Type } }),
        RoundDown = Table.TransformColumns(
            ChangeDaysFromToday,
            {
                "DaysFromToday", 
                each 
                    Number.RoundDown( _, 1),
                    type number
                    
            }
        ),
        Result = Table.RemoveColumns(RoundDown, "Today"),
        FilterRows = Table.SelectRows(Result, each [DaysFromToday] <= -0.2 and [DaysFromToday] >= -45)
    in
        FilterRows

/* their code */

    // GetStorageContainerContent

    let
        Source = #"#StorageContainers",
        #"ContainerContent" = Source{[Name=#"@AzureStorageBlobContainerName"]}[Data],
        #"Removed Other Columns" = Table.SelectColumns(ContainerContent,{"Content", "Name", "Date modified", "Attributes"}),
        #"Filtered Rows" = Table.SelectRows(#"Removed Other Columns", each [Name] <> "model.json"),
        #"Sorted Rows" = Table.Sort(#"Filtered Rows",{{"Date modified", Order.Descending}}),
        #"Expanded Attributes" = Table.ExpandRecordColumn(#"Sorted Rows", "Attributes", {"Size"}, {"Size"}),
        #"File Name column" = Table.DuplicateColumn(#"Expanded Attributes", "Name", "File Name"),
        #"Remove csv" = Table.ReplaceValue(#"File Name column","csv/","",Replacer.ReplaceText,{"File Name"}),
        #"Split Column by Delimiter" = Table.SplitColumn(#"Remove csv", "File Name", Splitter.SplitTextByEachDelimiter({"/"}, QuoteStyle.Csv, true), {"Interaction Name", "File Name"}),
        #"Transform" = Table.TransformColumnTypes(#"Split Column by Delimiter",{{"Interaction Name", type text}, {"File Name", type text}, {"Size", Int64.Type}}),    
        #"Add Datestamp" = Table.DuplicateColumn(#"Transform", "Date modified", "Datestamp"),
        #"DateStampFormat" = Table.TransformColumnTypes(#"Add Datestamp",{{"Datestamp", type date}}),
        
        TodayFunction = DateTime.FixedLocalNow,    
        #"Add Today" = Table.AddColumn(#"DateStampFormat", "Today", each TodayFunction()),
        //#"Changed TodayType" = Table.TransformColumnTypes(#"Add Today",{{"Today", type date}}),  //replaced code
        #"Changed TodayType" = Table.TransformColumnTypes(#"Add Today",{{"Today", type datetime}}),  //change from date to datetime
        #"Add DaysFromToday" = Table.AddColumn(#"Changed TodayType", "DaysFromToday", each [Datestamp]-[Today]),
        #"Changed DaysFromToday" = Table.TransformColumnTypes(#"Add DaysFromToday",{{"DaysFromToday", Number.Type}}),
        RoundDown = Table.TransformColumns(
            #"Changed DaysFromToday",
            {
                "DaysFromToday", 
                each 
                    Number.RoundDown( _, 1),
                    type number
                    
            }
        ),  // add in round down transformation for days from today
        Result = Table.RemoveColumns(#"Changed DaysFromToday", "Today")
    in
        Result

///

// FilterStorageContainerContent

    (#"Interaction Name") =>

    let
        Source = GetStorageContainerContent(),
        #"FilteredByInteraction" = if (#"Interaction Name" is null) then Source
        else
        Table.SelectRows(#"Source", each [Interaction Name] = #"Interaction Name"),
        // Filter by the number of daysback
        Result = if (not (#"@LoadInteractionsForNumberOfDaysBack" is null))
        then Table.SelectRows(
            #"FilteredByInteraction",
                //each  [DaysFromToday] <= -1 and [DaysFromToday] >= -#"@LoadInteractionsForNumberOfDaysBack"  // prior to modification
                each  [DaysFromToday] <= -0.2 and [DaysFromToday] >= -#"@LoadInteractionsForNumberOfDaysBack"
            )
        else #"FilteredByInteraction"
    in
        Result

//


