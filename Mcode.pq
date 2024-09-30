

//GetStorageContainerContent

    ()=>
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
        #"Changed TodayType" = Table.TransformColumnTypes(#"Add Today",{{"Today", type date}}),
        #"Add DaysFromToday" = Table.AddColumn(#"Changed TodayType", "DaysFromToday", each [Datestamp]-[Today]),
        #"Changed DaysFromToday" = Table.TransformColumnTypes(#"Add DaysFromToday",{{"DaysFromToday", Int64.Type}}),
        Result = Table.RemoveColumns(#"Changed DaysFromToday", "Today")
    in
        Result

//#StorageContainerContent

    //loaded, doesn't lead to anywhere


//FilteredStorageContainerContent


let
    Source = FilterStorageContainerContent(null),
    #"Remove Columns" = Table.RemoveColumns(Source,{"Name", "Date modified"}),
    #"Merged Queries" = Table.NestedJoin(#"Remove Columns",{"Interaction Name"},#"!LoadedInteractions",{"Interaction Name"},"!LoadedInteractions",JoinKind.Inner),
    #"Removed Columns" = Table.RemoveColumns(#"Merged Queries",{"!LoadedInteractions"}),
    Result = Table.Buffer(#"Removed Columns")
in
    Result




//#FilterStorageContainerContent

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
            each [DaysFromToday] < -1 and [DaysFromToday] >= -45 // adjust days from & to here
        )
      else #"FilteredByInteraction"
in
    Result



//ParseInteractionFileContent

    //importing csv



//GetinteractionTabledata

(#"Interaction Name" as text) =>
       let
           //Source = FilterStorageContainerContent(#"Interaction Name"),
           Source = #"#FilteredStorageContainerContent",
           #"FilteredByInteraction" = Table.SelectRows(#"Source", each [Interaction Name] = #"Interaction Name"),
           #"AddFileContents" = Table.AddColumn(#"FilteredByInteraction", "FileContent", each ParseInteractionFileContent([Content])),
           #"ContentTable" = Table.SelectColumns(AddFileContents,{"FileContent"}),
           #"NoDataFiles" = Table.IsEmpty(#"ContentTable"),
           InteractionTable = if (#"NoDataFiles") then 
             GetDefaultInteractionTable(#"Interaction Name")
           else
             Table.ExpandTableColumn(#"ContentTable", "FileContent", Table.ColumnNames(ContentTable{0}[FileContent])),
           // Interction timestamp is stored in US datetimezone format in interaction store - this should be fixed going forward
           #"Transformed" = Table.TransformColumnTypes(InteractionTable,{{"Timestamp", type datetimezone}}, "en-US"),
           #"Duplicated Column" = Table.DuplicateColumn(#"Transformed", "Timestamp", "Datestamp"),
           #"Datestamp" = Table.TransformColumns(#"Duplicated Column",{{"Datestamp", DateTime.Date, type date}}),
           #"RenameId" = Table.RenameColumns(#"Datestamp",{{"InternalMarketingInteractionId", "Id"}})          
       in
           #"RenameId"




//Email Clicked

let
    Source = GetInteractionTableData("EmailClicked")
in
    Source

///////////////