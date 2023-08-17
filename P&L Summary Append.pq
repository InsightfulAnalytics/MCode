
// merge marketing & brand manager, join on brand column
// merge cc group, on cc number
// 


let
  Source = Table.Combine({Actuals, #"Sales A&P", #"Cost Centre Expenses"}), 
  MergeMManager = Table.NestedJoin(
    Source, 
    {"Brand"}, 
    #"Marketing & Brand Manager", 
    {"Brand"}, 
    "Marketing & Brand Manager", 
    JoinKind.LeftOuter
  ), 
  ExpandMarketingBrandManager = Table.ExpandTableColumn(
    MergeMManager, 
    "Marketing & Brand Manager", 
    {"Marketing Manager", "Brand Manager"}, 
    {"Marketing Manager", "Brand Manager"}
  ), 
  MergeCcGroups = Table.NestedJoin(
    ExpandMarketingBrandManager, 
    {"CC"}, 
    #"Cost Centre Groups", 
    {"CC"}, 
    "Cost Centre Groups", 
    JoinKind.LeftOuter
  ), 
  ExpandCostCentreGroups = Table.ExpandTableColumn(
    MergeCcGroups, 
    "Cost Centre Groups", 
    {"CC Group"}, 
    {"CC Group"}
  ), 
  FilterRows = Table.SelectRows(ExpandCostCentreGroups, each true), 
  ReplaceNullWithBlank = Table.ReplaceValue(
    FilterRows, 
    null, 
    "", 
    Replacer.ReplaceValue, 
    {
      "mn_no", 
      "GL", 
      "CC", 
      "Month", 
      "Year", 
      "Amount", 
      "Acc & CC", 
      "Period", 
      "Financial Year", 
      "Type", 
      "Category", 
      "Brand", 
      "Channel", 
      "Group", 
      "Marketing Manager", 
      "Brand Manager", 
      "CC Group"
    }
  ), 
  ChangeTypes = Table.TransformColumnTypes(ReplaceNullWithBlank, {{"Amount", type number}}), 
  FilterOutZeros = Table.SelectRows(ChangeTypes, each ([Amount] <> 0))
in
  FilterOutZeros