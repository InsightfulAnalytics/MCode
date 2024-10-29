
let
  Source = Sql.Database("TGC-AZ-SQL01", "e-PAS PROD", [Query = "With FilteredBooking AS (    #(lf)SELECT#(lf)        BOOKING_ID AS BookingID,#(lf)        BOOKING_DATE AS BookingDate,#(lf)        START_TIME AS StartTime,#(lf)        BOOKING_STATUS_ID AS BookingStatusID,#(lf)        BOOKING_ADMISSION_TYPE_ID AS BookingAdmissionTypeID,#(lf)        FACILITY_ID AS FacilityID#(lf)    FROM#(lf)        pas.BOOKING#(lf)    WHERE#(lf)        BOOKING_STATUS_ID = 'D'#(lf))#(lf)SELECT #(lf)    -- Booking Details#(lf)    b.BookingID,#(lf)    b.BookingDate,#(lf)    b.StartTime,#(lf)    b.BookingStatusID,#(lf)    b.BookingAdmissionTypeID,#(lf)    bat.DESCRIPTION AS AdmissionTypeDescription,#(lf)    -- Patient details#(lf)    bp.PERSON_ID AS PersonID,#(lf)    p.MRN AS MRNNumber,#(lf)#(tab)ps.DATE_OF_BIRTH AS DateOfBirth,#(lf)    -- Providers details#(lf)    e.ADMITTING_DOCTOR_PROVIDER_ID AS AdmittingDoctorProviderID,#(lf)#(tab)--prd.PROVIDER_DISCIPLINE_ID,#(lf)    -- Facility details#(lf)    b.FacilityID AS FacilityID,#(lf)    -- Admission details#(lf)    e.ADMISSION_DATE AS AdmissionDate,#(lf)    e.ADMISSION_TIME AS AdmissionTime,#(lf)    e.ADMISSION_TYPE_ID AS AdmissionTypeID,#(lf)#(tab)e.ADMISSION_SOURCE_ID AS AdmissionSource,#(lf)    e.ADMISSION_REASON AS AdmissionReason,#(lf)    e.PATIENT_CATEGORY_ID AS PatientCategoryID,#(lf)    pc.PATIENT_CATEGORY_CODE AS PatientCategoryCode,#(lf)    -- Episode details#(lf)    e.EPISODE_ID AS EpisodeID,#(lf)    e.EPISODE_TYPE_ID AS EpisodeTypeID,#(lf)    e.EPISODE_STATUS_ID AS EpisodeStatusID,#(lf)    e.DISCHARGE_STATUS_ID AS DischargeStatusID,#(lf)    e.DISCHARGE_DESTINATION_ID AS DischargeDestinationID,#(lf)    e.DISCHARGE_DATE AS DischargeDate,#(lf)    e.DISCHARGE_TIME AS DischargeTime,#(lf)#(tab)epr.EPISODE_PROVIDER_SPECIALITY AS EpisodeProviderSpecialization,#(lf)#(tab)MAX(CONCAT(epr.EPISODE_PROVIDER_DATE, ' ', epr.EPISODE_PROVIDER_TIME)) AS LastDateTimeUpdated,#(lf)#(tab)-- Session detials#(lf)#(tab)be.ANAESTHETIC_START_TIME AS AnaestheticStartTime,#(lf)#(tab)be.ANAESTHETIC_FINISH_TIME AS AnaestheticFinishTime,#(lf)#(tab)be.OPERATION_START_TIME AS OperationStartTime,#(lf)#(tab)be.OPERATION_FINISH_TIME AS OperatingFinishTime,#(lf)#(tab)be.RECOVERY_START_TIME AS RecoveryStartTime,#(lf)#(tab)be.RECOVERY_FINISH_TIME AS RecoveryFinishTime,#(lf)#(tab)ed.DRG_CODE AS DRGCode,#(lf)#(tab)-- Health Fund Details#(lf)#(tab)ec.ORGANISATION_ID#(lf)FROM #(lf)    pas.EPISODE e#(lf)LEFT JOIN #(lf)    pas.PATIENT p ON e.PATIENT_ID = p.PATIENT_ID#(lf)LEFT JOIN #(lf)    pas.PERSON ps ON p.PERSON_ID = ps.PERSON_ID#(lf)LEFT JOIN#(lf)#(tab)pas.EPISODE_DRG AS ed ON e.EPISODE_ID = ed.EPISODE_ID AND ed.DRG_TYPE = 'FINAL'#(lf)LEFT JOIN #(lf)    pas.BOOKING_PATIENT bp ON ps.PERSON_ID = bp.PERSON_ID#(lf)LEFT JOIN #(lf)#(tab)pas.EPISODE_BOOKING_VIEW ebv ON e.EPISODE_ID = ebv.EPISODE_ID#(lf)LEFT JOIN #(lf)    FilteredBooking b ON ebv.BOOKING_ID = b.BookingID#(lf)LEFT JOIN #(lf)    pas.BOOKING_EXTENSION be ON b.BookingID = be.BOOKING_ID#(lf)LEFT JOIN #(lf)    pas.FACILITY f ON b.FacilityID = f.FACILITY_ID#(lf)LEFT JOIN #(lf)    pas.PROVIDER pr ON e.ADMITTING_DOCTOR_PROVIDER_ID = pr.PROVIDER_ID#(lf)LEFT JOIN #(lf)    pas.BED_DETAIL bd ON e.EPISODE_ID = bd.EPISODE_ID#(lf)LEFT JOIN #(lf)    pas.BOOKING_ADMISSION_TYPE bat ON b.BookingAdmissionTypeID = bat.BOOKING_ADMISSION_TYPE_ID#(lf)LEFT JOIN #(lf)    pas.PATIENT_CATEGORY pc ON e.PATIENT_CATEGORY_ID = pc.PATIENT_CATEGORY_ID#(lf)LEFT JOIN#(lf)#(tab)pas.EPISODE_PROVIDER epr ON e.ADMITTING_DOCTOR_PROVIDER_ID = epr.PROVIDER_ID AND e.EPISODE_ID = epr.EPISODE_ID#(lf)LEFT JOIN#(lf)#(tab)pas.EPISODE_ECF_HISTORY eeh ON e.EPISODE_ID = eeh.EPISODE_ID#(lf)LEFT JOIN #(lf)#(tab)pas.EPISODE_CLAIM AS ec ON e.EPISODE_ID = ec.EPISODE_ID#(lf) #(lf)#(lf)WHERE #(lf)    epr.EPISODE_PROVIDER_SPECIALITY <> ''#(lf)#(tab)AND epr.DELETE_USER_ID IS NULL#(lf)#(tab)AND e.DISCHARGE_STATUS_ID = 'COMPLETE'#(lf)GROUP BY #(lf)    b.BookingID,#(lf)    b.BookingDate,#(lf)    b.StartTime,#(lf)    b.BookingStatusID,#(lf)    b.BookingAdmissionTypeID,#(lf)    bat.DESCRIPTION,#(lf)    bp.PERSON_ID,#(lf)    p.MRN,#(lf)#(tab)ps.DATE_OF_BIRTH,#(lf)#(tab)e.ADMITTING_DOCTOR_PROVIDER_ID,#(lf)#(tab)b.FacilityID,#(lf)    f.FACILITY_NAME,#(lf)#(tab)e.ADMISSION_DATE,#(lf)    e.ADMISSION_TIME,#(lf)    e.ADMISSION_TYPE_ID,#(lf)#(tab)e.ADMISSION_SOURCE_ID,#(lf)    e.PATIENT_CATEGORY_ID,#(lf)    pc.PATIENT_CATEGORY_CODE,#(lf)#(tab)e.EPISODE_ID,#(lf)    e.EPISODE_NUMBER,#(lf)    e.EPISODE_TYPE_ID,#(lf)    e.EPISODE_STATUS_ID,#(lf)    e.ADMISSION_NUMBER,#(lf)    e.DISCHARGE_STATUS_ID,#(lf)    e.DISCHARGE_DESTINATION_ID,#(lf)    e.DISCHARGE_DATE,#(lf)    e.DISCHARGE_TIME,#(lf)    e.ADMISSION_REASON,#(lf)#(tab)epr.EPISODE_PROVIDER_SPECIALITY,#(lf)#(tab)epr.EPISODE_PROVIDER_DATE,#(lf)#(tab)epr.EPISODE_PROVIDER_TIME,#(lf)#(tab)be.ANAESTHETIC_START_TIME,#(lf)#(tab)be.ANAESTHETIC_FINISH_TIME,#(lf)#(tab)be.OPERATION_START_TIME,#(lf)#(tab)be.OPERATION_FINISH_TIME,#(lf)#(tab)be.RECOVERY_START_TIME,#(lf)#(tab)be.RECOVERY_FINISH_TIME,#(lf)#(tab)ed.DRG_CODE,#(lf)#(tab)ec.ORGANISATION_ID#(lf)"]),
  #"Update ColumnType" = Table.TransformColumnTypes(Source, {{"AdmissionDate", type date}, {"AdmissionTime", type time}, {"DischargeDate", type date}, {"DischargeTime", type time}, {"BookingDate", type date}, {"StartTime", type time}}),
  #"add datekey" = Table.AddColumn(#"Update ColumnType", "datekey", each Date.Year([AdmissionDate])*10000+Date.Month([AdmissionDate])*100+Date.Day([AdmissionDate])),
  #"Changed column type 1" = Table.TransformColumnTypes(#"add datekey", {{"datekey", Int64.Type}}),
  #"Add SiteID" = Table.AddColumn(#"Changed column type 1", "SiteID", each 5),
  #"Transform columns" = Table.TransformColumnTypes(#"Add SiteID", {{"SiteID", type text}}),
  #"Replace errors" = Table.ReplaceErrorValues(#"Transform columns", {{"SiteID", null}}),
  
  #"Add LengthOfStay" = 
    Table.AddColumn(
        #"Replace errors", 
        "LengthOfStay", 
            each 
                if [PatientCategoryCode] = "SDM" 
                or [PatientCategoryCode] = "C" 
                or [PatientCategoryCode] = "PAU" 
            then 
                0 
            else 
                if
                    [AdmissionDate] = [DischargeDate] 
                then 
                    1
                else
                    ([DischargeDate] - [AdmissionDate])
    ),
  
  #"Change Type ALS" = Table.TransformColumnTypes(#"Add LengthOfStay", {{"LengthOfStay", Int64.Type}}),
  #"Add CalendarMonthYear" = Table.AddColumn(#"Change Type ALS", "CalendarMonthYear", each Date.ToText([AdmissionDate], [Format = "MMM-yy"])),
  #"DataType CalMonthYear" = Table.TransformColumnTypes(#"Add CalendarMonthYear", {{"CalendarMonthYear", type text}}),
  #"Replace errors 1" = Table.ReplaceErrorValues(#"DataType CalMonthYear", {{"CalendarMonthYear", null}}),
  #"Add CalendarYear" = Table.AddColumn(#"Replace errors 1", "CalendarYearNumber", each Date.Year([AdmissionDate])),
  #"Add CY Text" = Table.AddColumn(#"Add CalendarYear", "CalendarYear", each Text.Combine({"CY",Number.ToText([CalendarYearNumber])},"-")),
  #"Add FiscalYearNumber" = Table.AddColumn(#"Add CY Text", "FiscalYearNumber", each let
    FiscalYear = if Date.Month([AdmissionDate]) >= 7 then Date.Year([AdmissionDate]) + 1 else Date.Year([AdmissionDate])
