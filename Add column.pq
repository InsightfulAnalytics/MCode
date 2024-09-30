



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
    FilterOutActualNullQty, 
    "ASP",
        each 
           [Sales] / [Qty]
    , Number.Type
)

////

= Table.AddColumn(
    ASPColumn, 
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
    RemoveSalesCost, 
    "Sales",
        each

        [ASP] * [Qty]

    , Number.Type
)



//////

= Table.AddColumn(
    ExpandCurrentFabAcg, 
    "Final ASP",
        each

            if
                [ASP] is null
            then
                [Current FAB ASP.ASP]
            else
                [ASP]

    , Number.Type
)

//////

= Table.AddColumn(
    FinalAspColumn, 
    "Final ACG",
        each

            if
                [ACG] is null
            then
                [Current FAB ACG.ACG]
            else
                [ACG]

    , Number.Type
)

//////

= Table.AddColumn(
    SalesColumn, 
    "Cost",
        each

            [Qty] * [ACG]

    , Number.Type
)

//////

= Table.AddColumn(
    CostColumn, 
    "Asp Acg Missing",
        each

            if
                [ASP] = null
            then
                ""
            else
                if
                    [ACG] = null
                then
                    ""
                else
                    "ok"

    , Text.Type
)

//////

= Table.AddColumn(
    RemoveMissingAspAcgColumn, 
    "YYYYMM",
        each

            Date.ToText ( [Date] , "yyyyMM" )
         
    , Text.Type
)

//////

= Table.AddColumn(
    ChangeYMColumnToNumber, 
    "Type",
        each
                "Forecast"
    , Text.Type
)

//////

= Table.AddColumn(
    FilterRows, 
    "ACG Increase",
        each
            [New ACG] - [Current ACG]
    , Number.Type
)

//////

= Table.AddColumn(
    AcgIncreaseColumn, 
    "ACG Increase %",
        each
            [ACG Increase] / [Current ACG]
    , Number.Type
)

//////

= Table.AddColumn(
    TransposeTable, 
    "Heading",
        each
            if
                [Column6] = null 
            then
                [Column7]
            else
                [Column6]

    , Text.Type
)

///////

= Table.AddColumn(
    RenameColumns, 
    "ASP",
        each

            if
                [Effective Date] = null
            then
                [Current ASP]
            else
                if
                    [Effective Date] > [Date]
                then
                    [Current ASP]
                else
                    [Current ASP] * (1 + [Percent Change] )

    , Number.Type
)

//////

= Table.AddColumn(
    NewAsp, 
    "New Sales",
        each
            [Qty] * [ASP]
    , Number.Type
)


//////

= Table.AddColumn(
    NewSales, 
    "Sales Increase",
        each
            [New Sales] - [Sales]
    , Number.Type
)

//////

= Table.AddColumn(
    GroupRows, 
    "Sales Increase Percent",
        each
        
            if
                [Sales Increase] <> 0
            then
                [Sales Increase] / [Sales]
            else
                0

    , Number.Type
)

//////

= Table.AddColumn(
    RemoveColumns, 
    "Date Of Increase",
        each
        
            if
                [Month] < #date(2023,7,1)
            then
                #date(2023,7,1)
            else
                [Month]

    , Date.Type
)

//////

= Table.AddColumn(
    RemoveColumns2, 
    "Merge SKU Date",
        each
        
            [SKU] & [Date Of Increase]

    , Text.Type
)

//////

= Table.AddColumn(
    RemoveColumns, 
    "ACG Merge Early",
        each

            if
                // for all rows where no cost chnages, return standard ACG
                [Date Effective] = null 
            then
                [Adjusted ACG]
            else
                if
                    [Date Effective] <= [Date]
                then
                    [New ACG]
                else
                    [Adjusted ACG]

    , Number.Type
)

//////

= Table.AddColumn(
    MergeAcg1, 
    "ACG Merge Late",
        each

            if
                // for all rows where no cost chnages, return standard ACG
                [Max Date.Date Effective] = null 
            then
                [ACG Merge Early]
            else
                if
                    [Max Date.Date Effective] <= [Date] 
                then
                    [Max Date.New ACG]
                else
                    [ACG Merge Early]

    , Number.Type
)

//////

= Table.AddColumn(
    RemoveColumns, 
    "ACG Merge1",
        each

            if
                [Date Effective] = null 
            then
                [Adjusted ACG]
            else
                if
                    [Date Effective]

    , Number.Type
)

//////

= Table.AddColumn(
    Merge2, 
    "Final ACG",
        each

            if
                [ACG Merge Late] > [Adjusted ACG]
            then
                [ACG Merge Late]
            else
                [Adjusted ACG]

    , Number.Type
)

