

(CsvFile) =>

let
    Source = Csv.Document(CsvFile, null, true),
    Budget_Model_Table = Source{[Item="Budget_Model",Kind="Table"]}[Data],
    FilterRows = Table.SelectRows(Budget_Model_Table, each ([Attribute] = "1 Qty" or [Attribute] = "2 ASP" or [Attribute] = "3 ACG" or [Attribute] = "4 Sales" or [Attribute] = "5 Cost"  )),
    RemoveOtherColumn = Table.SelectColumns(FilterRows,{  "Channel" , "Brand", "SKU", "Description"  , "Attribute", "Financial Year",  "Jun", "May", "Apr", "Mar", "Feb", "Jan", "Dec", "Nov", "Oct", "Sep", "Aug", "Jul" })
in
    RemoveOtherColumn


//budget model function

(ExcelFile) =>

let
    Source = Excel.Workbook(ExcelFile, null, true),
    Budget_Model_Table = Source{[Item="Budget_Model",Kind="Table"]}[Data],
    FilterRows = Table.SelectRows(Budget_Model_Table, each ([Attribute] = "1 Qty" or [Attribute] = "2 ASP" or [Attribute] = "3 ACG" or [Attribute] = "4 Sales" or [Attribute] = "5 Cost"  )),
    RemoveOtherColumn = Table.SelectColumns(FilterRows,{  "Channel" , "Brand", "SKU", "Description"  , "Attribute", "Financial Year",  "Jun", "May", "Apr", "Mar", "Feb", "Jan", "Dec", "Nov", "Oct", "Sep", "Aug", "Jul" })
in
    RemoveOtherColumn