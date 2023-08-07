
let
    Source = Excel.Workbook(Web.Contents("https://keypharmau.sharepoint.com/sites/KeyBrandMarketing/Shared%20Documents/Finance%20Reporting/A&P%20Tracker/A&P%20Tracker%20FY24_20230727%20v3-5.xlsm"), null, true),
    ANTIVIRAL_Sheet = Source{[Item="ANTIVIRAL",Kind="Sheet"]}[Data],
    RemoveOtherColumns = Table.SelectColumns(ANTIVIRAL_Sheet,{"Column1", "Column2", "Column3", "Column4", "Column5", "Column6" , "Column7" }),
    BrandNameDrillDown = RemoveOtherColumns{0}[Column2],
    RemoveTopRows = Table.Skip(RemoveOtherColumns,2),
    FilterOutNullAmount = Table.SelectRows(RemoveTopRows, each ([Column7] <> null)),
    PromoteHeaders = Table.PromoteHeaders(FilterOutNullAmount, [PromoteAllScalars=true]),
    ChangeTypes = Table.TransformColumnTypes(PromoteHeaders,{{"Account", type text}, {"Account Description", type text}, {"Project", type text}, {"Activity Description", type text}, {"Status", type text}, {"Month of Promo Activity", type text}, {"Invoice Amount#(lf)(Excl. GST)", type number}}),
    AddBrandColumn = Table.AddColumn(
    ChangeTypes, 
    "Brand",
        each
            BrandNameDrillDown
    , Text.Type
),
    RenameColumns = Table.RenameColumns(AddBrandColumn,{{"Invoice Amount#(lf)(Excl. GST)", "Amount"}}),
    AddDateColumn = Table.AddColumn(
    RenameColumns, 
    "Activity Date",
        each
            if  [Month of Promo Activity] = "Jul"   then    #date(2023,7,1) else
            if  [Month of Promo Activity] = "Aug"   then    #date(2023,8,1) else
            if  [Month of Promo Activity] = "Sep"   then    #date(2023,9,1) else
            if  [Month of Promo Activity] = "Oct"   then    #date(2023,10,1) else
            if  [Month of Promo Activity] = "Nov"   then    #date(2023,11,1) else
            if  [Month of Promo Activity] = "Dec"   then    #date(2023,12,1) else
            if  [Month of Promo Activity] = "Jan"   then    #date(2024,1,1) else
            if  [Month of Promo Activity] = "Feb"   then    #date(2024,2,1) else
            if  [Month of Promo Activity] = "Mar"   then    #date(2024,3,1) else
            if  [Month of Promo Activity] = "Apr"   then    #date(2024,4,1) else
            if  [Month of Promo Activity] = "May"   then    #date(2024,5,1) else
            if  [Month of Promo Activity] = "Jun"   then    #date(2024,6,1) else
                #date(2030,7,1)
    , Date.Type
)
in
    AddDateColumn

    //

    (Sheet)=>

    RemoveOtherColumns = Table.SelectColumns(Sheet,{"Column1", "Column2", "Column3", "Column4", "Column5", "Column6" , "Column7" }),
    BrandNameDrillDown = RemoveOtherColumns{0}[Column2],
    RemoveTopRows = Table.Skip(RemoveOtherColumns,2),
    FilterOutNullAmount = Table.SelectRows(RemoveTopRows, each ([Column7] <> null)),
    PromoteHeaders = Table.PromoteHeaders(FilterOutNullAmount, [PromoteAllScalars=true]),
    ChangeTypes = Table.TransformColumnTypes(PromoteHeaders,{{"Account", type text}, {"Account Description", type text}, {"Project", type text}, {"Activity Description", type text}, {"Status", type text}, {"Month of Promo Activity", type text}, {"Invoice Amount#(lf)(Excl. GST)", type number}}),
    AddBrandColumn = Table.AddColumn(
        ChangeTypes, 
        "Brand",
            each
                BrandNameDrillDown
        , Text.Type
    ),
    RenameColumns = Table.RenameColumns(AddBrandColumn,{{"Invoice Amount#(lf)(Excl. GST)", "Amount"}}),
    AddDateColumn = Table.AddColumn(
    RenameColumns, 
    "Activity Date",
        each
            if  [Month of Promo Activity] = "Jul"   then    #date(2023,7,1) else
            if  [Month of Promo Activity] = "Aug"   then    #date(2023,8,1) else
            if  [Month of Promo Activity] = "Sep"   then    #date(2023,9,1) else
            if  [Month of Promo Activity] = "Oct"   then    #date(2023,10,1) else
            if  [Month of Promo Activity] = "Nov"   then    #date(2023,11,1) else
            if  [Month of Promo Activity] = "Dec"   then    #date(2023,12,1) else
            if  [Month of Promo Activity] = "Jan"   then    #date(2024,1,1) else
            if  [Month of Promo Activity] = "Feb"   then    #date(2024,2,1) else
            if  [Month of Promo Activity] = "Mar"   then    #date(2024,3,1) else
            if  [Month of Promo Activity] = "Apr"   then    #date(2024,4,1) else
            if  [Month of Promo Activity] = "May"   then    #date(2024,5,1) else
            if  [Month of Promo Activity] = "Jun"   then    #date(2024,6,1) else
                #date(2030,7,1)
    , Date.Type
)
in
    AddDateColumn

