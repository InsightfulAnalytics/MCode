//Financial Year from date

= Table.AddColumn(
	ChangeType, 
	"Financial Year", 
	each
		//
		
		if
			Date.Month([Date]) > 6
		then 
			Date.Year([Date]) +1
		else
			Date.Year([Date])
		
		//
	, Number.Type
	)
	
..............

//Period from date

= Table.AddColumn(
	FYear, 
	"Period", 
	each

		//
		if
			Date.Month([Date]) > 6
		then 
			Date.Month([Date]) - 6
		else
			Date.Month([Date]) + 6
		//
	, Number.Type
	)
	
.....................

// Year from Financial Year


= Table.AddColumn(
	MonthNumber, 
	"Month", 
	each
		//
		
		if
			[Period] > 6 
		then
			[Financial Year] 
		else
			[Financial Year] - 1
		
		//
	, Number.Type
	)

.........................

//Get Month number from period

= Table.AddColumn(
	RemoveMonthName, 
	"Month", 
	each
		//
	
		if
			[Period] > 6 
		then
			[Period] - 6
		else
			[Period] + 6

		//
	, Number.Type
	)

/////////////////////

//Convert Year & Month to Date

= Table.AddColumn(
	Year, 
	"Date", 
	each
		//
	
		#date(
			[Year],
			[Month],
			1
		)

		//
	, Number.Type
	)



..................


if
	Number.FromText(Text.End([Inv_Dt_YYYYmm],2)) > 6
then
	Number.FromText(Text.End([Inv_Dt_YYYYmm],2)) - 6
else 
	Number.FromText(Text.End([Inv_Dt_YYYYmm],2)) + 6


if
	Number.FromText(Text.End([Inv_Dt_YYYYmm],2)) > 6
then
	Number.FromText(Text.Start([Inv_Dt_YYYYmm],4)) +1
else 
	Number.FromText(Text.Start([Inv_Dt_YYYYmm],4)) +1



Number.ToText([Financial Year]) & (
if
	Text.Length(Number.ToText([Period])) > 1
then
	Number.ToText([Period])
else
	"0" & Number.ToText([Period])
)

=
if
	(if
		Date.Month(DateTime.LocalNow()) > 6
	then 
		Date.Month(DateTime.LocalNow()) - 6
	else
		Date.Month(DateTime.LocalNow()) + 6
	) -1 = 0
then
	12
else
	(if
		Date.Month(DateTime.LocalNow()) > 6
	then 
		Date.Month(DateTime.LocalNow()) - 6
	else
		Date.Month(DateTime.LocalNow()) + 6
	) -1
	

= Date.Month(DateTime.LocalNow())



//full date from text YYYYMMDD

if 		
	Date.FromText(
		Text.End([request_dt],2) &
		"," &
		Text.Middle([request_dt],4,2) &
		"," &
		Text.Start([request_dt],4)	
	)
then
	0 
else
	Date.FromText(
		Text.End([request_dt],2) &
		"/" &
		Text.Middle([request_dt],4,2) &
		"/" &
		Text.Start([request_dt],4)	
	)	

//Full date sting as a number


Date.MonthName(#date(2011, 12, 31), "en-US")


//Get month name and year and combine together as text

	Date.MonthName(
		#date(
		Number.FromText(Text.Start([Inv_Dt_YYYYmm],4)) ,
		Number.FromText(Text.End([Inv_Dt_YYYYmm],2)) ,
		 1) ,
		"en-US"
	)
	//MonthName from Inv_Dt_YYYYmm

& " " &
Number.ToText(
	Date.Year(
		#date(
		Number.FromText(Text.Start([Inv_Dt_YYYYmm],4)) ,
		Number.FromText(Text.End([Inv_Dt_YYYYmm],2)) ,
		 1)
	)
	//Year from Inv_Dt_YYYYmm
)

/////////

//If date greater than parameter date

= Table.AddColumn(
	FYear, 
	"Period", 
	each

		//



		//
	, Number.Type
	)
	
////////////

//Convert Year & Month to YYYYMM

= Table.AddColumn(
	Date, 
	"YYYYMM", 
	each
		//
		
		if
			[Month] < 10
		then
			Number.ToText([Year]) & "0" & Number.ToText([Month]) 
		else
			Number.ToText([Year])  & Number.ToText([Month]) 
		
		//
	, Number.Type
)