in
    FiscalYear),
  #"Add FY Text" = Table.AddColumn(#"Add FiscalYearNumber", "FiscalYear", each Text.Combine({"FY", Number.ToText([FiscalYearNumber])}, "-")),
  #"Transform columns 1" = Table.TransformColumnTypes(#"Add FY Text", {{"CalendarYearNumber", type text}, {"CalendarYear", type text}, {"FiscalYearNumber", type text}, {"FiscalYear", type text}}),
  #"Replace errors 2" = Table.ReplaceErrorValues(#"Transform columns 1", {{"CalendarYearNumber", null}, {"CalendarYear", null}, {"FiscalYearNumber", null}, {"FiscalYear", null}}),
  #"Add CalendarYearMonthNumber" = Table.AddColumn(#"Replace errors 2", "CalendarYearMonthNumber", each Date.Year([AdmissionDate])*12 - 1 + Date.Month([AdmissionDate])),
  #"data type CalYearMonthNumbe" = Table.TransformColumnTypes(#"Add CalendarYearMonthNumber", {{"CalendarYearMonthNumber", Int64.Type}, {"AnaestheticStartTime", type time}, {"AnaestheticFinishTime", type time}, {"OperationStartTime", type time}, {"OperatingFinishTime", type time}, {"RecoveryStartTime", type time}, {"RecoveryFinishTime", type time}}),
  #"Add AgeAtTimeOfAdmission" = Table.AddColumn(#"data type CalYearMonthNumbe", "AgeAtTimeOfAdmission", each if [DateOfBirth] = null or [AdmissionDate] = null then 
    null 
  else 
    Number.RoundDown(
        Number.From(
            (Date.From([AdmissionDate]) - Date.From([DateOfBirth])) / 365.25
        )
    )),
  #"Format AgeAtTimeOfAdmission" = Table.TransformColumnTypes(#"Add AgeAtTimeOfAdmission", {{"AgeAtTimeOfAdmission", Int64.Type}}),
  #"Add PatientAgeGroup" = Table.AddColumn(#"Format AgeAtTimeOfAdmission", "PatientAgeGroup", each if [AgeAtTimeOfAdmission] = null then "Unknown" else if [AgeAtTimeOfAdmission] = 0 then "Newborn" else if [AgeAtTimeOfAdmission] < 16 then "Child" else "Adult"),
  #"Format PatientAgeGroup" = Table.TransformColumnTypes(#"Add PatientAgeGroup", {{"PatientAgeGroup", type text}}),
  #"Add BasecostCentre" = Table.AddColumn(#"Format PatientAgeGroup", "BaseCostCentre", each let
    NotSpecialCategory = not List.Contains({"PAQ","PAU","CD","ND", "SDM", "C"}, [PatientCategoryCode]),
    SameDayMedical = List.Contains({"SDM", "C"}, [PatientCategoryCode]),
    IsMaternity = List.Contains({"CD", "ND", "PAQ", "PAU"}, [PatientCategoryCode])

