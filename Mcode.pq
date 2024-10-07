
Table.TransformColumnTypes(Table.AddColumn(#"Replace errors 3", "AgeBracket", each let
            age = [AgeAtTimeOfAdmission]
        in
            if age < 18 then "Under 18"
            else if age >= 18 and age <= 24 then "18-24"
            else if age >= 25 and age <= 34 then "25-34"
            else if age >= 35 and age <= 44 then "35-44"
            else if age >= 45 and age <= 54 then "45-54"
            else if age >= 55 and age <= 64 then "55-64"
            else if age >= 65 and age <= 74 then "65-74"
            else if age >= 75 and age <= 84 then "75-84"
            else if age >= 85 and age <= 94 then "85-94"
            else if age >= 95 and age <= 104 then "95-104"
            else "105+"), {{"AgeBracket", type text}}),

/////////



Table.TransformColumnTypes(
    Table.AddColumn(
        #"Replace errors 3", 
        "AgeBracket", 
        each let
            age = [AgeAtTimeOfAdmission]
        in
            if age = 0 then "Newborn"
            else if age >= 1 and age <= 15  then "1-15"
            else if age >= 16 and age <= 25 then "16-25"
            else if age >= 26 and age <= 35 then "26-35"
            else if age >= 36 and age <= 45 then "36-45"
            else if age >= 46 and age <= 55 then "46-55"
            else if age >= 56 and age <= 65 then "56-65"
            else if age >= 66 and age <= 75 then "66-75"
            else if age >= 76 and age <= 85 then "76-85"
            else if age >= 86 and age <= 95 then "86-95"
            else if age >= 96 and age <= 105 then "96-105"
            else "Not Known"
    ),
    {{"AgeBracket", type text}})