////////////////


= Table.AddColumn(
	ChangeType, 
	"Type", 
	each
		//
		
		if
			[YYYYMM] < 1stBudgetYYYYMM
		then
			"Actual"
		else
			"Budget"
		
		//
	, Text.Type
)

///////////////

//Convert YYYYMM to Date

= Table.AddColumn(
	Source, 
	"Date", 
	each
		//
	
		#date(
			Number.FromText(Text.Start([Inv_Dt_YYYYmm], 4) ) ,
            Number.FromText(Text.End([Inv_Dt_YYYYmm],2) ) ,
			1
		)

		//
	, Date.Type
	)


= Table.SelectRows(Source, each ([Name] = "BLISTEX.xlsm"))





//Convert YYYYMM to Date

= Table.AddColumn(
	ChangeDateType, 
	"Date", 
	each
		//
	
		#date(
			Number.FromText(Text.Start([YYYYMM], 4) ) ,
            Number.FromText(Text.End([YYYYMM],2) ) ,
			1
		)

		//
	, Date.Type
	)

////  Adding in || Fy - Period - Month - Year || from date column
    
    //Financial Year from date
    FinancialYear
        = Table.AddColumn(
            EndOfMonthColumn, 
            "Financial Year", 
            each
                //
                
                if
                    Date.Month([Date]) > 6
                then 
                    Date.Year([Date]) +1
                else
                    Date.Year([Date])
                
                //
            , Number.Type
            ),

    //Period from date
    Period
        = Table.AddColumn(
            FinancialYear, 
            "Period", 
            each

                //
                if
                    Date.Month([Date]) > 6
                then 
                    Date.Month([Date]) - 6
                else
                    Date.Month([Date]) + 6
                //
            , Number.Type
            ),
            

    // Year from Financial Year
    Year
        = Table.AddColumn(
            Period, 
            "Year", 
            each
                //
                
                if
                    [Period] > 6 
                then
                    [Financial Year] 
                else
                    [Financial Year] - 1
                
                //
            , Number.Type
            ),

    //Get Month number from period
    Month
        = Table.AddColumn(
            Year, 
            "Month", 
            each
                //
            
                if
                    [Period] > 6 
                then
                    [Period] - 6
                else
                    [Period] + 6

                //
            , Number.Type
            )

////////////

// DateOneYearAgo
let
    Source = Date.AddDays(Date.From(DateTime.LocalNow()),-365)
in
    Source


////

= Table.AddColumn(
    ChangeTypes, 
    "Order Month",
        each
            if  [Name] = "Jul"   then    #date(2023,7,1) else
            if  [Name] = "Aug"   then    #date(2023,8,1) else
            if  [Name] = "Sep"   then    #date(2023,9,1) else
            if  [Name] = "Oct"   then    #date(2023,10,1) else
            if  [Name] = "Nov"   then    #date(2023,11,1) else
            if  [Name] = "Dec"   then    #date(2023,12,1) else
            if  [Name] = "Jan"   then    #date(2024,1,1) else
            if  [Name] = "Feb"   then    #date(2024,2,1) else
            if  [Name] = "Mar"   then    #date(2024,3,1) else
            if  [Name] = "Apr"   then    #date(2024,4,1) else
            if  [Name] = "May"   then    #date(2024,5,1) else
            if  [Name] = "Jun"   then    #date(2024,6,1) else
                #date(2030,7,1)
    , Date.Type
)

////

= Table.AddColumn(
    ChangeTypes, 
    "Order Month",
        each
            if  [Name] = "July"   then    #date(2023,7,1) else
            if  [Name] = "August"   then    #date(2023,8,1) else
            if  [Name] = "September"   then    #date(2023,9,1) else
            if  [Name] = "October"   then    #date(2023,10,1) else
            if  [Name] = "November"   then    #date(2023,11,1) else
            if  [Name] = "December"   then    #date(2023,12,1) else
            if  [Name] = "January"   then    #date(2024,1,1) else
            if  [Name] = "February"   then    #date(2024,2,1) else
            if  [Name] = "March"   then    #date(2024,3,1) else
            if  [Name] = "April"   then    #date(2024,4,1) else
            if  [Name] = "May"   then    #date(2024,5,1) else
            if  [Name] = "June"   then    #date(2024,6,1) else
                "not found"
    , Date.Type
)
	