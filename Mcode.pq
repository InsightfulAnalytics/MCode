
let
    Source = Table.Group(FactEpisodes, {"AdmissionDate", "EpisodeID", "DischargeDate"}, {{"Count", each Table.RowCount(_), Int64.Type}}),
    RemoveColumns = Table.RemoveColumns(Source,{"Count"}),

    // Calculate the number of days between AdmissionDate and DischargeDate
    AddedDuration = Table.AddColumn(RemoveColumns, "DayCount", each Duration.Days([DischargeDate] - [AdmissionDate])),

    // Add a custom column that generates a list of dates from AdmissionDate to (DischargeDate - 1 day)
    AddedDateList = Table.AddColumn(AddedDuration, "DateList", each
        if [DayCount] > 0 then
            List.Dates([AdmissionDate], [DayCount], #duration(1, 0, 0, 0))
        else
            {[AdmissionDate]} // If DayCount is 0 or negative, keep the AdmissionDate
    ),

    // Expand the DateList column to create new rows
    ExpandedDateList = Table.ExpandListColumn(AddedDateList, "DateList"),

    // Rename the DateList column to AdmissionDate (if desired)
    RenamedColumns = Table.RenameColumns(ExpandedDateList, {{"DateList", "AdmissionDate Expanded"}}),

    // Remove unnecessary columns (optional)
    RemovedColumns = Table.RemoveColumns(RenamedColumns, {"AdmissionDate", "DayCount"}),

    // Reorder columns (optional)
    ReorderedColumns = Table.ReorderColumns(RemovedColumns, {"AdmissionDate Expanded", "EpisodeID", "DischargeDate"})
in
    ReorderedColumns
