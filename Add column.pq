


////////// add a column

= Table.AddColumn(
    AddColumnSales, 
    "Cost", 
    each [Constrained Qty] * [ACG],
    Number.Type
)



////////// add a column

= Table.AddColumn(
    RenameColumns, 
    "SKU", 
    each 
        if
            [SKU.1] 
        is 
            null
        then
            [SKU.2]
        else
            [SKU.1]
    ,
    Text.Type
)

////////// add a column

= Table.AddColumn(
    RenamePrice, 
    "Old Price", 
    each 
        if
            [Old Price.1] 
        is 
            null
        then
            [New Price.1]
        else
            [Old Price.1]
    ,
    Number.Type
)

////////// add a column

= Table.AddColumn(
    ExpandACGsOct2022, 
    "New ACG", 
    each 
        if
            [Oct 2022 ACGs] 
        is 
            null
        then
            [ACG]
        else
            [Oct 2022 ACGs] 
    ,
    Number.Type
)

////////// add a column

= Table.AddColumn(
    RemovePriceColumns, 
    "Price Change", 
    each 
        [New Price] - [Old Price]
    ,
    Number.Type
)


////////



= // delete from here after acg changes are loaded

Table.AddColumn(
	RemoveColumnFypChannel, 
	"YYYYMM", 
	each
		//
		
		if
			[Period] < 10
		then
			Number.ToText([Financial Year]) & "0" & Number.ToText([Period]) 
		else
			Number.ToText([Financial Year])  & Number.ToText([Period]) 
		
		//
	, Number.Type
)

// ASP working

=Table.AddColumn(
	RenameFabAsp, 
	"Adjusted ASP", 
	each
		//
		
		if
			[New ASP] = null
		then
			[FAB ASP]
		else
			[New ASP]
		
		//
	, Number.Type
)

// Adjusted Sales

=Table.AddColumn(
	AdjUncSales, 
	"Adjusted Sales", 
	each
		//
		
        [Adjusted ASP] * [FAB Units]
		
		//
	, Number.Type
)

// FYFYPP from Fy & Period

=Table.AddColumn(
	RenameFyear, 
	"FYFYPP", 
	each
		//
		
        if
            [Period] < 10
        then
            Number.ToText([FYear] )& "0" & Number.ToText([Period])
        else
            Number.ToText([FYear] )& Number.ToText([Period])
		//
	, Number.Type
)

// 

=Table.AddColumn(
	ExpandPriceChanges, 
	"Adjusted ASP", 
	each
		//
		
		if
			[Price Changes.Effective Date] = null
		then
			[ASP]
		else

			if
                [Price Changes.Effective Date] >= [Invoice Date]
            then
                [Price Changes.Old Price]
            else
                [ASP]
		
		//
	, Number.Type
)

//////

=Table.AddColumn(
	TransposeTable, 
	"Column1and2", 
	each
		//
		
        if
            [Column1] is null
        then
            [Column2]
        else
            if
                [Column2] is null
            then
                [Column1]
            else
                //[Column1] & " ; " & [Column2]
                [Column2]
		//
	, Text.Type
)

///////////

=Table.AddColumn(
	ChangeTypes, 
	"GTIN-Trunc", 
	each
		// Truncate the first number of the GTINS
        Text.End(
            [GTIN] , 
            Text.Length([GTIN]  ) -1
        )
		//
	, Text.Type
)


// Column to calculate the old ACG if the new ACG is effective

ManualAcgColumn
    =Table.AddColumn(
        ExpandCostIncreases , 
        "Manual ACG", 
        each
            // 
            if
                [New ACG] is null
            then
                [ACG]
            else
                if
                    [Invoice Date] >= [Date Increase Effective]
                then
                    [Current ACG]
                else
                    [ACG]
            //
        , Number.Type
    )

// 

=Table.AddColumn(
	FilterDate , 
	"Manual ASP", 
	each
		// Divide with error handling
        try   
            if
                [Price Increase Effect] = 0
            then
                0
            else
                [Price Increase Effect] / [Sales Actual]
        otherwise
            0
		//
	, Number.Type
)

    // Column to calculate Cost Increase Effect
    CostIncreaseEffect
        =Table.AddColumn(
            ManualCostColumn , 
            "Cost Increase Effect", 
            each
                // 
                [Cost] - [Adjusted Cost]
                //
            , Number.Type
        )

