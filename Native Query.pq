
// Filtering a native query with an M code parameter (Product)

    let
        Source = Sql.Database("BIGPUN", "AdvWorksDW2012", 
            [Query="SELECT * FROM AdvWorksDW2012.dbo.DimProduct WHERE EnglishProductName LIKE '%" & Product & "%'"])
    in
        Source

//