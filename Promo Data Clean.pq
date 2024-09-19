
// IsDate - function to return logical when testing if a date value is present in text field

    (text) =>
  
    let
      parsed      = try Date.FromText(text),
      reformatted = try Date.ToText(parsed[Value], "dd.MM.yyyy")
    in
      not parsed[HasError] and not reformatted[HasError] and text = reformatted[Value]

//1st version
let
    Source = Excel.Workbook(File.Contents("C:\\Users\\tosborn\\OneDrive - Key Pharmaceuticals\\Desktop\\Chat GPT ADA - Woolies Data.xlsx"), null, true),
    SheetData = Source{[Item="Data1", Kind="Sheet"]}[Data],

    // subquery to get claim number
    
        // Get the first row as a list
        FirstRow = Table.ToRecords(Table.FirstN(SheetData, 1)){0},
        FirstRowList = Record.FieldValues(FirstRow),

        // Find the index of the cell containing "Claim No:"
        ClaimNoIndex = List.PositionOf(FirstRowList, "Claim No:"),

        // Get the claim number from the next cell
        ClaimNumber = FirstRowList{ClaimNoIndex + 1},

    // All types as text
    ChangesAllTypesToText = Table.TransformColumnTypes(SheetData,{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}, {"Column12", type text}, {"Column13", type text}, {"Column14", type text}, {"Column15", type text}, {"Column16", type text}}),

    // Convert the table into a list of lists, where each sublist is a row
    ListOfRows = List.Transform(Table.ToRows(ChangesAllTypesToText), each List.Transform(_, each if _ is null then "" else Text.From(_))),

    // Define the list of keywords to filter by
    KeywordsListToFilterBy = {"Blistex", "No Doz", "Odor Eaters", "OdorEaters"},

    // Filter the list of rows based on the presence of keywords
    FilteredListOfRows = List.Select(ListOfRows, each let RowAsString = Text.Combine(_, " ") in List.AnyTrue(List.Transform(KeywordsListToFilterBy, each Text.Contains(RowAsString, _, Comparer.OrdinalIgnoreCase)))),

    // Remove blank rows from each list
    NoBlankRowsList = List.Transform(FilteredListOfRows, each List.Select(_, each Text.Trim(_) <> "")),

    // Keep only the third last record from each list
    ThirdLastRecord = List.Transform(NoBlankRowsList, each List.LastN(_, 3){0}),
    RowsWithKeywords = List.Transform(NoBlankRowsList, each List.Select(_, each List.AnyTrue(List.Transform(KeywordsListToFilterBy, (keyword) => Text.Contains(_, keyword, Comparer.OrdinalIgnoreCase))))),
    FlattenedKeywords = List.Combine(RowsWithKeywords),

    // Custom function to check if a string is a date
    IsDate = (text) => 
        let 
            parsed = try Date.FromText(text),
            reformatted = try Date.ToText(parsed[Value], "dd.MM.yyyy")
        in 
            not parsed[HasError] and not reformatted[HasError] and text = reformatted[Value],

    // Keep rows that are in date format
    RowsWithDates = List.Transform(NoBlankRowsList, each List.Select(_, each IsDate(_))),

    // To combine all of the lists and records together in a table:

        // Extract the first and second date from RowsWithDates
    FirstDate = List.Transform(RowsWithDates, each List.First(_, null )),
    SecondDate = List.Transform(RowsWithDates, each List.Skip(_, 1){0}),

    // Combine the four lists into records
    CombinedRecords = List.Transform(
        List.Positions(FlattenedKeywords), 
        each [
            FlattenedKeywords = FlattenedKeywords{_}, 
            FirstDate = FirstDate{_}, 
            SecondDate = SecondDate{_}, 
            ThirdLastRecord = ThirdLastRecord{_}
        ]
    ),

    
    // Convert the list of records into a table
    FinalTable = Table.FromRecords(CombinedRecords),
    ChangeTypes = Table.TransformColumnTypes(FinalTable,{{"FlattenedKeywords", type text}, {"FirstDate", type date}, {"SecondDate", type date}, {"ThirdLastRecord", type number}}),
    ClaimNumberColumn = Table.AddColumn(ChangeTypes, "ClaimNumber", each ClaimNumber , type text )
in
    ClaimNumberColumn

//2nd version