//////

= Table.AddColumn(
    FinalAcg, 
    "Adjusted Cost Mo",
        each
            [Final ACG] * [Qty]

    , Number.Type
)

///////

= Table.AddColumn(
    FirstSaleDateTypeDate, 
    "Last Sale Date",
        each
            Date.AddDays([First Sale Date] , 365*3 )
    , Date.Type
)

///////

= Table.SelectRows(ExpandSkuBrandList, each [Date] >= FirstBudgetMonth)

///////

= Table.AddColumn(
    FilterCategories, 
    "Date",
        each
            #date([Year] , [Month] , 1 )
    , Date.Type
)

//

let
    Source = YourTable, // Replace YourTable with your actual table name
    MinDate = List.Min(Dates), // Get the minimum date from the "Dates" list
    MaxDate = List.Max(Dates), // Get the maximum date from the "Dates" list
    FilteredRows = Table.SelectRows(Source, each [Date] >= MinDate and [Date] <= MaxDate) // Filter the "Date" column in the table
in
    FilteredRows

///

let
    Source = Excel.Workbook(File.Contents("M:\Finance\Reporting\P&L\Profit & Loss Summary.xlsm"), null, true),
    Append_Table = Source{[Item="Append",Kind="Table"]}[Data],
    FilterCategories = Table.SelectRows(Append_Table, each ([Category] = "Parcel buy disc" or [Category] = "Sales")),
    DateColumn = 
        Table.AddColumn(
            FilterCategories, 
            "Date",
                each
                    #date([Year] , [Month] , 1 )
            , Date.Type
        )
    MinDate = List.Min(Dates), // Get the minimum date from the "Dates" list
    MaxDate = List.Max(Dates), // Get the maximum date from the "Dates" list
    FilteredDates = Table.SelectRows(DateColumn, each [Date] >= MinDate and [Date] <= MaxDate  ) // Filter the "Date" column in the table
in
    DateColumn

///

let
    Source = Excel.Workbook(Web.Contents("https://keypharmau.sharepoint.com/sites/KeyBrandMarketing/Shared%20Documents/Finance%20Reporting/A&P%20Tracker/A&P%20Tracker%20FY24_20230727%20v3-5.xlsm"), null, true),
    ANTIVIRAL_Sheet = Source{[Item="ANTIVIRAL",Kind="Sheet"]}[Data],
    RemoveOtherColumns = Table.SelectColumns(ANTIVIRAL_Sheet,{"Column1", "Column2", "Column3", "Column4", "Column5", "Column6" , "Column7" }),
    BrandNameDrillDown = RemoveTopRows{0}[Column2],
    RemoveTopRows = Table.Skip(RemoveOtherColumns,2)
in
    RemoveTopRows

//

= Table.AddColumn(
    ChangeTypes, 
    "Brand",
        each
            BrandNameDrillDown
    , Date.Type
)

//

= Table.AddColumn(
    RenameColumns, 
    "Activity Date",
        each
            if  [Month of Promo Activity] = "Jul"   then    #date(2023,7,1) else
            if  [Month of Promo Activity] = "Aug"   then    #date(2023,8,1) else
            if  [Month of Promo Activity] = "Sep"   then    #date(2023,9,1) else
            if  [Month of Promo Activity] = "Oct"   then    #date(2023,10,1) else
            if  [Month of Promo Activity] = "Nov"   then    #date(2023,11,1) else
            if  [Month of Promo Activity] = "Dec"   then    #date(2023,12,1) else
            if  [Month of Promo Activity] = "Jan"   then    #date(2024,1,1) else
            if  [Month of Promo Activity] = "Feb"   then    #date(2024,2,1) else
            if  [Month of Promo Activity] = "Mar"   then    #date(2024,3,1) else
            if  [Month of Promo Activity] = "Apr"   then    #date(2024,4,1) else
            if  [Month of Promo Activity] = "May"   then    #date(2024,5,1) else
            if  [Month of Promo Activity] = "Jun"   then    #date(2024,6,1) else
                #date(2030,7,1)
    , Date.Type
)

//

= Table.AddColumn(
    Source, 
    "Location",
        each
            if
                [Country] = "AUS"
            then
                [Billing Address 1] & " " & 
                [Billing Address 2] & " " &
                [Billing Address 3] & " " &
                "Australia"
            else
                null
    , Text.Type
)

////


