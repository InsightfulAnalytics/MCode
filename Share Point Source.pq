/*
    Connect to a file saved in sharepoint 
    sample for Microsoft Sharepoint site file
*/

    // MS sharepoint things

        let
            // Go to sharepoint site, navigate to the documents site, copy past the web URL, 
            // delete everything after and including the "Shared%", for example, the below is from address:
            // https://microsoftapc.sharepoint.com/teams/TimOsbornPbiFiles/Shared%20Documents/Forms/AllItems.aspx?viewid=db6b39d4%2Dd2f6%2D43f8%2Dab90%2D08d6fa4e6391
            Source = SharePoint.Files(
                "https://microsoftapc.sharepoint.com/teams/TimOsbornPbiFiles/", 
                [ApiVersion = 15]
            ), 

            // Filter by the specific file name 
            Filter = Table.SelectRows(Source, each ([Name] = "Cp2_Sales_Forecast.xlsx")), 

            // Filter on the first file in the list
            Navigation = Filter{0}[Content], 

            // Access the Excel Workbook contents (import)
            ImportExcelWorkbook = Excel.Workbook(Navigation), 

            // Filter by table object only, no sheets or other objects
            FilterRows = Table.SelectRows(ImportExcelWorkbook, each ([Kind] = "Table")), 

            // Data columns only
            RemoveOtherColumns = Table.SelectColumns(FilterRows, {"Data"}), 

            // Expand Columns
            ExpandData = Table.ExpandTableColumn(
                RemoveOtherColumns, 
                "Data", 
                {"Forecast", "Sales"}, 
                {"Forecast", "Sales"}
            ), 

            // Change types
            ChangeTypes = Table.TransformColumnTypes(
                ExpandData, 
                {{"Forecast", type date}, {"Sales", type number}}
            )

        in
            // Display result
            ChangeTypes




/*//Connect to a file saved in sharepoint */

    // Acurio budget file,  sharepoint file, nested table transformations and function

        let
            Source = SharePoint.Files("https://acurioservices.sharepoint.com/sites/ITS", [ApiVersion = 15]),
            BudgetFile = Table.SelectRows(Source, each ([Name] = BudgetFileName )),
            DrillDown = BudgetFile{0}[Content],
            ImportExcelWorkbook = Excel.Workbook(DrillDown, null, true),
            KeepOnlyDataColumn = Table.SelectColumns(ImportExcelWorkbook, {"Data", "Item"}),
            NestedTablePromoteHeaders = Table.AddColumn(
                KeepOnlyDataColumn,
                "PromoteHeaders",
                each Table.PromoteHeaders([Data], [PromoteAllScalars = true])
            ),
            NestedTableAddItemColumn = Table.AddColumn(
                NestedTablePromoteHeaders,
                "TablesWithItem",
                (currentRow) =>
                let
                    item = currentRow[Item],
                    promotedTable = currentRow[PromoteHeaders],
                    newTable = Table.AddColumn(promotedTable, "Item", (_) => item)
                in
                    newTable
            ),
            ExpandTables = Table.Combine(NestedTableAddItemColumn[TablesWithItem]),
            UnpivotDatesValues = Table.UnpivotOtherColumns(ExpandTables, {"CostCentre", "Type", "Specialization", "Item"}, "Attribute", "Value"),
            ChangeColumnTypes = Table.TransformColumnTypes(
                UnpivotDatesValues,
                {
                {"CostCentre", type text},
                {"Type", type text},
                {"Specialization", type text},
                {"Attribute", type date},
                {"Value", type number},
                {"Item", type text}
                }
            )
        in
        ChangeColumnTypes

    //order type codes

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

    /////////

    //casefill report

        let
            Source = SharePoint.Files("https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/", [ApiVersion = 15]),
            FilterOutOtherFiles =  Table.SelectRows(Source, each ([Name] = "CSL Report.xlsb")),
            Navigation = FilterOutOtherFiles{0}[Content],
            ImportExcelWorkbook = Excel.Workbook(Navigation),
            KeepOnlyOosReportTable = Table.SelectRows(ImportExcelWorkbook, each ([Name] = "OOSReport")),
            RemoveOtherColumns = Table.SelectColumns(KeepOnlyOosReportTable,{"Data"}),
            ExpandData = Table.ExpandTableColumn(RemoveOtherColumns, "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}),
            RemoveNullRows = Table.SelectRows(ExpandData, each ([Column1] <> null)),
            PromoteHeaders = Table.PromoteHeaders(RemoveNullRows, [PromoteAllScalars=true]),
            RemoveColumns = Table.RemoveColumns(PromoteHeaders,{"OriginalChannel", "Line #", "Item Description", "Value", "Column20", "Column21", "Column22"}),
            ReplaceNullWithZero = Table.ReplaceValue(RemoveColumns,null,"0",Replacer.ReplaceValue,{ "Unsupplied Qty", "Quantity issued"}),
            ChangeTypes = Table.TransformColumnTypes(ReplaceNullWithZero,{{"Unsupplied Qty", type number}, {"Quantity issued", type number}, {"Supplier Code", type text}, {"Month", type date}, {"Channel", type text}, {"Customer", type text}, {"Brand", type text}, {"Product Code", type text}, {"Reason Code", type text}, {"OriginalCustomer", type text}, {"Purchase order", type text}, {"Order Date", type date}, {"Delivery Docket #", type text}, {"State", type text}, {"Item Code (SKU)", type text}})
        in
            ChangeTypes


    /////

   // "SFA & Bias SKU Exclusions.xlsm"

        let
            Source = SharePoint.Files("https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/", [ApiVersion = 15]),
            FilterOutOtherFiles =  Table.SelectRows(Source, each ([Name] = "SFA & Bias SKU Exclusions.xlsm")),
            Navigation = FilterOutOtherFiles{0}[Content],
            ImportExcelWorkbook = Excel.Workbook(Navigation),
            tbl_Ex_Products_Table = ImportExcelWorkbook{[Item="tbl_Ex_Products",Kind="Table"]}[Data],
            UnpivotOtherColumns = Table.UnpivotOtherColumns(tbl_Ex_Products_Table, {"Brand Number", "Brand", "SKU", "Product Name"}, "Attribute", "Value"),
            ChangeTypes = Table.TransformColumnTypes(UnpivotOtherColumns,{{"Brand Number", type text}, {"Brand", type text}, {"SKU", type text}, {"Product Name", type text}, {"Attribute", type date}, {"Value", type text}}   ),
            RenameColumns = Table.RenameColumns(ChangeTypes,{{"Value", "Exclude"}, {"Attribute", "Date"}})
        in
            RenameColumns

//

/*//Connect to a foler saved in sharepoint */

    // Old code local files parameter, new code uses sharepoint online for file source ( Source = Folder.Files(#"API Data"), )
    Source = SharePoint.Files("https://keypharmau.sharepoint.com/sites/PowerBIDataFiles", [ApiVersion = 15]),



