

section Section1;

shared zDL_Payfile_Syd = let
    Source = Folder.Files("\\casino.internal\\Data\\SYD\\Groups\\Scheduling\\Financial Reports\\Pay Files\\F08 & F30"),
    #"Filtered rows" = Table.SelectRows(Source, each ([Extension] = ".csv")),
    #"Filtered rows 1" = Table.SelectRows(#"Filtered rows", each [Date created] > #datetime(2023, 6, 30, 0, 0, 0)),
    #"Lowercased text" = Table.TransformColumns(#"Filtered rows 1", {{"Name", each Text.Lower(_), type text}}),
    #"Filtered rows 2" = Table.SelectRows(#"Lowercased text", each Text.Contains([Name], "sent")),
    #"Filtered hidden files" = Table.SelectRows(#"Filtered rows 2", each [Attributes]?[Hidden]? <> true),
    #"Invoke custom function" = Table.AddColumn(#"Filtered hidden files", "Transform file", each #"Transform file"([Content])),
    #"Removed other columns" = Table.SelectColumns(#"Invoke custom function", {"Transform file"}),
    #"Expanded table column" = Table.ExpandTableColumn(#"Removed other columns", "Transform file", Table.ColumnNames(#"Transform file"(#"Sample file")))
in
    #"Expanded table column";

shared #"Sample file" = let
    Source = Folder.Files("\\casino.internal\\Data\\SYD\\Groups\\Scheduling\\Financial Reports\\Pay Files\\F08 & F30"),
    #"Filtered rows" = Table.SelectRows(Source, each [Extension] = ".csv"),
    #"Filtered rows 1" = Table.SelectRows(#"Filtered rows", each [Date created] > #datetime(2023, 6, 30, 0, 0, 0)),
    #"Lowercased text" = Table.TransformColumns(#"Filtered rows 1", {{"Name", each Text.Lower(_), type text}}),
    #"Filtered rows 2" = Table.SelectRows(#"Lowercased text", each Text.Contains([Name], "sent")),
    #"Filtered hidden files" = Table.SelectRows(#"Filtered rows 2", each [Attributes]?[Hidden]? <> true),
    Navigation = #"Filtered hidden files"{0}[Content]
in
    Navigation;

shared Parameter = let
    Parameter = #"Sample file" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type binary, BinaryIdentifier = #"Sample file"]
in
    Parameter;

shared #"Transform Sample file" = let
    Source = Csv.Document(Parameter, [Delimiter = ",", Columns = 19, QuoteStyle = QuoteStyle.None]),
    #"Promoted headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true])
in
    #"Promoted headers";

// function
[FunctionQueryBinding = "{\"exemplarFormulaName\":\"Transform Sample file\"}"]

shared #"Transform file" = let
    #"Transform file" = (Parameter as binary) => let
        Source = Csv.Document(Parameter, [Delimiter = ",", Columns = 19, QuoteStyle = QuoteStyle.None]),
        #"Promoted headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true])
    in
        #"Promoted headers"
in
    #"Transform file";





