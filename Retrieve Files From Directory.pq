
// Function to expand Prior forecasts in directory

// Prior_Forecasts_Function

(ExcelFile) =>

let

  Source = Excel.Workbook(ExcelFile, null, true), 
  Forecast_Table = Source{[Item = "tbl_Unconstrained", Kind = "Table"]}[Data]

in
  Forecast_Table

/////////////////

// Brand Group Files Loading Example Below

let
  Source = Folder.Files(PriorForecastDirectory), 
  FilterRows = Table.SelectRows(Source, each not Text.StartsWith([Name], "~$")), 
  FilterRows1 = Table.SelectRows(FilterRows, each ([Extension] = ".xlsm")), 
  RemoveOtherColumns = Table.SelectColumns(FilterRows1, {"Content"}), 
  InvokeCustomFunction = Table.AddColumn(
    RemoveOtherColumns, 
    "Budget Model Function", 
    each #"Budget Model Function"([Content])
  ), 
  RemoveOtherColumns1 = Table.SelectColumns(InvokeCustomFunction, {"Budget Model Function"}), 
  ExpandBudgetModelFunction = Table.ExpandTableColumn(
    RemoveOtherColumns1, 
    "Budget Model Function", 
    {
      "Channel", 
      "Brand", 
      "SKU", 
      "Description", 
      "Attribute", 
      "Financial Year", 
      "Jun", 
      "May", 
      "Apr", 
      "Mar", 
      "Feb", 
      "Jan", 
      "Dec", 
      "Nov", 
      "Oct", 
      "Sep", 
      "Aug", 
      "Jul"
    }, 
    {
      "Channel", 
      "Brand", 
      "SKU", 
      "Description", 
      "Attribute", 
      "Financial Year", 
      "Jun", 
      "May", 
      "Apr", 
      "Mar", 
      "Feb", 
      "Jan", 
      "Dec", 
      "Nov", 
      "Oct", 
      "Sep", 
      "Aug", 
      "Jul"
    }
  )
in
  ExpandBudgetModelFunction