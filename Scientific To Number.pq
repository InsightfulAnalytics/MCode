= Table.AddColumn(
	ExpandedGTINMapping, 
	"SKU", 
	each
		//  
		if
			[PRODUCT CODE] = null
		then
			[Vendor Style]
		else
			[PRODUCT CODE]
		//
	, Text.Type

)

-------------


= Table.AddColumn(
	RenameSKU, 
	"Custom", 
	each
		//  convert the requested Delivery date to number (get rid of scientific number)
		//  if there is an error return the delivery date 
		try 
			Number.ToText(Number.From([GTIN]),"G")
		otherwise
			[GTIN]

		//
	, Text.Type

)