///

let
    Source = Odbc.Query("dsn=_Data_01_MSSQL", "/* Range of accounts query for marketing accruals actuals transaction level  */#(lf)#(lf)#(tab)SELECT #(tab)#(lf)#(tab)#(tab)LEFT(gltrxhst_sql.mn_no,5) #(tab)#(tab)AS 'GL'#(lf)#(tab)#(tab), LEFT(gltrxhst_sql.sb_no,2) #(tab)AS 'CC'#(lf)#(tab)#(tab), SYACTFIL_SQL.acct_desc#(tab)#(tab)AS 'GL Description'#(lf)#(tab)#(tab), gltrxhst_sql.trx_dt#(tab)#(tab)#(tab)AS 'Date'#(lf)#(tab)#(tab), gltrxhst_sql.trx_amt#(tab)#(tab)#(tab)AS 'Amount'#(lf)#(tab)#(tab), gltrxhst_sql.reference#(tab)#(tab)AS 'Reference'#(lf)#(tab)#(tab), gltrxhst_sql.trx_src#(tab)#(tab)#(tab)AS 'Source'#(lf)#(tab)FROM#(lf)#(tab) #(tab)DATA_001.dbo.gltrxhst_sql gltrxhst_sql#(lf)#(tab)#(tab), DATA_001.dbo.SYACTFIL_SQL SYACTFIL_SQL#(lf)#(tab)WHERE #(tab)#(lf)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)#(tab)#(tab)LEFT(gltrxhst_sql.mn_no,5) >= 45611#(tab)#(tab)#(lf)#(tab)#(tab)#(tab)#(tab)AND#(tab)LEFT(gltrxhst_sql.mn_no,5) <= 90138#(lf)#(tab)#(tab)#(tab))#(tab)AND #(lf)#(tab)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)#(tab)#(tab)LEFT(gltrxhst_sql.sb_no,2) = 18#(lf)#(tab)#(tab)#(tab))#(tab)AND#(lf)#(tab)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)#(tab)#(tab)gltrxhst_sql.trx_dt>= 20230701 #(tab)#(tab)#(lf)#(tab)#(tab)#(tab)#(tab)AND#(tab)(SYACTFIL_SQL.mn_no=gltrxhst_sql.mn_no) #(lf)#(tab)#(tab)#(tab)#(tab)AND (SYACTFIL_SQL.sb_no=gltrxhst_sql.sb_no)#(lf)#(tab)#(tab)#(tab))#(lf)#(tab)#(tab))"),
    DateType1 = Table.TransformColumnTypes(Source,{{"Date", type text}}),
    DateType2 = Table.TransformColumnTypes(DateType1,{{"Date", type date}}),
    MergeQueries = Table.NestedJoin(DateType2, {"GL", "CC"}, #"GL Groups P&L Summary", {"GL", "CC"}, "LedgerList", JoinKind.Inner),
    ExpandCategoryBrand = Table.ExpandTableColumn(MergeQueries, "LedgerList", {"Category", "Brand"}, {"Category", "Brand"})
in
    ExpandCategoryBrand