let
    Source = Odbc.Query("dsn=_Data_01_MSSQL", "/*  Order billing and ship to address dim table   */#(lf)#(lf)SELECT#(lf)     ord_no                 AS 'Order Number'#(lf)    ,MAX(oe_po_no)          AS 'Purchase Order Number'#(lf)    ,MAX(bill_to_addr_1)    AS 'Billing Address 1'#(lf)    ,MAX(bill_to_addr_2)    AS 'Billing Address 2'#(lf)    ,MAX(bill_to_addr_3)    AS 'Billing Address 3'#(lf)    ,MAX(ship_to_name)      AS 'Ship To Name'#(lf)    ,MAX(ship_to_addr_3)    AS 'Ship To Address3'#(lf)    ,MAX(CASE #(lf)        WHEN CHARINDEX('NSW', ship_to_addr_3) > 0 THEN 'NSW'#(lf)        WHEN CHARINDEX('VIC', ship_to_addr_3) > 0 THEN 'VIC'#(lf)        WHEN CHARINDEX('QLD', ship_to_addr_3) > 0 THEN 'QLD'#(lf)        WHEN CHARINDEX('NT', ship_to_addr_3) > 0 THEN 'NT'#(lf)        WHEN CHARINDEX('SA', ship_to_addr_3) > 0 THEN 'SA'#(lf)        WHEN CHARINDEX('WA', ship_to_addr_3) > 0 THEN 'WA'#(lf)        WHEN CHARINDEX('TAS', ship_to_addr_3) > 0 THEN 'TAS'#(lf)        ELSE 'Other'#(lf)    END)                    AS 'State'#(lf)    ,MAX(CASE #(lf)        WHEN CHARINDEX('NSW', ship_to_addr_3) > 0 THEN 'AUS'#(lf)        WHEN CHARINDEX('VIC', ship_to_addr_3) > 0 THEN 'AUS'#(lf)        WHEN CHARINDEX('QLD', ship_to_addr_3) > 0 THEN 'AUS'#(lf)        WHEN CHARINDEX('NT', ship_to_addr_3) > 0 THEN 'AUS'#(lf)        WHEN CHARINDEX('SA', ship_to_addr_3) > 0 THEN 'AUS'#(lf)        WHEN CHARINDEX('WA', ship_to_addr_3) > 0 THEN 'AUS'#(lf)        WHEN CHARINDEX('TAS', ship_to_addr_3) > 0 THEN 'AUS'#(lf)        ELSE 'INTERNATIONAL'#(lf)    END)                    AS 'Country'#(lf)    ,MAX(ship_to_country)   AS 'Ship To Country'#(lf)FROM#(lf)    OEHDRHST_SQL#(lf)GROUP BY#(lf)    ord_no;")

    = Table.AddColumn(
    Source, 
    "Location
    ",
        each
            Number.FromText([Ship To Address3])
    , Text.Type
)

    ExtractedNumber = Text.RegexReplace([Ship To Address3], "[^0-9]", ""),
    FourDigitNumber = Text.End(ExtractedNumber, 4)

in
    Source

/////

= Table.SelectRows(Source, each ([Kind] = "Sheet") and ([Name] <> "Total"))
//

= Table.SelectRows(
    Data, 
    each (
        [Column3] <> null
    )
)

//

= Table.RemoveColumns(
    [Data], 
    {"Column3"}
)


//

= Table.AddColumn(
    KeepOnlyDataColumns, 
    "Location",
        each
            Table.RemoveColumns(
                [Data], 
                {"Column3"}
            )
)

//

= Table.SelectRows(Source, each ([Kind] = "Sheet") and ([Name] <> "Total"))


///

= Table.AddColumn(
    ChangeTypeDateValue, 
    "Amount",
        each
            if
                Text.Contains([Value], "for" ) 
            then
                2
            else
                if
                    Text.Contains([Value] , "/" )
                then
                    [ConvertedDate]
                else
                    [Value]
    , Number.Type
)

///////////





/////

//code that works for the date 45112 formatted as a number

