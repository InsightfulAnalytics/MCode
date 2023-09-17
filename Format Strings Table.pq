
//Format strings table, load into blank query

    let
        Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WckwuKU3MUdJRUtZRVjaw1gBTmkC+oVKsTrRSSEZ+aXFiXkoxTIUOkGEElvLNzMnJzM9DyICkjJViYwE=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Format = _t, #"Format String" = _t, Sort = _t]),
        SortRows = Table.Sort(Source,{{"Sort", Order.Ascending}})
    in
        SortRows