= Table.AddColumn(
	SortRows , 
	"Cost Increase % Effect", 
	each
		// Divide with error handling
        try   
            if
                [Cost Increase Effect] = 0
            then
                0
            else
                [Cost Increase Effect] / [Sales With Old ACG]
        otherwise
            0
		//
	, Number.Type
)


////

= Table.AddColumn(
    Source,
    "State",
    each

        if Text.Contains([Ship To Address], "NSW") 
        then "NSW" 
        else 
            if Text.Contains([Ship To Address], "VIC") 
            then "VIC" 
            else 
                if Text.Contains([Ship To Address], "QLD") 
                then "QLD" 
                else 
                    if Text.Contains([Ship To Address], "TAS") 
                    then "TAS" 
                    else 
                        if Text.Contains([Ship To Address], "SA") 
                        then "SA" 
                        else 
                            if Text.Contains([Ship To Address], "NT") 
                            then "NT" 
                            else 
                                if Text.Contains([Ship To Address], "WA") 
                                then "WA" 
                                else 
                                    if Text.Contains([Ship To Address], "ACT") 
                                    then "ACT" 
                                    else "Other"
    , 
    Text.Type
)

///

=Table.AddColumn(
	StateColumn, 
	"Rebate %", 
	each
		// 
        if
            Text.Contains([Customer] , "Drakes") and
            Text.Contains([State] , "SA")
        then
            0.03
        else
            0
		//
	, Number.Type
)

///

