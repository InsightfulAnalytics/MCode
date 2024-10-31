// length of stay column

  AddLengthOfStay = Table.AddColumn(
    ReplaceErrors, 
    "LengthOfStay", 
    each 
      if 
            [PatientCategoryCode] = "SDM"
        or  [PatientCategoryCode] = "C"
        or  [PatientCategoryCode] = "PAU"
      then
        0
      else if [AdmissionDate] = [DischargeDate] then
        1
      else
        ([DischargeDate] - [AdmissionDate])
    , 
    Int64.Type
  ),