in
    if [EpisodeTypeID] = "INPATIENT" and [PatientAgeGroup] = "Adult" and NotSpecialCategory then
        "SUGW"
    else if [EpisodeTypeID] = "INPATIENT" and [PatientAgeGroup] = "Child" and NotSpecialCategory then
        "PAED"
    else if [EpisodeTypeID] = "DAYPATIENT" and [PatientAgeGroup] = "Adult" and NotSpecialCategory then
        "OPTH"
    else if [EpisodeTypeID] = "DAYPATIENT" and [PatientAgeGroup] = "Child" and NotSpecialCategory then
        "OPTH"
    else if [EpisodeTypeID] = "DAYPATIENT" and [PatientAgeGroup] = "Newborn" then
        "MATE"
    else if [EpisodeTypeID] = "INPATIENT" or [EpisodeTypeID] = "DAYPATIENT" and IsMaternity then
        "MATE"
    else if SameDayMedical then
        "SAME"
    else
        "Other"),
  #"Add Theatre CostCentre" = Table.AddColumn(#"Add BasecostCentre", "TheatreCostCentre", each if [BaseCostCentre] = "SUGW" then "OPTH" else if [BaseCostCentre] = "PAED" then "OPTH" else if [BaseCostCentre] = "MATE" then "MATE" else if [BaseCostCentre] = "OPTH" then "OPTH" else if [BaseCostCentre] = "SAME" then "SAME" else "OTHER"),
  #"Add CostcentreKey" = Table.AddColumn(#"Add Theatre CostCentre", "CostCentreKey", each Text.Combine({[BaseCostCentre], [TheatreCostCentre]}, "-")),
  #"Format Cost Centre" = Table.TransformColumnTypes(#"Add CostcentreKey", {{"BaseCostCentre", type text}, {"TheatreCostCentre", type text}, {"CostCentreKey", type text}}),
  #"Add Theatre Duration" = Table.TransformColumnTypes(Table.AddColumn(#"Format Cost Centre", "TheatreDurationMinutes", each Duration.Hours([OperatingFinishTime]-[OperationStartTime])*60 + Duration.Minutes([OperatingFinishTime]-[OperationStartTime])), {{"TheatreDurationMinutes", type number}}),
  #"Add Anaeast Duration" = Table.TransformColumnTypes(Table.AddColumn(#"Add Theatre Duration", "AnaestheticDurationMinutes", each Duration.Hours([AnaestheticFinishTime]-[AnaestheticStartTime])*60 + Duration.Minutes([AnaestheticFinishTime]-[AnaestheticStartTime])), {{"AnaestheticDurationMinutes", type number}}),
  #"Add Recovery Duration" = Table.AddColumn(#"Add Anaeast Duration", "RecoveryDurationMinutes", each Duration.Hours([RecoveryFinishTime]-[RecoveryStartTime])*60 + Duration.Minutes([RecoveryFinishTime]-[RecoveryStartTime])),
  #"Replace null in duration zero" = Table.ReplaceValue(#"Add Recovery Duration", null, 0, Replacer.ReplaceValue, {"TheatreDurationMinutes", "AnaestheticDurationMinutes", "RecoveryDurationMinutes"}),
  #"Transform columns 2" = Table.TransformColumnTypes(#"Replace null in duration zero", {{"RecoveryDurationMinutes", type text}}),
  ReplaceErrors3 = Table.ReplaceErrorValues(#"Transform columns 2", {{"RecoveryDurationMinutes", null}}),
  AddAgeBracket = Table.TransformColumnTypes(
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
)
in
  AddAgeBracket