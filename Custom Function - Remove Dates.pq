
//Uses a custom function to remove date from the Reference column (GL reference column)
let
    RemoveDate = (text as text) as text =>
    let
        // split text by space
        splitText = Text.Split(text, " "),
        
        // remove strings matching date format
        noDateText = List.Transform(splitText, each if Text.Length(_) = 8 and Text.Middle(_, 2, 1) = "." and Text.Middle(_, 5, 1) = "." then "" else _),
        
        // combine text back together
        finalText = Text.Combine(noDateText, " ")
    in
        finalText,

    Source = Odbc.Query("dsn=_Data_01_MSSQL", "SELECT #(tab)#(lf)#(tab)#(tab)LEFT(gltrxhst_sql.mn_no,5) #(tab)#(tab)AS 'GL'#(lf)#(tab)#(tab), LEFT(gltrxhst_sql.sb_no,2) #(tab)AS 'CC'#(lf)#(tab)#(tab), SYACTFIL_SQL.acct_desc #(tab)#(tab)AS 'Account Description'#(lf)#(tab)#(tab), gltrxhst_sql.trx_dt#(tab)#(tab)#(tab)AS 'Date'#(lf)#(tab)#(tab), gltrxhst_sql.trx_amt#(tab)#(tab)#(tab)AS 'Amount'#(lf)#(tab)#(tab), gltrxhst_sql.trx_src#(tab)#(tab)#(tab)AS 'Trx Source'#(lf)#(tab)#(tab), gltrxhst_sql.reference#(tab)#(tab)AS 'Reference'#(lf)#(tab)#(tab), gltrxhst_sql.user_name#(tab)#(tab)AS 'User'#(lf)#(tab)#(tab), gltrxhst_sql.pkg_id#(tab)#(tab)#(tab)AS 'Pkg ID'#(lf)#(tab)#(tab), gltrxhst_sql.jnl_no#(tab)#(tab)#(tab)AS 'Journal Number'#(lf)#(tab)#(tab), gltrxhst_sql.batch_no #(tab)#(tab)AS 'Batch Number'#(lf)FROM #(tab) #(lf)#(tab)#(tab)DATA_001.dbo.gltrxhst_sql gltrxhst_sql#(lf)#(tab)#(tab)#(lf)JOIN#(lf)#(tab)#(tab)DATA_001.dbo.SYACTFIL_SQL SYACTFIL_SQL#(lf)ON#(lf)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)(SYACTFIL_SQL.mn_no=gltrxhst_sql.mn_no) AND#(lf)#(tab)#(tab)#(tab)(SYACTFIL_SQL.sb_no=gltrxhst_sql.sb_no)#(lf)#(tab)#(tab))#(lf)WHERE #(tab)#(lf)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)LEFT(gltrxhst_sql.mn_no,5)  >= 47111#(tab)  AND #(lf)#(tab)#(tab)#(tab)LEFT(gltrxhst_sql.mn_no,5)  <= 47576#(tab)  #(lf)#(tab)#(tab))"),
    TypeDate1 = Table.TransformColumnTypes(Source,{{"Date", type text}}),
    TypeDate2 = Table.TransformColumnTypes(TypeDate1,{{"Date", type date}}),
    FilterDateFrom = Table.SelectRows(TypeDate2, each [Date] >= FyStart ),
    FilterDateTo = Table.SelectRows(FilterDateFrom, each [Date] <= DateTo ),
    FilterOutACCRUE = Table.SelectRows(FilterDateTo, each ([Trx Source] <> "ACCRUE    ")),
    SortByDate = Table.Sort(FilterOutACCRUE,{{"Date", Order.Ascending}, {"Reference", Order.Ascending}}),
    RemoveColumns = Table.RemoveColumns(SortByDate,{"User", "Pkg ID", "Journal Number", "Batch Number"}),
    CopyReferenceColumn = Table.AddColumn(RemoveColumns, "GL Reference", each [Reference] , Text.Type ),
    
    // use custom function to remove dates
    ChangedType = Table.TransformColumns(CopyReferenceColumn, {{"Reference", RemoveDate}})
in
    ChangedType


