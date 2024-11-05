

    /* Create dim table for small multiple totals, use with many to many relationship 
        Relationship is Single cross filter direction from small multiple to dim table (small multiple filters dim)
        */

        let
        Source = DimSRG, 
        DuplicateColumn = Table.DuplicateColumn(Source, "SRGCode", "SRGCode - Copy"), 
        UnpivotColumn = Table.UnpivotOtherColumns(
            DuplicateColumn, 
            {"SRGDescription"}, 
            "Attribute", 
            "Value"
        ), 
        AddConditionalColumn = Table.AddColumn(
            UnpivotColumn, 
            "Custom", 
            each if Text.Contains([Attribute], "Copy") then "Total Market Share" else [SRGDescription]
        ), 
        RemoveOtherColumns = Table.SelectColumns(AddConditionalColumn, {"Custom", "Value"}), 
        RenameColumns = Table.RenameColumns(RemoveOtherColumns, {{"Value", "SRG Code"}}), 
        ChangeTypes = Table.TransformColumnTypes(RenameColumns, {{"Custom", type text}}), 
        RenameColumnCustom = Table.RenameColumns(ChangeTypes, {{"Custom", "Group"}})
        in
        RenameColumnCustom


  ////

















