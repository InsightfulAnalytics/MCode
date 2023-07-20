let
    Source = Excel.Workbook(File.Contents("M:\Budget & LE's\11. Brand Planning FY24-25\Brand Plan P&L FY24-25.xlsm"), null, true),
    FilterOutHSheets = Table.SelectRows(Source, each not Text.StartsWith([Name], "h_")),
    FilterOutOtherKind = Table.SelectRows(FilterOutHSheets, each ([Kind] = "Sheet")),
    RemoveColumnsKeepData = Table.SelectColumns(FilterOutOtherKind,{"Data"}),
    InvokeCustomFunction = Table.AddColumn(RemoveColumnsKeepData, "Fy23 Brand P&L Sheet Function", each #"Fy23 Brand P&L Sheet Function"([Data])),
    KeepFunctionColumn = Table.RemoveColumns(InvokeCustomFunction,{"Data"}),
    ExpandSheetFunction = Table.ExpandTableColumn(KeepFunctionColumn, "Fy23 Brand P&L Sheet Function", {"Group", "Category", "Channel", "Brand", "Attribute", "Value"}, {"Group", "Category", "Channel", "Brand", "Attribute", "Value"}),
    ChangeTypes = Table.TransformColumnTypes(ExpandSheetFunction,{{"Group", type text}, {"Category", type text}, {"Channel", type text}, {"Brand", type text}, {"Attribute", type date}, {"Value", type number}}),
    ReplaceStarInChannelColumn = Table.ReplaceValue(ChangeTypes,"*","",Replacer.ReplaceValue,{"Channel"}),
    RenameDateColumn = Table.RenameColumns(ReplaceStarInChannelColumn,{{"Attribute", "Date"}}),
    FilterOutZeros = Table.SelectRows(RenameDateColumn, each ([Value] <> 0)),
    //Financial Year from date
    FinancialYear
        = Table.AddColumn(
            FilterOutZeros, 
            "Financial Year", 
            each
                //
                
                if
                    Date.Month([Date]) > 6
                then 
                    Date.Year([Date]) +1
                else
                    Date.Year([Date])
                
                //
            , Number.Type
            ),

    //Period from date
    Period
        = Table.AddColumn(
            FinancialYear, 
            "Period", 
            each

                //
                if
                    Date.Month([Date]) > 6
                then 
                    Date.Month([Date]) - 6
                else
                    Date.Month([Date]) + 6
                //
            , Number.Type
            ),
            

    // Year from Financial Year
    Year
        = Table.AddColumn(
            Period, 
            "Year", 
            each
                //
                
                if
                    [Period] > 6 
                then
                    [Financial Year] 
                else
                    [Financial Year] - 1
                
                //
            , Number.Type
            ),

    //Get Month number from period
    Month
        = Table.AddColumn(
            Year, 
            "Month", 
            each
                //
            
                if
                    [Period] > 6 
                then
                    [Period] - 6
                else
                    [Period] + 6

                //
            , Number.Type
            ),
    RenameValueToAmount = Table.RenameColumns(Month,{{"Value", "Amount"}}),
    AddTypeColumn = Table.AddColumn(RenameValueToAmount, "Type", each "Mar LE" , Text.Type ),
    ReplaceNotEqualToSigns = Table.ReplaceValue(AddTypeColumn,"<>Supplier rebate","Landing Charge Variance",Replacer.ReplaceValue,{"Category"}),
    FilterOutOperatingExpenses = Table.SelectRows(ReplaceNotEqualToSigns, each ([Group] <> "Operating Expenses"))

in
    FilterOutOperatingExpenses

////

let
    Source = Excel.Workbook(Web.Contents("https://keypharmau.sharepoint.com/sites/PowerBIDataFiles/Shared%20Documents/Reference%20Files/Order%20Type%20Codes.xlsx"), null, true),
    tbl_Order_Types_Table = Source{[Item="tbl_Order_Types",Kind="Table"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(tbl_Order_Types_Table,{{"Order Type", type text}, {"Order Type SB", type text}, {"Order Type Combined", type text}, {"Description", type text}, {"Comment", type text}, {"Type", type text}})
in
    #"Changed Type"


    ///testing 