
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
        ReplaceErrors3, 
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
    {{"AgeBracket", type text}}
),

///////////

Table.TransformColumnTypes(
    Table.AddColumn(
        RemoveColumn, 
        "Order", 
        each let
            age = [AgeBracket]
        in
            if age = "Newborn" then 0
            else if age = "1-15" then 1
            else if age = "16-25" then 2
            else if age = "26-35" then 3
            else if age = "36-45" then 4
            else if age = "46-55" then 5
            else if age = "56-65" then 6
            else if age = "66-75" then 7
            else if age = "76-85" then 8
            else if age = "86-95" then 9
            else if age = "96-105" then 10
            else 11
    ),
    {{"Order", type Int64}}
)


//////////////


let
  Source = Sql.Database("TGC-AZ-SQL01", "e-pas PROD", [Query = "SELECT#(lf)-- Facility Details#(lf)ps.FACILITY_ID AS FacilityID,#(lf)f.FACILITY_NAME,#(lf)-- Session Details#(lf)ps.START_DATE AS SessionDate,#(lf)ps.START_TIME AS SessionStartTime,#(lf)ps.END_TIME AS SessionEndTime,#(lf)--Booking Details#(lf)b.BOOKING_ID AS BookingID,#(lf)b.BOOKING_DATE AS BookingDate,#(lf)b.START_TIME AS BookingStartTime,#(lf)b.END_TIME AS BookingEndTime,#(lf)--Provider Details#(lf)b.PROVIDER_ID AS ProviderID,#(lf)--Patient Details#(lf)bp.PERSON_ID AS PersonID#(lf)FROM pas.PROVIDER_SESSION AS ps #(lf)--LEFT JOIN pas.PROVIDER_SESSION_DETAIL AS psd ON ps.PROVIDER_SESSION_ID = psd.PROVIDER_SESSION_ID AND ps.START_DATE = psd.SESSION_DATE#(lf)LEFT JOIN pas.BOOKING AS b ON ps.START_DATE = b.BOOKING_DATE AND ps.FACILITY_ID = b.FACILITY_ID#(lf)--LEFT JOIN pas.BOOKING_EXTRACT bx ON b.BOOKING_ID = bx.BOOKING_ID#(lf)LEFT JOIN pas.BOOKING_PATIENT AS bp ON b.BOOKING_ID = bp.BOOKING_ID AND b.END_TIME <= ps.END_TIME AND b.START_TIME >= ps.START_TIME#(lf)LEFT JOIN pas.FACILITY AS f ON ps.FACILITY_ID = f.FACILITY_ID#(lf)WHERE ps.VERSION_NUMBER <> 0#(lf)ORDER BY SessionDate DESC#(lf)#(lf)"]),
  #"Format Booking Date" = Table.TransformColumnTypes(Source, {{"BookingDate", type date}, {"BookingStartTime", type time}, {"BookingEndTime", type time}, {"SessionStartTime", type time}, {"SessionEndTime", type time}}),
  AddSessionDuration = Table.TransformColumnTypes(Table.AddColumn(ChangeColumnTypes, "SessionDurationMinutes", each Duration.Hours([SessionEndTime]-[SessionStartTime])*60 + Duration.Minutes([SessionEndTime]-[SessionStartTime])), {{"SessionDurationMinutes", Int64.Type}}),
  AddBookingDuration = Table.TransformColumnTypes(Table.AddColumn(AddSessionDuration, "BookingDurationMinutes", each Duration.Hours([BookingEndTime]-[BookingStartTime])*60 + Duration.Minutes([BookingEndTime]-[BookingStartTime])), {{"BookingDurationMinutes", Int64.Type}})
in
  AddBookingDuration


