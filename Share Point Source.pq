
//Connect to a file saved in sharepoint

let

    Source = SharePoint.Files("https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/", [ApiVersion = 15]),
    Filter = Table.SelectRows(Source, each ([Name] = "Order Type Codes.xlsx")),
    Navigation = Filter{0}[Content],
    ImportExcelWorkbook = Excel.Workbook(Navigation),
    FilterRows = Table.SelectRows(ImportExcelWorkbook, each ([Kind] = "Table")),
    RemoveOtherColumns = Table.SelectColumns(FilterRows,{"Data"}),
    ExpandData = Table.ExpandTableColumn(RemoveOtherColumns, "Data", {"Order Type", "Order Type SB", "Order Type Combined", "Description", "Comment", "Type"}, {"Order Type", "Order Type SB", "Order Type Combined", "Description", "Comment", "Type"}),
    ChangeType = Table.TransformColumnTypes(ExpandData,{{"Order Type", type text}, {"Order Type SB", type text}, {"Order Type Combined", type text}, {"Description", type text}, {"Comment", type text}, {"Type", type text}})

in

    ChangeType  