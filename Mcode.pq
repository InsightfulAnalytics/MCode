
// GL Groups P&L Summary

let
    Source = Excel.Workbook(File.Contents("M:\Finance\Reporting\P&L\Profit & Loss Summary.xlsm"), null, true),
    tbl_GL_Groups_Table = Source{[Item="tbl_GL_Groups",Kind="Table"]}[Data],
    ChangeTypes = Table.TransformColumnTypes(tbl_GL_Groups_Table,{{"mn_no", type text}, {"GL", type text}, {"Acc & CC", type text}, {"Description", type text}, {"Category", type text}, {"Brand", type text}, {"Channel", type text}, {"Group", type text}, {"B/P", type text}, {"C/D", type text}, {"CC", type text}, {"Cost Centre", type text}, {"RS Group", type text}}),
    FilterRows = Table.SelectRows(ChangeTypes, each ([Group] = "Marketing") and ([Category] <> "Sample stock" and [Category] <> "Supplier rebate"))
in
    FilterRows


//

let
    Source = Odbc.Query("dsn=_Data_01_MSSQL", "/* Range of accounts query for marketing accruals actuals transaction level  */#(lf)#(lf)#(tab)SELECT #(tab)#(lf)#(tab)#(tab)LEFT(gltrxhst_sql.mn_no,5) #(tab)#(tab)AS 'GL'#(lf)#(tab)#(tab), LEFT(gltrxhst_sql.sb_no,2) #(tab)AS 'CC'#(lf)#(tab)#(tab), SYACTFIL_SQL.acct_desc#(tab)#(tab)AS 'GL Description'#(lf)#(tab)#(tab), gltrxhst_sql.trx_dt#(tab)#(tab)#(tab)AS 'Date'#(lf)#(tab)#(tab), gltrxhst_sql.trx_amt#(tab)#(tab)#(tab)AS 'Amount'#(lf)#(tab)#(tab), gltrxhst_sql.reference#(tab)#(tab)AS 'Reference'#(lf)#(tab)#(tab), gltrxhst_sql.trx_src#(tab)#(tab)#(tab)AS 'Source'#(lf)#(tab)FROM#(lf)#(tab) #(tab)DATA_001.dbo.gltrxhst_sql gltrxhst_sql#(lf)#(tab)#(tab), DATA_001.dbo.SYACTFIL_SQL SYACTFIL_SQL#(lf)#(tab)WHERE #(tab)#(lf)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)#(tab)#(tab)LEFT(gltrxhst_sql.mn_no,5) >= 45611#(tab)#(tab)#(lf)#(tab)#(tab)#(tab)#(tab)AND#(tab)LEFT(gltrxhst_sql.mn_no,5) <= 90138#(lf)#(tab)#(tab)#(tab))#(tab)AND #(lf)#(tab)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)#(tab)#(tab)LEFT(gltrxhst_sql.sb_no,2) = 18#(lf)#(tab)#(tab)#(tab))#(tab)AND#(lf)#(tab)#(tab)#(tab)(#(lf)#(tab)#(tab)#(tab)#(tab)#(tab)gltrxhst_sql.trx_dt>= 20230701 #(tab)#(tab)#(lf)#(tab)#(tab)#(tab)#(tab)AND#(tab)(SYACTFIL_SQL.mn_no=gltrxhst_sql.mn_no) #(lf)#(tab)#(tab)#(tab)#(tab)AND (SYACTFIL_SQL.sb_no=gltrxhst_sql.sb_no)#(lf)#(tab)#(tab)#(tab))#(lf)#(tab)#(tab))"),
    DateType1 = Table.TransformColumnTypes(Source,{{"Date", type text}}),
    DateType2 = Table.TransformColumnTypes(DateType1,{{"Date", type date}}),
    MergeQueries = Table.NestedJoin(DateType2, {"GL", "CC"}, #"GL Groups P&L Summary", {"GL", "CC"}, "LedgerList", JoinKind.Inner),
    ExpandCategoryBrand = Table.ExpandTableColumn(MergeQueries, "LedgerList", {"Category", "Brand"}, {"Category", "Brand"})
in
    ExpandCategoryBrand

  