

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
                        // any other unplanned eventualities will return the PO date field
                        // and will cause an error becuase this won't be in the date format
                        // EXPECT ERROR HERE - NEED ANOTHER NESTED IF FOR UNPLANNED DATE 
                        [PO Date Text]
        // if error is thrown, return date
        otherwise #date (1900,1,1)
        //
	, Date.Type

)
