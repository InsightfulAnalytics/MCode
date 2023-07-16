let
    Source = Odbc.Query("dsn=_Data_01_MSSQL", "SELECT#(lf)#(tab)Inv_Dt_YYYYmm * 1#(tab)     AS YYYYMM,#(lf)#(tab)inv_dt#(tab)#(tab)#(tab)#(tab)#(tab) AS 'Invoice Date',#(lf)#(tab)TRIM(AltCustName)#(tab)#(tab) AS Customer,#(lf)#(tab)TRIM(item_no)#(tab)#(tab) #(tab) AS SKU,#(lf)#(tab)TRIM(item_desc_1)#(tab) #(tab) AS Product,#(lf)#(tab)TRIM(prod_cat_desc)#(tab)#(tab) AS Brand,#(lf)#(tab)SUM(qty_to_ship)#(tab)#(tab) AS Qty,#(lf)#(tab)SUM(sls_amt)#(tab)#(tab)#(tab) AS Sales,#(lf)#(tab)SUM(cost_amt)#(tab)#(tab) #(tab) AS Cost#(lf)FROM#(lf)#(tab)v_Tim_OE_Sales_history_all_data #(lf)WHERE#(lf)#(tab)prod_cat * 1 > 19#(tab)AND#(lf)#(tab)Inv_Dt_YYYYmm * 1 > 202106#(lf)GROUP BY#(lf)#(tab)Inv_Dt_YYYYmm,#(lf)#(tab)inv_dt,#(lf)#(tab)TRIM(AltCustName),#(lf)#(tab)TRIM(item_no),#(lf)#(tab)TRIM(item_desc_1),#(lf)#(tab)TRIM(prod_cat_desc)#(tab);"),
    FilterYYYYMM = Table.SelectRows(Source, each [YYYYMM] >= YYYYMM),
    AddGmColumn = Table.AddColumn(FilterYYYYMM, "GM", each [Sales]-[Cost], Number.Type),

    AddGmPercentColumn = 
        Table.AddColumn(
            AddGmColumn,
            "GM %", 
            each try
            // 
                if (if Number.IsNaN(([GM] / [Sales])) then 0 else ([GM] / [Sales]))
                = Number.NegativeInfinity
                then
                0
                else if Number.IsNaN(([GM] / [Sales])) then
                0
                else
                ([GM] / [Sales])
            otherwise
            0, 
            Number.Type),
    AddAspColumn = 
         Table.AddColumn(
            AddGmPercentColumn, 
            "ASP", 
            each try
            
                if (if Number.IsNaN(([Sales]/[Qty])) then 0 else ([Sales]/[Qty]))
                = Number.NegativeInfinity
                then
                0
                else if Number.IsNaN(([Sales]/[Qty])) then
                0
                else
                ([Sales]/[Qty])
            otherwise
            0,
            Number.Type),

    AddAcgColumn = 
        Table.AddColumn(
            AddAspColumn, 
            "ACG", 
            each try
            
                if (if Number.IsNaN(([Cost]/[Qty])) then 0 else ([Cost]/[Qty]))
                = Number.NegativeInfinity
                then
                0
                else if Number.IsNaN(([Cost]/[Qty])) then
                0
                else
                ([Cost]/[Qty])
            otherwise
            0),

    AddStartOfMonthDate = 
        Table.AddColumn( 
            AddAcgColumn , 
            "Date.1", 
            each Date.FromText(
                "1/" &
                Text.End([Date],2) &
                "/" &
                Text.Start([Date],4)	
            )
        , Date.Type),

    
    DuplicateDate = Table.DuplicateColumn( AddStartOfMonthDate , "Date.1", "Year"),
    ExtractYear = Table.TransformColumns( DuplicateDate ,{{"Year", Date.Year, Int64.Type}}),
    DuplicateDateForMonth = Table.DuplicateColumn( ExtractYear , "Date.1", "Month"),
    ExtractMonth = Table.TransformColumns( DuplicateDateForMonth ,{{"Month", Date.Month, Int64.Type}})
in
    
    ExtractMonth