let
  Source = Excel.Workbook(
    File.Contents(
      "C:\\Users\\tosborn\\OneDrive - Key Pharmaceuticals\\Desktop\\Chat GPT ADA - Woolies Data.xlsx"
    ),
    null,
    true
  ),

  SheetData = Source{[Item = "Data1", Kind = "Sheet"]}[Data],
  
  // subquery to get claim number
  // Get the first row as a list
  FirstRow = Table.ToRecords(Table.FirstN(SheetData, 1)){0},
  FirstRowList = Record.FieldValues(FirstRow),
  
  // Find the index of the cell containing "Claim No:"
  ClaimNoIndex = List.PositionOf(FirstRowList, "Claim No:"),
  
  // Get the claim number from the next cell
  ClaimNumber = FirstRowList{ClaimNoIndex + 1},
  
  // All types as text
  ChangeColumnTypes = Table.TransformColumnTypes(
    SheetData,
    List.Transform(Table.ColumnNames(SheetData), each {_, Text.Type})
  ),
  
  // Convert the table into a list of lists, where each sublist is a row
  ListOfRows = List.Transform(
    Table.ToRows(ChangeColumnTypes),
    each List.Transform(_, each if _ is null then "" else Text.From(_))
  ),
  
  // Filter the list of rows based on the presence of keywords
  FilteredListOfRows = 
    List.Select(
      ListOfRows,
      each
        let
          RowAsString = Text.Combine(_, " ")
        in
          List.AnyTrue(
            List.Transform(
              KeywordsListToFilterBy,
              each Text.Contains(RowAsString, _, Comparer.OrdinalIgnoreCase)
            )
          )
    ),

  // Remove blank rows from each list
  NoBlankRowsList = List.Transform(FilteredListOfRows, each List.Select(_, each Text.Trim(_) <> "")),

  /* Keep only the third last record from each list, works on all lists expect the first one 
     which is the sith record from the end so the records were seperated, number extracted and then combined
     this exercise is to get the $ value from the lists */
  // ThirdLastRecord = List.Transform(NoBlankRowsList, each List.LastN(_, 3){0}),

    // Keep only the first list and get the sixth last item from it
    FirstListSixthLastItem = List.LastN(NoBlankRowsList{0}, 6){0},

    // Filter out the first list and keep the third last record from each of the remaining lists
    RemainingListsThirdLastItems = List.Transform(List.Skip(NoBlankRowsList, 1), each List.LastN(_, 3){0}),

    // Combine the items from the first list and the remaining lists
    ThirdLastRecord = List.Combine({{FirstListSixthLastItem}, RemainingListsThirdLastItems}),
  
  // filter the list by keywords
  RowsWithKeywords = List.Transform(
    NoBlankRowsList,
    each List.Select(
      _,
      each List.AnyTrue(
        List.Transform(
          KeywordsListToFilterBy,
          (keyword) => Text.Contains(_, keyword, Comparer.OrdinalIgnoreCase)
        )
      )
    )
  ),

  // convert the keywords lists to values in a list
  FlattenedKeywords = List.Combine(RowsWithKeywords),

  // Keep rows that are in date format
  RowsWithDates = List.Transform(NoBlankRowsList, each List.Select(_, each IsDate(_))),

  // To combine all of the lists and records together in a table:
  // Extract the first and second date from RowsWithDates
  FirstDate = List.Transform(RowsWithDates, each List.First(_, null)),
  SecondDate = List.Transform(RowsWithDates, each List.Skip(_, 1){0}),

  // Combine the four lists into records
  CombinedRecords = List.Transform(
    List.Positions(FlattenedKeywords),
    each [
      FlattenedKeywords = FlattenedKeywords{_},
      FirstDate         = FirstDate{_},
      SecondDate        = SecondDate{_},
      ThirdLastRecord   = ThirdLastRecord{_}
    ]
  ),

  // Convert the list of records into a table
  FinalTable = Table.FromRecords(CombinedRecords),
  ChangeTypes = Table.TransformColumnTypes(
    FinalTable,
    {
      {"FlattenedKeywords", type text},
      {"FirstDate", type date},
      {"SecondDate", type date},
      {"ThirdLastRecord", type number}
    }
  ),

  //add claim number column
  ClaimNumberColumn = Table.AddColumn(ChangeTypes, "ClaimNumber", each ClaimNumber, type text)

in
  ClaimNumberColumn


