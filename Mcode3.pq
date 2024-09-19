
let
  Source = SharePoint.Files("https://woodplc.sharepoint.com/sites/PBIDSASEAAA/", [ApiVersion = 15]), 
  #"Filtered rows" = Table.SelectRows(Source, each Text.Contains([Name], "INPCostControlData")), 
  #"Filtered hidden files" = Table.SelectRows(#"Filtered rows", each [Attributes]?[Hidden]? <> true), 
  #"Invoke custom function" = Table.AddColumn(
    #"Filtered hidden files", 
    "Transform file (2)", 
    each #"Transform file (2)"([Content])
  ), 
  #"Renamed columns" = Table.RenameColumns(#"Invoke custom function", {{"Name", "Source.Name"}}), 
  #"Removed other columns" = Table.SelectColumns(
    #"Renamed columns", 
    {"Source.Name", "Transform file (2)"}
  ), 
  #"Split column by delimiter" = Table.SplitColumn(
    #"Removed other columns", 
    "Source.Name", 
    Splitter.SplitTextByDelimiter("@"), 
    {"Source.Name.1", "Source.Name.2"}
  ), 
  #"Split column by delimiter 1" = Table.SplitColumn(
    #"Split column by delimiter", 
    "Source.Name.2", 
    Splitter.SplitTextByDelimiter("."), 
    {"Source.Name.3", "Source.Name.4"}
  ), 
  #"Trimmed text" = Table.TransformColumns(
    #"Split column by delimiter 1", 
    {{"Source.Name.3", each Text.Trim(_), type nullable text}}
  ), 
  #"Changed column type with locale" = Table.TransformColumnTypes(
    #"Trimmed text", 
    {{"Source.Name.3", type datetime}}, 
    "en-AU"
  ), 
  #"Filtered rows 1" = Table.SelectRows(
    #"Changed column type with locale", 
    each Date.IsInPreviousNWeeks([Source.Name.3], 18)
  ), 
  #"Expanded table column" = Table.ExpandTableColumn(
    #"Filtered rows 1", 
    "Transform file (2)", 
    Table.ColumnNames(#"Transform file (2)"(#"Sample file (2)"))
  ), 
  #"Inserted Merged Column" = Table.AddColumn(
    #"Expanded table column", 
    "ProjectTask", 
    each Text.Combine({Text.From([Job Code], "en-US"), [Work Element Code]}), 
    type text
  ), 
  #"Added custom" = Table.AddColumn(
    #"Inserted Merged Column", 
    "ExcludeZeroCost", 
    each [Budget Anticipated]
      + [Budget Approved]
      + [Budget Original]
      + [Budget Pending]
      + [#"Commitment "]
      + [Expenditure To Date]
      + [Final Forecast]
  ), 
  #"Removed columns" = Table.RemoveColumns(#"Added custom", {"Source.Name.1", "Source.Name.4"}), 
  #"Renamed columns 2" = Table.RenameColumns(
    #"Removed columns", 
    {
      {"Source.Name.3", "Cut-Off"}, 
      {"Client Project No ", "Client Project No"}, 
      {"Commitment ", "Commitment"}
    }
  ), 
  #"Changed column type" = Table.TransformColumnTypes(
    #"Renamed columns 2", 
    {
      {"Budget Original", Currency.Type}, 
      {"Budget Approved", Currency.Type}, 
      {"Budget Pending", Currency.Type}, 
      {"Budget Anticipated", Currency.Type}, 
      {"Earned Cost", Currency.Type}, 
      {"Commitment", Currency.Type}, 
      {"Expenditure To Date", Currency.Type}, 
      {"Forecast Remaining", Currency.Type}, 
      {"Final Forecast", Currency.Type}, 
      {"Variance", Currency.Type}, 
      {"VOWD", Currency.Type}, 
      {"ExcludeZeroCost", type number}, 
      {"Responsible Party", type text}, 
      {"Client CBS", type text}, 
      {"Package", type text}, 
      {"Asset", type text}, 
      {"Client Project No", type text}, 
      {"Client Focal Point", type text}, 
      {"Wood Project Engineer", type text}, 
      {"Project Type", type text}, 
      {"Expenditure Category Name", type text}, 
      {"Expenditure Category Code", type text}, 
      {"Work Element Status", type text}, 
      {"Work Element Name", type text}, 
      {"Work Element Code", type text}, 
      {"WBS Status", type text}, 
      {"WBS Name", type text}, 
      {"WBS Code", type text}, 
      {"Work Phase Status", type text}, 
      {"Work Phase Name", type text}, 
      {"Work Phase Code", type text}, 
      {"Job status", type text}, 
      {"Project Number", type text}, 
      {"Job Description", type text}, 
      {"Job Code", type text}
    }
  ), 
  #"Replace errors" = Table.ReplaceErrorValues(
    #"Changed column type", 
    {
      {"Job Code", null}, 
      {"Job Description", null}, 
      {"Project Number", null}, 
      {"Job status", null}, 
      {"Work Phase Code", null}, 
      {"Work Phase Name", null}, 
      {"Work Phase Status", null}, 
      {"WBS Code", null}, 
      {"WBS Name", null}, 
      {"WBS Status", null}, 
      {"Work Element Code", null}, 
      {"Work Element Name", null}, 
      {"Work Element Status", null}, 
      {"Expenditure Category Code", null}, 
      {"Expenditure Category Name", null}, 
      {"Project Type", null}, 
      {"Wood Project Engineer", null}, 
      {"Client Focal Point", null}, 
      {"Client Project No", null}, 
      {"Asset", null}, 
      {"Package", null}, 
      {"Client CBS", null}, 
      {"Responsible Party", null}, 
      {"Budget Original", null}, 
      {"Budget Approved", null}, 
      {"Budget Pending", null}, 
      {"Budget Anticipated", null}, 
      {"Earned Cost", null}, 
      {"Commitment", null}, 
      {"Expenditure To Date", null}, 
      {"Forecast Remaining", null}, 
      {"Final Forecast", null}, 
      {"Variance", null}, 
      {"VOWD", null}, 
      {"ExcludeZeroCost", null}
    }
  ), 
  #"t_Imperium_Cost_History-4375742D4F6666-autogenerated_for_incremental_refresh" = Table.SelectRows(
    #"Replace errors", 
    each DateTime.From([#"Cut-Off"]) >= RangeStart and DateTime.From([#"Cut-Off"]) < RangeEnd
  )
in
  #"t_Imperium_Cost_History-4375742D4F6666-autogenerated_for_incremental_refresh"

