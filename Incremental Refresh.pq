
/*
  Power Query (M), incremental refresh without Query Folding with SQL native Query.
  taken from: https://learn.microsoft.com/en-us/power-bi/connect-data/incremental-refresh-overview#query-folding

*/
    let
    Query = 
        "select * from dbo.FactInternetSales where OrderDateKey >= '"&
        Text.From(
            Int32.From( 
                DateTime.ToText(RangeStart,"yyyyMMdd") 
            )
        ) &
        "' and OrderDateKey < '"& 
            Text.From(
                Int32.From( 
                    DateTime.ToText(RangeEnd,"yyyyMMdd") 
                )
            ) &
        "' ",

    Source = 
        Sql.Database("BIGPUN","AdvWorksDW2012"),  // Server & Database
    Data = 
        Value.NativeQuery(Source, Query, null, [EnableFolding=false])
        
    in
    Data

//