

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
                        // any other unplanned eventualities will return the requested date field
                        // and will cause an error becuase this won't be in the date format
                        // EXPECT ERROR HERE - NEED ANOTHER NESTED IF FOR UNPLANNED DATE 
                        [Requested Delivery Date]
        // error handling, some requested dates are null so return PO Date if error
        otherwise [PO Date]
    //
	, Date.Type

)
