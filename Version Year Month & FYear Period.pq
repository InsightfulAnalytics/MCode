


// FYearPeriod Text blank query

let
    Source = "",
    DateMonth = Date.Month(LastActDate),
    PeriodText = 
    
        if
            DateMonth < 10 and DateMonth > 6
        then
            "0" & Number.ToText(DateMonth - 6 )
        else 
            if
                DateMonth < 7
            then
                "0" & Number.ToText(DateMonth + 6 )
            else 
                Number.ToText(DateMonth),
    FYear = Date.Year(LastActDate),
    FYearText = 

        if
            DateMonth > 7 
        then
            Number.ToText(FYear + 1 )
        else
            Number.ToText(FYear ),

    FYearPeriod = FYearText & PeriodText

in
    FYearPeriod

//Version Number

= Table.AddColumn(ConstrainedCost, "Version Number", each FYearPeriod , Number.Type)

//Version

= Table.AddColumn(AddVersionNumber, "Version", each Date.ToText( LastActDate , [Format="MMM yyy"] ) & " FC" , Text.Type)


// "Jul 2022 FC"