let
    Source = Excel.Workbook(File.Contents("\\keypharm.local\keydata\Data\SALES\Glenn Buxton\Supermarkets\Promotional Calendar.xls"), null, true),
    FY1 = Source{[Name="FY24"]}[Data],
    RemoveTopRow = Table.Skip(FY1,1),
    TransposeTable = Table.Transpose(RemoveTopRow),
    ChangeTypeFirstColumn = Table.TransformColumnTypes(TransposeTable,{{"Column1", type text}}),
    ConvertTextToNumber = 
        Table.AddColumn(
            ChangeTypeFirstColumn, 
            "Try", 
            each 
                let 
                    firstFiveChars = Text.Start([Column1], 5),
                    attemptedNumber = try Number.FromText(firstFiveChars) otherwise null,
                    firstChar = Text.Start([Column1], 1),
                    isNumber = try Number.FromText(firstChar) otherwise null,
                    isDateNumber = try Number.FromText([Column1]) otherwise null

                in
                    if 
                        attemptedNumber <> null 
                    then
                        attemptedNumber
                    else
                        if 
                            isNumber <> null 
                        then 
                            if 
                                isDateNumber <> null 
                            then
                                DateTime.ToText(#date(1899, 12, 30) + Duration.From(isDateNumber), "dd/MM/yyyy")
                            else
                                try 
                                    DateTime.ToText(DateTime.From([Column1]), "dd/MM/yyyy") 
                                otherwise
                                    [Column1]
                        else 
                            [Column1]
                        
            ,type any 
        ),
    NumberToDate = Table.TransformColumnTypes(ConvertTextToNumber,{{"Try", type date}})
in
    NumberToDate


/////////

let
    Source = ... ,  // Your source table
    AddOneMonth = Table.TransformColumns(ChangeType, {{"Date", each Date.AddMonths(_, 1), type date}})
in
    AddOneMonth

/////////////////////

= Table.AddColumn(
    GroupRows, 
    "ACG Increase",
        each
            [Final ACG] - [ACG]
    , Date.Type
)

/////////////////////

= Table.AddColumn(
    AcgIncreaseColumn, 
    "ACG Increase %",
        each
            [ACG Increase] / [ACG]
    , Number.Type
)

/////////////////////

= Table.AddColumn(
    AcgPercentIncreaseColumn, 
    "Cost Increase",
        each
            [Current Cost] - [Adjusted Cost]
    , Number.Type
)

/////////////////////

= Table.AddColumn(
    CostIncreaseColumn, 
    "Average Monthly Increase",
        each
            [Cost Increase] / [Count Of Months]
    , Number.Type
)

/////////////////////

= Table.AddColumn(
    RemoveCostColumns, 
    "Adjusted ASP",
        each
            if
                [Price List.ASP] = null and [Macola.ASP] = null
            then
                [FAB.ASP]
            else
                if
                    [Price List.ASP] = null
                then
                    [Macola.ASP]
                else
                    [FAB.ASP]
    , Number.Type
)

///////

= Table.AddColumn(
    AspVariance, 
    "Sales Impact",
        each

            if
                [ASP Variance] = null
            then
                null
            else
                [Qty] * [ASP Variance]

    , Number.Type
)

///

= Table.AddColumn(
    AdjustedAsp, 
    "ASP Variance",
        each

            [FAB.ASP] - [Adjusted ASP]  

    , Number.Type
)


/////

let
  // Perform a left outer join between "Current FAB" and "Recent Sale - SKU FAB Channel" tables on "SKU" and "Channel" columns
  Source = Table.NestedJoin(
    #"Current FAB", 
    {"SKU", "Channel"}, 
    #"Recent Sale - SKU FAB Channel", 
    {"SKU", "Channel"}, 
    "Recent Sale - SKU Customer", 
    JoinKind.LeftOuter
  ), 
  
  // Filter out rows where the "Qty" column is zero
  FilterOutZeroQty = Table.SelectRows(Source, each ([Qty] <> 0)), 
  
  // Add a new column "FAB.ASP" that calculates the average selling price (ASP) as Sales/Qty, rounded to 2 decimal places
  CalculateAspColumn = Table.AddColumn(
    FilterOutZeroQty, 
    "FAB.ASP", 
    each Number.Round([Sales] / [Qty], 2), 
    Number.Type
  ), 
  
  // Expand the "ASP" column from the "Recent Sale - SKU Customer" table into a new column "Macola.ASP"
  ExpandMacolaAspAcg = Table.ExpandTableColumn(
    CalculateAspColumn, 
    "Recent Sale - SKU Customer", 
    {"ASP"}, 
    {"Macola.ASP"}
  ), 
  
  // Perform another left outer join with the "Price List" table on "SKU" and "Channel" columns
  MergePriceList = Table.NestedJoin(
    ExpandMacolaAspAcg, 
    {"SKU", "Channel"}, 
    #"Price List", 
    {"SKU", "Channel"}, 
    "Price List", 
    JoinKind.LeftOuter
  ), 
  
  // Expand the "ASP" column from the "Price List" table into a new column "Price List.ASP"
  ExpandPriceList = Table.ExpandTableColumn(
    MergePriceList, 
    "Price List", 
    {"ASP"}, 
    {"Price List.ASP"}
  ), 

    // Add a new column "Adjusted ASP1" that takes values from "FAB.ASP", "Macola.ASP" based on conditions
  AdjustedAsp1 = Table.AddColumn(
    ExpandPriceList, 
    "Adjusted ASP1", 
    each 
      if 
        [Macola.ASP] = null
      then
        [FAB.ASP]
      else
        [Macola.ASP]
    ,Number.Type
  ), 
  
  // Add a new column "Adjusted ASP2" that uses price list prices when they take effect
  AdjustedAsp2 = 
  Table.AddColumn(
      AdjustedAsp1, 
        "Adjusted ASP2", 
        each 
            if 
                [Price List.ASP] = null
            then
                [Adjusted ASP1]
            else
                if
                    [Price List.Effective Date] >= [Date]
                then
                    [Price List.ASP]
                else
                    [Adjusted ASP1]
        ,Number.Type
    )
  , 
  
  // Add a new column "ASP Variance" that calculates the difference between "Adjusted ASP" and "FAB.ASP"
  AspVariance = Table.AddColumn(
    AdjustedAsp, 
    "ASP Variance", 
    each [Adjusted ASP] - [FAB.ASP], 
    Number.Type
  ), 
  
  // Add a new column "Sales Impact" that multiplies "ASP Variance" by "Qty" if "ASP Variance" is not null
  SalesImpact = Table.AddColumn(
    AspVariance, 
    "Sales Impact", 
    each if [ASP Variance] = null then null else [Qty] * [ASP Variance], 
    Number.Type
  )
in
  SalesImpact


//////////////

= Table.AddColumn(
    ExpandActuals, 
        "Sort By", 
        each 
            if
                [Brand] is null
            then
                [Act.Brand] & " - " & [Act.Category]
            else
                [Brand] & " - " & [Account Description]
    ,Text.Type
)

//////////////

= Table.AddColumn(
    ChangeTypesColumns, 
        "Amount1", 
        each 
            if
                Text.Contains([Value], "/" ) = true
            then
                [Value] 
            else
                null
    ,Text.Type
)

//////////////

= Table.AddColumn(
    ChangeTypeNumber, 
        "Amount", 
        each 
            if
                [Amount1] is null
            then
                [Value] * 1
            else
                [Amount1]
    ,Number.Type
)


//////////

= Table.AddColumn(
    ChangeEffectiveDateType, 
        "Old Sales", 
        each 
            if
                [Effective Date] = null
                then
                    [Sales]
                else
                    if
                        [Effective Date] <= [Date]
                    then
                        if
                            [FAB ASP Before Change] * [Qty] > [Sales]
                        then
                            [Sales]
                    else
                        [Sales]
    ,Number.Type
)

//////////


= Table.AddColumn(
    AddChannelColumn, 
        "Sales Variance", 
        each 
            if
                [Old Sales] > [Sales]
            then
                [Value] * 1
            else
                [Amount1]
    ,Number.Type
)

//////////


= Table.AddColumn(
    AddChannelColumn, 
        "Increase", 
        each 
            [NEW PRICE] - [CURRENT PRICE]  
            
    ,Number.Type
)

//////////

= Table.AddColumn(
    IncreaseAmount, 
        "Increase Percent", 
        each 
            [Increase] / [CURRENT PRICE]
            
    ,Number.Type
)

//////////

= Table.AddColumn(
    ChangesTypesAgain1, 
        "Sales Less Increase", 
        each 
            if
                [Effective Date.1] = null
                then
                    [Sales]
                else
                    if
                        [Effective Date.1] <= [Date]
                    then
                        [Sales] / (1+[Increase Percent.1]) 
                    else
                        [Sales]
    ,Number.Type
)

//////////

= Table.AddColumn(
    SalesLessIncrease, 
        "Increase Impact", 
        each 
            [Sales] - [Sales Less Increase]
            
    ,Number.Type
)


///////

= Table.AddColumn(
    NewSalesColumn, 
    "Cost New",
        each 
            if
                [Adjusted ACG] = null
            then
                [Cost]
            else
                [Qty] * [Adjusted ACG]
    , Number.Type
)

///

= Table.AddColumn(
    ExpandAspIncreases, 
        "Sales New", 
        each 
            if
                [Adjusted ASP] is null
            then
                [Sales]
            else
                [Adjusted ASP] * [Qty]
    ,Number.Type
)

///

= Table.AddColumn(
    RemoveAspAcg, 
        "Filter Zeros", 
        each 
            [Sales] + [Cost] + [Qty]
    ,Number.Type
)

///

= Table.AddColumn(
    ReorderColumns, 
        "YYYYMM", 
        each 
            let
                TextDate = Text.From([Date])
            //Text.End(Text.From([Date]),4)
            Text.End(TextDate,4)
    ,Number.Type
)

///

= Table.AddColumn(
    RemoveColumns, 
        "Sales", 
        each 
            [Qty] * [NPD.ASP]
    ,Number.Type
)

///

= Table.AddColumn(
    SalesColumnCalculated, 
        "Cost", 
        each 
            [Qty] * [NPD.ACG]
    ,Number.Type
)

///

= Table.AddColumn(
    ChangeTypes, 
        "FilterOutFy24Bud", 
        each 
            Number.ToText([Financial Year]) & " " & [Group] & " " & [Type]
    ,Text.Type
)


/////////



let
    Source = Excel.Workbook(File.Contents("C:\\Users\\tosborn\\OneDrive - Key Pharmaceuticals\\Desktop\\Chat GPT ADA - Woolies Data.xlsx"), null, true),
    SheetData = Source{[Item="Data1", Kind="Sheet"]}[Data],

    // Convert the table into a list of lists, where each sublist is a row
    ListOfRows = List.Transform(Table.ToRows(SheetData), each List.Transform(_, each if _ is null then "" else Text.From(_))),

    // Define the list of keywords to filter by
    KeywordsList = {"Blistex", "No Doz", "Odor Eaters", "OdorEaters"},

    // Filter the list of rows based on the presence of keywords
    FilteredListOfRows = List.Select(ListOfRows, each let RowAsString = Text.Combine(_, " ") in List.AnyTrue(List.Transform(KeywordsList, each Text.Contains(RowAsString, _, Comparer.OrdinalIgnoreCase)))),

    // Remove blank rows from each list
    NoBlankRowsList = List.Transform(FilteredListOfRows, each List.Select(_, each Text.Trim(_) <> "")),

    // Keep only the third last record from each list
    ThirdLastRecord = List.Transform(NoBlankRowsList, each List.Range(_, List.Count(_) - 3, 1)),
    FlattenedThirdLast = List.Combine(ThirdLastRecord),

    // Keep rows containing any keyword from KeywordsList
    RowsWithKeywords = List.Transform(NoBlankRowsList, each List.Select(_, each List.AnyTrue(List.Transform(KeywordsList, (keyword) => Text.Contains(_, keyword, Comparer.OrdinalIgnoreCase))))),
    FlattenedKeywords = List.Combine(RowsWithKeywords),

    // Custom function to check if a string is a date
    IsDate = (text) => 
        let 
            parsed = try Date.FromText(text) 
        in 
            if parsed[HasError] then false else Type.Is(parsed[Value], type date),

    // Keep rows that are in date format
    RowsWithDates = List.Transform(NoBlankRowsList, each List.Select(_, each let result = try IsDate(_) in if result[HasError] then false else result[Value]))
in
    RowsWithDates


////////////// debug function

let
    TestList = {"19.07.2023", "25.07.2023", "Blistex Lip Balm", "18.399999999999999", "Not a date"},
    // Custom function to check if a string is a date
    IsDate = (text) => 
    let 
        parsed = try Date.FromText(text),
        reformatted = try Date.ToText(parsed[Value], "dd.MM.yyyy")
    in 
        not parsed[HasError] and not reformatted[HasError]


    ,Results = List.Transform(TestList, each IsDate(_))
in
    Results


    /////////

let
    Source = Excel.Workbook(File.Contents("C:\\Users\\tosborn\\OneDrive - Key Pharmaceuticals\\Desktop\\Chat GPT ADA - Woolies Data.xlsx"), null, true),
    SheetData = Source{[Item="Data1", Kind="Sheet"]}[Data],

    // Convert the table into a list of lists, where each sublist is a row
    ListOfRows = List.Transform(Table.ToRows(SheetData), each List.Transform(_, each if _ is null then "" else Text.From(_))),

    // Define the list of keywords to filter by
    KeywordsList = {"Blistex", "No Doz", "Odor Eaters", "OdorEaters"},

    // Filter the list of rows based on the presence of keywords
    FilteredListOfRows = List.Select(ListOfRows, each let RowAsString = Text.Combine(_, " ") in List.AnyTrue(List.Transform(KeywordsList, each Text.Contains(RowAsString, _, Comparer.OrdinalIgnoreCase)))),

        // Remove blank rows from each list
    NoBlankRowsList = List.Transform(FilteredListOfRows, each List.Select(_, each Text.Trim(_) <> "")),
    // Remove blank rows from each list
    NoBlankRowsList1 = NoBlankRowsList{5},
    ConvertToTable = Table.FromList(NoBlankRowsList1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    // Custom function to check if a string is a date
    IsDate = (text) => 
        let 
            parsed = try Date.FromText(text),
            reformatted = try Date.ToText(parsed[Value], "dd.MM.yyyy")
        in 
            not parsed[HasError] and not reformatted[HasError]

    // Add Column to test date function     
    AddDateColumn = Table.AddColumn(ConvertToTable, "IsDate", each IsDate([Column1]), type logical)


in
    ConvertToTable


//////

/// first query to get claim number

let
    Source = Excel.Workbook(File.Contents("C:\\Users\\tosborn\\OneDrive - Key Pharmaceuticals\\Desktop\\Chat GPT ADA - Woolies Data.xlsx"), null, true),
    SheetData = Source{[Item="Data1", Kind="Sheet"]}[Data],

let

    // Get the first row as a list
    FirstRow = Table.ToRecords(Table.FirstN(SheetData, 1)){0},
    FirstRowList = Record.FieldValues(FirstRow),

    // Find the index of the cell containing "Claim No:"
    ClaimNoIndex = List.PositionOf(FirstRowList, "Claim No:"),

    // Get the claim number from the next cell
    ClaimNumber = FirstRowList{ClaimNoIndex + 1}
in
    ClaimNumber

//////  large query


let
    Source = Excel.Workbook(File.Contents("C:\\Users\\tosborn\\OneDrive - Key Pharmaceuticals\\Desktop\\Chat GPT ADA - Woolies Data.xlsx"), null, true),
    SheetData = Source{[Item="Data1", Kind="Sheet"]}[Data],

    // subquery to get claim number
    
        // Get the first row as a list
        FirstRow = Table.ToRecords(Table.FirstN(SheetData, 1)){0},
        FirstRowList = Record.FieldValues(FirstRow),

        // Find the index of the cell containing "Claim No:"
        ClaimNoIndex = List.PositionOf(FirstRowList, "Claim No:"),

        // Get the claim number from the next cell
        ClaimNumber = FirstRowList{ClaimNoIndex + 1}

    // All types as text
    ChangesAllTypesToText = Table.TransformColumnTypes(SheetData,{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}, {"Column12", type text}, {"Column13", type text}, {"Column14", type text}, {"Column15", type text}, {"Column16", type text}}),

    // Convert the table into a list of lists, where each sublist is a row
    ListOfRows = List.Transform(Table.ToRows(ChangesAllTypesToText), each List.Transform(_, each if _ is null then "" else Text.From(_))),

    // Define the list of keywords to filter by
    KeywordsListToFilterBy = {"Blistex", "No Doz", "Odor Eaters", "OdorEaters"},

    // Filter the list of rows based on the presence of keywords
    FilteredListOfRows = List.Select(ListOfRows, each let RowAsString = Text.Combine(_, " ") in List.AnyTrue(List.Transform(KeywordsListToFilterBy, each Text.Contains(RowAsString, _, Comparer.OrdinalIgnoreCase)))),

    // Remove blank rows from each list
    NoBlankRowsList = List.Transform(FilteredListOfRows, each List.Select(_, each Text.Trim(_) <> "")),

    // Keep only the third last record from each list
    ThirdLastRecord = List.Transform(NoBlankRowsList, each List.LastN(_, 3){0}),
    RowsWithKeywords = List.Transform(NoBlankRowsList, each List.Select(_, each List.AnyTrue(List.Transform(KeywordsListToFilterBy, (keyword) => Text.Contains(_, keyword, Comparer.OrdinalIgnoreCase))))),
    FlattenedKeywords = List.Combine(RowsWithKeywords),

    // Custom function to check if a string is a date
    IsDate = (text) => 
        let 
            parsed = try Date.FromText(text),
            reformatted = try Date.ToText(parsed[Value], "dd.MM.yyyy")
        in 
            not parsed[HasError] and not reformatted[HasError] and text = reformatted[Value],

    // Keep rows that are in date format
    RowsWithDates = List.Transform(NoBlankRowsList, each List.Select(_, each IsDate(_))),

    // To combine all of the lists and records together in a table:

        // Extract the first and second date from RowsWithDates
    FirstDate = List.Transform(RowsWithDates, each List.First(_, null )),
    SecondDate = List.Transform(RowsWithDates, each List.Skip(_, 1){0}),

    // Combine the four lists into records
    CombinedRecords = List.Transform(
        List.Positions(FlattenedKeywords), 
        each [
            FlattenedKeywords = FlattenedKeywords{_}, 
            FirstDate = FirstDate{_}, 
            SecondDate = SecondDate{_}, 
            ThirdLastRecord = ThirdLastRecord{_}
        ]
    ),

    
    // Convert the list of records into a table
    FinalTable = Table.FromRecords(CombinedRecords),
    ChangeTypes = Table.TransformColumnTypes(FinalTable,{{"FlattenedKeywords", type text}, {"FirstDate", type date}, {"SecondDate", type date}, {"ThirdLastRecord", type number}})
in
    ChangeTypes



////

let
    Source = Excel.Workbook(File.Contents("C:\\Users\\tosborn\\OneDrive - Key Pharmaceuticals\\Desktop\\Chat GPT ADA - Woolies Data.xlsx"), null, true),
    SheetData = Source{[Item="Data1", Kind="Sheet"]}[Data],
    ChangesAllTypesToText = Table.TransformColumnTypes(SheetData,{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}, {"Column12", type text}, {"Column13", type text}, {"Column14", type text}, {"Column15", type text}, {"Column16", type text}}),

    // Convert the table into a list of lists, where each sublist is a row
    ListOfRows = List.Transform(Table.ToRows(ChangesAllTypesToText), each List.Transform(_, each if _ is null then "" else Text.From(_))),

    // Define the list of keywords to filter by
    KeywordsListToFilterBy = {"Blistex", "No Doz", "Odor Eaters", "OdorEaters"},

    // Filter the list of rows based on the presence of keywords
    FilteredListOfRows = List.Select(ListOfRows, each let RowAsString = Text.Combine(_, " ") in List.AnyTrue(List.Transform(KeywordsListToFilterBy, each Text.Contains(RowAsString, _, Comparer.OrdinalIgnoreCase)))),

    // Remove blank rows from each list
    NoBlankRowsList = List.Transform(FilteredListOfRows, each List.Select(_, each Text.Trim(_) <> "")),

    // Keep only the third last record from each list
    ThirdLastRecord = List.Transform(NoBlankRowsList, each List.LastN(_, 3){0}),
    RowsWithKeywords = List.Transform(NoBlankRowsList, each List.Select(_, each List.AnyTrue(List.Transform(KeywordsListToFilterBy, (keyword) => Text.Contains(_, keyword, Comparer.OrdinalIgnoreCase))))),
    FlattenedKeywords = List.Combine(RowsWithKeywords),

    // Custom function to check if a string is a date
    IsDate = (text) => 
        let 
            parsed = try Date.FromText(text),
            reformatted = try Date.ToText(parsed[Value], "dd.MM.yyyy")
        in 
            not parsed[HasError] and not reformatted[HasError] and text = reformatted[Value],

    // Keep rows that are in date format
    RowsWithDates = List.Transform(NoBlankRowsList, each List.Select(_, each IsDate(_))),

    // To combine all of the lists and records together in a table:

        // Extract the first and second date from RowsWithDates
    FirstDate = List.Transform(RowsWithDates, each List.First(_, null )),
    SecondDate = List.Transform(RowsWithDates, each List.Skip(_, 1){0}),

    // Combine the four lists into records
    CombinedRecords = List.Transform(
        List.Positions(FlattenedKeywords), 
        each [
            FlattenedKeywords = FlattenedKeywords{_}, 
            FirstDate = FirstDate{_}, 
            SecondDate = SecondDate{_}, 
            ThirdLastRecord = ThirdLastRecord{_}
        ]
    ),

    
    // Convert the list of records into a table
    FinalTable = Table.FromRecords(CombinedRecords),
    ChangeTypes = Table.TransformColumnTypes(FinalTable,{{"FlattenedKeywords", type text}, {"FirstDate", type date}, {"SecondDate", type date}, {"ThirdLastRecord", type number}})
in
    ChangeTypes









/////////////////////

= Table.AddColumn(
    ChangeType, 
    "Date",
        each
            #date([Year] , Date.FromText([Attribute] , [Format="MMM"] ) , 1 )
)

////////////////


= Table.AddColumn(
    ChangeType, 
    "Date",
        each
            #date(
                [Year],
                Date.Month(
                    Date.FromText([Attribute] , [Format="MMM"] )
                ),
                1
            ),
            Date.Type
)

Table.AddColumn(
    AddMonthYearColumn,
    "Current Month",
    each 
        if
            [MonthOffset] = -1 
        then
            "Prior Month"
        else
            "Make Date Selection"
    ,
    type text
)



            if
                [YearOffset] = 0
            then
            

////////


Table.AddColumn(
    UnpivotColumns,
    "Date",
    each 
        #date(
            Number.FromText (Text.Start([FYear], 4 )) ,  // year
            7,
            1
        )
    ,
    type text
)

////////

Table.AddColumn(
    AddDateColumn,
    "Date Year End",
    each 
        #date(
            Number.FromText (Text.Start([FYear], 4 )) ,  // year
            6,
            30
        )
    ,
    type text
)