=Table.AddColumn(
	RebateColumn, 
	"Rebate Amount", 
	each
		[#"Rebate %"] * [Sales]
		//
	, Number.Type
)

///

=Table.AddColumn(
	FilterRows, 
	"Brand Num", 
	each
		//
        Number.FromText([#"Cat #"])
		//
	, Number.Type
)

///////

= Table.AddColumn(
	ReplaceNullsAcgVariance, 
	"New ACG", 
	each
		//
        [ACG] + [ACG Variance]
		//
	, Number.Type
)

////

= Table.AddColumn(
	NewAcgColumn, 
	"New Cost", 
	each
		//
        [New ACG] * [Qty]
		//
	, Number.Type
)

////


= Table.AddColumn(
	NewCostColumn, 
	"Cost Variance", 
	each
		//
        [Cost] - [New Cost]
		//
	, Number.Type
)


////

= Table.AddColumn(
	ChangeType, 
	"ACG Variance", 
	each
		//
        [New ACG] - [Current ACG]
		//
	, Number.Type
)

////

= Table.SelectRows(
    Source, 
    each 
        [mn_no] <> "00050" and
        [mn_no] <> "00051" and
        [mn_no] <> "00055" and
        [mn_no] <> "00056" and
        [mn_no] <> "00057" and
        [mn_no] <> "00058" and        
        [mn_no] <> "00059" and
        [mn_no] <> "00060" and
        [mn_no] <> "00061" and
        [mn_no] <> "00062" and
        [mn_no] <> "00063" and
        [mn_no] <> "00064"

)

////////

= Table.AddColumn(
	AdjustedAspColumn , 
	"Manual ASP", 
	each
		// 
        if
            [Price Changes.Effective Date] is null
        then
            [ASP]
        else
            if
                [Invoice Date] >= [Price Changes.Effective Date]
            then
                [Price Changes.Old Price]
            else
                [ASP]
		//
	, Number.Type
)

////////

= Table.AddColumn(
	AdjustedAspColumn , 
	"Manual ASP", 
	each
		// 
        if
            [Price Changes.Effective Date] is null
        then
            [ASP]
        else
            if
                [Customer] = "C.W.Management"
            then
                [ASP]
            else
                if
                    [Invoice Date] >= [Price Changes.Effective Date]
                then
                    [Price Changes.Old Price]
                else
                    [ASP]
		//
	, Number.Type
)

////

= Table.AddColumn(
	ExpandeGTINMapping, 
	"SKU", 
	each
		//  
		if
			[Key SKU] = null
		then
			[Vendor Style]
		else
			[Key SKU]
		//
	, Text.Type

)

////

= Table.AddColumn(
	CombineSKU, 
	"SKU Final", 
	each
		//  
		if
			[SKU] = ""
		then
			[GTIN Mapping Main.GTIN]
		else
			[SKU]
		//
	, Text.Type

)

GTIN Mapping Main.Key SKU


///

= Table.AddColumn(
	ReplaceBlankWithNull, 
	"SKU Final", 
	each
		//  
		if
			[SKU] = null
		then
			[GTIN Mapping Main.Key SKU]
		else
			[SKU]
		//
	, Text.Type

)

///

= Table.AddColumn(
	AudWithGstColumn, 
	"Payment Due Date", 
	each
		//  
		Date.AddDays([Request Date] , [AP Terms])
		//
	, Date.Type
)

///

= Table.AddColumn(
	PaymentDueDate, 
	"Total Using Last Cost With GST", 
	each
		//  
		if
            [GST] = "GSTI "
        then
            [Total Using Last Cost] * 1.1
        else
            [Total Using Last Cost]
		//
	, Number.Type

)

///

= Table.AddColumn(
	DateType, 
	"Total AUD With GST", 
	each
		//  
		if
            [GST] = "GSTI "
        then
            [Total Value AUD] * 1.1
        else
            [Total Value AUD]
		//
	, Number.Type

)

///

= Table.AddColumn(
	ExpandDemandForecast, 
	"Combined Qty", 
	each
		//  
		if
            [Demand Qty Forecast.Qty] = null
        then
            [Qty]
        else
            [Demand Qty Forecast.Qty]
		//
	, Int64.Type
)

///

= Table.AddColumn(
	PaymentDueDate, 
	"Total Using Last Cost With GST", 
	each
		//  
        if
            [Manufacturing PO] = "M"
        then
            [Order Qty] * [Value Added Cost Rate]
        else
            if
                [GST] = "GSTI "
            then
                [Total Using Last Cost] * 1.1
            else
                [Total Using Last Cost]
		//
	, Number.Type

)

///

= Table.AddColumn(
	LastCostGstColumn, 
	"Total Using Average Cost With GST", 
	each
		//  
            if
                [GST] = "GSTI "
            then
                [Total Using Average Cost] * 1.1
            else
                [Total Using Average Cost]
		//
	, Number.Type

)

///

= Table.AddColumn(
	LastCostGstColumn, 
	"Total Using Average Cost With GST", 
	each
		//  
        if
            [Manufacturing PO] = "M"
        then
            [Order Qty] * [Value Added Cost Rate]
        else
            if
                [GST] = "GSTI "
            then
                [Total Using Average Cost] * 1.1
            else
                [Total Using Average Cost]
		//
	, Number.Type

)

//

= Table.AddColumn(
	ApTermsType, 
	"Payment Due Date", 
	each
		//  
        try
		Date.AddDays([Due Date] , [AP Terms])
        otherwise [Due Date]
		//
	, Date.Type
)

/////

= Table.AddColumn(
	FilterOrderTypeCP, 
	"Total With GST", 
	each
		//  
        if
            [Manufacturing PO] = "M"
        then
            [Order Qty] * [Value Added Cost Rate]
        else
            if
                [Average Unit Cost] = 0
            then
                if
                    [GST] = "GSTI "
                then
                    [Total Using Last Cost] * 1.1
                else
                    [Total Using Last Cost]
            else
                if
                    [GST] = "GSTI "
                then
                    [Total Using Average Cost] * 1.1
                else
                    [Total Using Average Cost]
		//
	, Number.Type
)

///

= Table.AddColumn(
	LastCostGstColumn, 
	"Total Using Average Cost With GST", 
	each
		//  
        if
            [Manufacturing PO] = "M"
        then
            [Order Qty] * [Value Added Cost Rate]
        else
            if
                [GST] = "GSTI "
            then
                [Total Using Average Cost] * 1.1
            else
                [Total Using Average Cost]
		//
	, Number.Type

)

///

= Table.AddColumn(
	ExpandBgfAspAcg, 
	"Sales", 
	each
		//  
            [ASP] * [Qty]
		//
	, Number.Type

)

///

= Table.AddColumn(
	ExpandACGList, 
	"Cost", 
	each
		//  
            [ACG] * [Combined Qty]
		//
	, Number.Type

)

//

        Table.AddColumn(
            ConsolidatedQtyColumn, 
            "Combined Sales", 
            each
                //  
                if
                    [Demand Qty Forecast.Sales] = null
                then
                    [Sales]
                else
                    [Demand Qty Forecast.Sales]
                //
            , Number.Type
        )


//

        Table.AddColumn(
            ConsolidatedSalesColumn, 
            "Combined Cost", 
            each
                //  
                if
                    [Demand Qty Forecast.Cost] = null
                then
                    [Cost]
                else
                    [Demand Qty Forecast.Cost]
                //
            , Number.Type
        )

///

= Table.AddColumn(
	RenameCostAfterFixColumn, 
	"Cost", 
	each
		//  
            if
                [ACG Increases March 2023.ACG] is null
            then
                [Cost After Fix]
            else
                [ACG Increases March 2023.ACG] * [Qty]
		//
	, Number.Type

)

///

= Table.AddColumn(
	RenameColumns, 
	"PO Date", 
	each
        // catch any errors
        try
            // convert the PO Date Text to a usable date using neted ifs
            if
                // if the PO Date Text contains a slash
                Text.Contains(
                    [PO Date Text], "/"
                )
            then
                // then convert it from MM/DD/YYYY to the date DD/MM/YYYY
                Date.FromText(
                    Text.End([PO Date Text],4) &
                    "," &
                    Text.Start([PO Date Text],2)	&
                    "," &
                    Text.Middle([PO Date Text],3,2)    
                )
            else
                if
                    // if the date is a length of 12 characters
                    Text.Length([PO Date Text]) = 12
                then
                    //then convert to date format DD/MM/YYYY
                    Date.FromText(
                        Text.Start([PO Date Text],4) &
                        "," &
                        Text.Middle([PO Date Text],4,2)	&
                        "," &
                        Text.Middle([PO Date Text],6,2)    
                )
                else
                    // if length is 8 then convert to date DD/MM/YYYY
                    if
                        // if the date is a length of 8 characters
                        Text.Length([PO Date Text]) = 8
                    then
                        //then convert to date format DD/MM/YYYY
                        Date.FromText(
                            Text.Start([PO Date Text],4) &
                            "," &
                            Text.Middle([PO Date Text],4,2)	&
                            "," &
                            Text.Middle([PO Date Text],6,2)    
                    )
                    else
                        // if length is > 12 then convert to DD/MM/YYYY
                        if
                            Text.Length([PO Date Text]) > 12
                        then
                            //then convert to date format DD/MM/YYYY
                            Date.FromText(
                                Text.Start([PO Date Text],4) &
                                "," &
                                Text.Middle([PO Date Text],4,2)	&
                                "," &
                                Text.Middle([PO Date Text],6,2)    
                            )                            
                        else
                            // any other unplanned eventualities will return the PO date field
                            // and will cause an error becuase this won't be in the date format
                            // EXPECT ERROR HERE - NEED ANOTHER NESTED IF FOR UNPLANNED DATE 
                            [PO Date Text]
        // if error is thrown, return date
        otherwise #date (1900,1,1)
        //
	, Date.Type

)

////

= Table.AddColumn(
	ColumnPODate, 
	"Requested Date", 
	each
        try
            // convert the requested Delivery date to a usable date using neted ifs
            if
                // if the requested delivery date contains a slash
                Text.Contains(
                    [Requested Delivery Date], "/"
                )
            then
                // then convert it from MM/DD/YYYY to the date DD/MM/YYYY
                Date.FromText(
                    Text.End([Requested Delivery Date],4) &
                    "," &
                    Text.Start([Requested Delivery Date],2)	&
                    "," &
                    Text.Middle([Requested Delivery Date],3,2)    
                )
            else
                if
                    // if the date is a length of 12 characters
                    Text.Length([Requested Delivery Date]) = 12
                then
                    //then convert to date format DD/MM/YYYY
                    Date.FromText(
                        Text.Start([Requested Delivery Date],4) &
                        "," &
                        Text.Middle([Requested Delivery Date],4,2)	&
                        "," &
                        Text.Middle([Requested Delivery Date],6,2)    
                )
                else
                    // if length is 8 then convert to date DD/MM/YYYY
                    if
                        // if the date is a length of 8 characters
                        Text.Length([Requested Delivery Date]) = 8
                    then
                        //then convert to date format DD/MM/YYYY
                        Date.FromText(
                            Text.Start([Requested Delivery Date],4) &
                            "," &
                            Text.Middle([Requested Delivery Date],4,2)	&
                            "," &
                            Text.Middle([Requested Delivery Date],6,2)    
                    )
                    else
                        // any other unplanned eventualities will return the PO Date
                        [PO Date]
        // error handling, some requested dates are null so return PO Date if error
        otherwise [PO Date]
    //
	, Date.Type

)


///


= Table.AddColumn(
	AddClaimInvoiceNumberColumn, 
	"Banner And Type", 
	each
		[Banner] & " - " & [Expense Type]
	, Text.Type

)

///


= Table.AddColumn(
	ReorderColumns, 
	"Effective Date", 
	each
    ///
		#date(2023,8,1)
    ///
	, Date.Type
)

///

= Table.AddColumn(
	AddEffectiveDateColumn, 
	"Channel", 
	each
    ///
		"PHARMACY"
    ///
	, Text.Type
)

///

= Table.AddColumn(
	ExpandPharmacyPriceChanges, 
	"New Sales", 
	each
    ///
		if
            [Effective Date] is null
        then
            [Sales]
        else
            if
                [Effective Date] >= [Date]
            then
                [Qty] * [NEW PRICE]
            else
                [Sales]
        ///
        , Number.Type
    )

///

= Table.AddColumn(
	RenameColumns, 
	"Sales Variance", 
	each
    ///
		[New Sales] - [Sales] 
    ///
	, Number.Type
)

///


= Table.AddColumn(
	AddEffectiveDateColumn, 
	"Increase %", 
	each
    ///
		[Increase Amount] / [Current ASP]
    ///
	, Number.Type
)

///

= Table.AddColumn(
	ChangeFabAspType, 
	"NEW PRICE", 
	each
    ///
		[Fab Asp] *  1 + [Increase Percent]
    ///
	, Number.Type
)

///

= Table.AddColumn(
	ExpandSupermarket, 
	"New Sales SM", 
	each
    ///
		if
            [Supermarket.Effective Date] is null
        then
            [New Sales]
        else
            if
                [Date]  >= [Supermarket.Effective Date] 
            then
                ((1 + [Supermarket.Increase Percent]) * [Current ASP]) * [Qty]
            else
                [New Sales]
        ///
        , Number.Type
    )

//////

= Table.AddColumn(
    ReplaceValue, 
    "Constrained Qty",
        each 
            if
                [Qty] = null
            then
                0
            else 
                if
                    [Type] = "Actual"
                then
                    [Qty]
                else
                    if
                        [Type] = "Forecast" and
                        [Qty] - [Qty Constraints] < 0 
                    then
                        0
                    else
                        [Qty] - [Qty Constraints]
                
    , Number.Type
)

//////

= Table.AddColumn(
    ReplaceValue, 
    "Constrained Qty",
        each 
            if
                [Qty] = null
            then
                0
            else 
                
    , Number.Type
)


//////

= Table.AddColumn(
    ReplaceValue, 
    "Constrained Qty",
        each 
            if
                [AvCost] + [LastCost] = 0
            then
                [ACG]
            else 
                
    , Number.Type
)

//////

= Table.AddColumn(
    Source, 
    "Max Cost",
        each 
            if
                [AvCost] > [LastCost] 
            then
                [AvCost]
            else 
                [LastCost]
    , Number.Type
)

//////

= Table.AddColumn(
    ExpandAverageLastCost, 
    "Adjusted ACG",
        each 
            if
                [ACG] > [Max Av Last Cost] 
            then
                [ACG]
            else 
                [Max Av Last Cost]
    , Number.Type
)

//////

= Table.AddColumn(
    HigherOfAcgAndSystemCost, 
    "Adjusted Cost",
        each 
            [Adjusted ACG] * [Qty]
    , Number.Type
)

//////

= Table.AddColumn(
    HigherOfAcgAndSystemCost, 
    "Adjusted Cost",
        each 
            [Adjusted ACG] * [Qty]
    , Number.Type
)

//////

= Table.AddColumn(
    AdjustedCost, 
    "Cost Increase",
        each 
            [Cost] - [Adjusted Cost]
    , Number.Type
)

//////

= Table.AddColumn(
    ExpandDemandFC, 
    "Qty Variance",
        each 
            [Qty] - [Demand Qty Forecast.Qty]
    , Number.Type
)

//////

= Table.AddColumn(
    MaxOfAvLastCost, 
    "Max All Cost ",
        each 
            if
                [Max Av Last Cost] > [NPD.ACG] 
            then
                [Max Av Last Cost]
            else 
                [NPD.ACG]
    , Number.Type
)

Max Av Last Cost

//////

= Table.AddColumn(
    ExpandAcgIncreases, 
    "Cost New",
        each 
            [Qty] * [Adjusted ACG]
    , Number.Type
)

//////

= Table.AddColumn(
    RemoveColumns, 
    "Adjusted End Date",
        each 
           if
                [RPR Type] = "Evergreen"
           then
                #date(2024,8,31)
           else 
                [Calc Contract End Date]
    , Date.Type
)


///

= Table.AddColumn(
    AdjustedDateColumn, 
    "Adjusted Contract Term",
        each 
           Number.Round(Number.From(([Adjusted End Date] - [Contract Start Date])/( 365.25 / 12 )) ,0 )
    , Number.Type
)

///

= Table.AddColumn(
    MonthlyTcvColumn, 
    "Adjusted TCV",
        each 
           [Monthly TCV] * [Adjusted Contract Term]
    , Number.Type
)

///

= Table.AddColumn(
    GroupRowsWithoutDates, 
    "ASP",
        each 
           [Sales] / [Qty]
    , Number.Type
)

////

= Table.AddColumn(
    AspColumn, 
    "ACG",
        each 
           [Cost] / [Qty]
    , Number.Type
)

//////

= Table.AddColumn(
    AspColumn, 
    "ACG",
        each 
           [Cost] / [Qty]
    , Number.Type
)

//////

= Table.AddColumn(
    ExpandNPD, 
    "ASP Merged",
        each

            if
                [ASP.1] = null 
            then
                [ASP]
            else
                [ASP.1]

    , Number.Type
)

//////

= Table.AddColumn(
    MergeAsp, 
    "ACG Merged",
        each

            if
                [ACG.1] = null 
            then
                [ACG]
            else
                [ACG.1]

    , Number.Type
)

//

let
    CurrentDate = DateTime.LocalNow(),
    DateFourMonthsAgo = Date.AddMonths(DateTime.LocalNow(), -4)
in
    DateFourMonthsAgo


///

let
    Source = Odbc.Query("dsn=_Data_01_MSSQL", "-- SKU Average and Last Cost#(lf)#(lf)SELECT DISTINCT#(lf)        TRIM(im.item_no)   #(tab)#(tab)AS 'SKU'#(lf)        ,TRIM(im.loc)           AS 'Location'#(lf)        ,il.avg_cost            AS 'AvCost'#(lf)        ,il.last_cost#(tab)#(tab)#(tab)AS 'LastCost'#(lf)FROM   #(lf)        data_001.dbo.imitmidx_sql #(tab)im #(tab)#(tab)-- item master for all SKU list#(lf)JOIN#(lf)        data_001.dbo.IMINVLOC_SQL #(tab)il #(tab)#(tab)-- location and average cost details#(lf)ON#(lf)        im.item_no + im.loc = il.item_no + il.loc"),
    MaxOfAvLastCost = Table.AddColumn(
    Source, 
    "Max Av Last Cost",
        each 
            if
                [AvCost] > [LastCost] 
            then
                [AvCost]
            else 
                [LastCost]
    , Number.Type
)
in
    MaxOfAvLastCost

///


= Table.AddColumn(
    ExpandAverageLastCost, 
    "ACG Merged",
        each

            // if Macola acg is null then use fab acg, if fab acg is null use npd acg, or Macola acg for all else

            if
                [Macola.ACG] = null 
            then
                [FAB.ACG]
            else
                [Macola.ACG]

    , Number.Type
)

/////

= Table.AddColumn(
    RemoveWorkingAspAcg, 
    "Asp Acg isnull",
        each

            if
                [ACG] = null 
            then
                1
            else
                if
                    [ASP] = null
                then
                    1
                else
                    0
                
    , Number.Type
)

//////

= Table.AddColumn(
    FilterOutZeroQty, 
    "FAB.ASP",
        each

        [Sales] / [Qty]

    , Number.Type
)



//////

= Table.AddColumn(
    CalculateAspColumn, 
    "FAB.ACG",
        each

        [Cost] / [Qty]

    , Number.Type
)



//////

= Table.AddColumn(
    AspColumn, 
    "Asp",
        each

        if
            [Amended.ASP] = null
        then
            [Current ASP]
        else
            [Amended.ASP]

    , Number.Type
)

//

let
    Source = Odbc.Query("dsn=_Data_01_MSSQL", "SELECT#(lf)#(tab)CONCAT(#(lf)        CONVERT(varchar , '1/') ,#(lf)        CONVERT(varchar , RIGHT(Inv_Dt_YYYYmm, 2) ) ,#(lf)        '/' ,#(lf)        CONVERT(varchar, LEFT(Inv_Dt_YYYYmm,4) )#(lf)#(tab))       #(tab)             AS 'Date',#(lf)#(tab)TRIM(AltCustName)#(tab)#(tab) AS Customer,#(lf)#(tab)TRIM(item_no)#(tab)#(tab) #(tab) AS SKU,#(lf)#(tab)TRIM(item_desc_1)#(tab) #(tab) AS Product,#(lf)#(tab)TRIM(prod_cat_desc)#(tab)#(tab) AS Brand,#(lf)#(tab)SUM(qty_to_ship)#(tab)#(tab) AS Qty,#(lf)#(tab)SUM(sls_amt)#(tab)#(tab)#(tab) AS Sales#(lf)FROM#(lf)#(tab)v_Tim_OE_Sales_history_all_data #(lf)WHERE#(lf)#(tab)prod_cat * 1 > 19#(tab)#(tab)#(tab)#(tab)AND#(lf)#(tab)Inv_Dt_YYYYmm * 1 > 202206#(tab)#(tab)AND#(lf)#(tab)TRIM(AltCustName) = 'National Pharmacies' AND#(lf)#(tab)(qty_to_ship) <> 0#(lf)GROUP BY#(lf)#(tab)CONCAT(#(lf)        CONVERT(varchar , '1/') ,#(lf)        CONVERT(varchar , RIGHT(Inv_Dt_YYYYmm, 2) ) ,#(lf)        '/' ,#(lf)        CONVERT(varchar, LEFT(Inv_Dt_YYYYmm,4) )#(lf)#(tab)), #(lf)#(tab)TRIM(AltCustName),#(lf)#(tab)TRIM(item_no),#(lf)#(tab)TRIM(item_desc_1),#(lf)#(tab)TRIM(prod_cat_desc)#(tab);"),
    ChangeType = Table.TransformColumnTypes(Source,{{"Date", type date}}),
    SortRows = Table.Sort(ChangeType,{{"Date", Order.Ascending}}),
    AddCustom = Table.AddColumn(SortRows, "Rebate %", each 0.08, Number.Type),
    AddCustom1 = Table.AddColumn(AddCustom, "Rebate $", each Number.Round( [#"Rebate %"] * [Sales] ,2 ), Number.Type)
in
    AddCustom1


//////

= Table.AddColumn(
    ChangeType, 
    "Date",
        each

        Date.ToText([Column1], "yyyyMM") 

    , Text.Type
) 


//////

= Table.AddColumn(
    ChangeType, 
    "Date",
        each

        Date.ToText([Column1], "yyyyMM") 

    , Text.Type
) 

///

Text.Remove(
        _,
        {"0".."9"}
        )

//////

= Table.AddColumn(
    ReorderColumns, 
    "ASP Variance",
        each

        if
            [Macola.ASP] = null
        then
            null
        else
            [FAB.ASP] - [Macola.ASP]

    , Number.Type
)

//////

= Table.AddColumn(
    AspVariance, 
    "ACG Variance",
        each

        if
            [Macola.ACG] = null
        then
            null
        else
            [FAB.ACG] - [Macola.ACG]

    , Number.Type
)

//////

= Table.AddColumn(
    AcgVariance, 
    "Sales Impact",
        each

        if
            [Macola.ASP] = null
        then
            null
        else
            [Qty] * [FAB.ASP]

    , Number.Type
)

//////

= Table.AddColumn(
    SalesImpact , 
    "Cost Impact",
        each

        if
            [Macola.ACG] = null
        then
            null
        else
            [Qty] * [ACG Variance]

    , Number.Type
)

//////

= Table.AddColumn(
    AppendGrandTotal , 
    "Reference",
        each

        if
            [Invoice Date] = null
        then
            "7-Eleven Stores"
        else
            "7-Eleven Rebate " & Date.ToText([Invoice Date] , "MMM-yyyy" )

    , Number.Type
)