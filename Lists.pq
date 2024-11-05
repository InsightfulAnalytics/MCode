
/* working with lists */

//  add cumulative sum column using a list

    = Table.AddColumn(ReorderColumns, "CumulativeSum", each List.Sum(List.FirstN(Table.Column(ReorderColumns, "Amount"), [Index] + 1)), type number)

//

    = 
    Table.AddColumn(
        ReorderColumns,
        "Remove24Bud",
        each 
            List.ContainsAny(
                {}
                
            )
    )

/////////

// Change all column types to text
    ChangeColumnTypes =
        Table.TransformColumnTypes(
            SheetData,
            List.Transform(
                Table.ColumnNames(SheetData),  
            each {_, Text.Type}
            )
        ),




//////

// duplicate rows that are between start and end date

    let
    Source = Table.Group(
        FactEpisodes, 
        {"AdmissionDate", "EpisodeID", "DischargeDate", "PatientCategoryCode"}, 
        {{"Count", each Table.RowCount(_), Int64.Type}}
    ), 
    FilterRows = Table.SelectRows(
        Source, 
        each (
        [PatientCategoryCode]
            <> "C"
            and [PatientCategoryCode] <> "PAU"
            and [PatientCategoryCode] <> "SDM"
        )
    ), 
    RemoveColumns = Table.RemoveColumns(FilterRows, {"Count"}), 
    // Calculate the number of days between AdmissionDate and DischargeDate
    AddedDuration = Table.AddColumn(
        RemoveColumns, 
        "DayCount", 
        each Duration.Days([DischargeDate] - [AdmissionDate])
    ), 
    // Add a custom column that generates a list of dates from AdmissionDate to (DischargeDate - 1 day)
    AddedDateList = Table.AddColumn(
        AddedDuration, 
        "Date", 
        each 
        if [DayCount] > 0 then
            List.Dates([AdmissionDate], [DayCount], #duration(1, 0, 0, 0))
        else
            {[AdmissionDate]} // If DayCount is 0 or negative, keep the AdmissionDate
    ), 
    // Expand the DateList column to create new rows
    ExpandedDateList = Table.ExpandListColumn(AddedDateList, "Date"), 
    // Remove unnecessary columns (optional)
    RemovedColumns = Table.RemoveColumns(ExpandedDateList, {"AdmissionDate", "DayCount"}), 
    ChangeType = Table.TransformColumnTypes(RemovedColumns, {{"Date", type date}})
    in
    ChangeType

/////









