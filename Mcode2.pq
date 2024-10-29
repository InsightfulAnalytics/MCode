

// Basic theroy:

  let
      Source1 = 
          let
              Internal1 = 1
          in
              Internal1
      , Source2 =
          let
              Internal2 = 2
          in
              Internal2
  in
      Source2



= Table.Combine({#"Hours Same Day Shifts", #"Hours Overnight Start Shift", #"Hours Overnight End Shift", #"Hours Time Off", #"Hours Incomplete"})

// Backup of combine query

let
    Source = Table.Combine({#"Hours Same Day Shifts", #"Hours Overnight Start Shift", #"Hours Overnight End Shift", #"Hours Time Off", #"Hours Incomplete"})
in
    Source



let
  HoursOverNightStartShift =
    // Hours Overnight Start Shift
    let
        Source = PowerPlatform.Dataflows(null),
        Workspaces = Source{[Id="Workspaces"]}[Data],
        #"a6717a81-d48a-48c7-bafa-d33d04d08433" = Workspaces{[workspaceId="a6717a81-d48a-48c7-bafa-d33d04d08433"]}[Data],
        #"f3e170fd-1590-4850-9245-a25c896cd495" = #"a6717a81-d48a-48c7-bafa-d33d04d08433"{[dataflowId="f3e170fd-1590-4850-9245-a25c896cd495"]}[Data],
        FactEmployeeHours_ = #"f3e170fd-1590-4850-9245-a25c896cd495"{[entity="FactEmployeeHours",version=""]}[Data],
        ReplaceBlankWithNull = 
            Table.ReplaceValue(
                FactEmployeeHours_, 
                "", 
                null, 
                Replacer.ReplaceValue, 
                Table.ColumnNames(FactEmployeeHours_)
            ),
        AddEndShiftDate = 
            Table.AddColumn(
                ReplaceBlankWithNull,
                "Work End Date",
                each 
                    try 
                        Date.AddDays (
                            [WorkDate],
                            if 
                                [EndTime] < [StartTime]    
                            then
                                1
                            else
                                0
                        ) 
                    otherwise 
                        null
                ,
                type date
            ),
        FilterOutIncompleteRecords = Table.SelectRows(AddEndShiftDate, each ([Is Time Off] = null) and ([EndTime] <> null) and ([StartTime] <> null)),
        OverNightShiftColumn = Table.AddColumn(
        FilterOutIncompleteRecords,
        "Overnight Shift",
        each 
            if 
                [EndTime] < [StartTime]    
            then
                1
            else
                0
        ,
        type text
        ),
        FilterOvernightShifts = Table.SelectRows(OverNightShiftColumn, each ([Overnight Shift] = 1)),
        AddEndTimeOvernight = Table.AddColumn(
        FilterOvernightShifts,
        "EndTime Overnight",
        each 
            #time (23,59,0)
        ,
        type time
        ),
        RemoveOriginalEndTime = Table.RemoveColumns(AddEndTimeOvernight,{"EndTime"}),
        RenameEndTime = Table.RenameColumns(RemoveOriginalEndTime,{{"EndTime Overnight", "EndTime"}}),
        AddColumnType = Table.AddColumn(
        RenameEndTime,
        "Type",
        each 
            "Overnight Start Shift"
        ,
        type text
        ),
        RemoveColumns = Table.RemoveColumns(AddColumnType,{"Overnight Shift", "Work End Date"}),
        MinutesWorked = 
            Table.AddColumn(
                RemoveColumns,
                "Minutes Worked",
                each 
                    try
                        Duration.TotalMinutes([EndTime] - [StartTime])
                    otherwise
                        null
                ,
                type number 
            )
    in
        MinutesWorked

  , HoursOverNightEndShift =

      // Hours Overnight End Shift
      let
          Source = PowerPlatform.Dataflows(null),
          Workspaces = Source{[Id="Workspaces"]}[Data],
          #"a6717a81-d48a-48c7-bafa-d33d04d08433" = Workspaces{[workspaceId="a6717a81-d48a-48c7-bafa-d33d04d08433"]}[Data],
          #"f3e170fd-1590-4850-9245-a25c896cd495" = #"a6717a81-d48a-48c7-bafa-d33d04d08433"{[dataflowId="f3e170fd-1590-4850-9245-a25c896cd495"]}[Data],
          FactEmployeeHours_ = #"f3e170fd-1590-4850-9245-a25c896cd495"{[entity="FactEmployeeHours",version=""]}[Data],
          ReplaceBlankWithNull = 
              Table.ReplaceValue(
                  FactEmployeeHours_, 
                  "", 
                  null, 
                  Replacer.ReplaceValue, 
                  Table.ColumnNames(FactEmployeeHours_)
              ),
          AddEndShiftDate = 
              Table.AddColumn(
                  ReplaceBlankWithNull,
                  "Work End Date",
                  each 
                      try 
                          Date.AddDays (
                              [WorkDate],
                              if 
                                  [EndTime] < [StartTime]    
                              then
                                  1
                              else
                                  0
                          ) 
                      otherwise 
                          null
                  ,
                  type date
              ),
          FilterOutIncompleteRecords = Table.SelectRows(AddEndShiftDate, each ([Is Time Off] = null) and ([EndTime] <> null) and ([StartTime] <> null)),
          OverNightShiftColumn = Table.AddColumn(
          FilterOutIncompleteRecords,
          "Overnight Shift",
          each 
              if 
                  [EndTime] < [StartTime]    
              then
                  1
              else
                  0
          ,
          type text
          ),
          FilterOvernightShifts = Table.SelectRows(OverNightShiftColumn, each ([Overnight Shift] = 1)),
          AddStartTimeOvernight = Table.AddColumn(
          FilterOvernightShifts,
          "StartTime Overnight",
          each 
              #time (00,00,0)
          ,
          type time
        ),
          RemoveOriginalEndTime = Table.RemoveColumns(AddStartTimeOvernight,{"StartTime"}),
          RenameEndTime = Table.RenameColumns(RemoveOriginalEndTime,{{"StartTime Overnight", "StartTime"}}),
          AddTypeColumn = Table.AddColumn(
          RenameEndTime,
          "Type",
          each 
              "Overnight End Shift"
          ,
          type text
          ),
          RemoveColumns = Table.RemoveColumns(AddTypeColumn,{"Overnight Shift", "WorkDate"}),
          RenameColumn = Table.RenameColumns(RemoveColumns,{{"Work End Date", "WorkDate"}}),
          MinutesWorked = 
              Table.AddColumn(
                  RenameColumn,
                  "Minutes Worked",
                  each 
                      try
                          Duration.TotalMinutes(  [EndTime]  - [StartTime]   )
                      otherwise
                          null
                  ,
                  type number 
              )
      in
          MinutesWorked
  
  , HoursSameDayShift =
      // Hours Same Day Shifts
      let
          Source = PowerPlatform.Dataflows(null),
          Workspaces = Source{[Id="Workspaces"]}[Data],
          #"a6717a81-d48a-48c7-bafa-d33d04d08433" = Workspaces{[workspaceId="a6717a81-d48a-48c7-bafa-d33d04d08433"]}[Data],
          #"f3e170fd-1590-4850-9245-a25c896cd495" = #"a6717a81-d48a-48c7-bafa-d33d04d08433"{[dataflowId="f3e170fd-1590-4850-9245-a25c896cd495"]}[Data],
          FactEmployeeHours_ = #"f3e170fd-1590-4850-9245-a25c896cd495"{[entity="FactEmployeeHours",version=""]}[Data],
          ReplaceBlankWithNull = 
              Table.ReplaceValue(
                  FactEmployeeHours_, 
                  "", 
                  null, 
                  Replacer.ReplaceValue, 
                  Table.ColumnNames(FactEmployeeHours_)
              ),
          AddEndShiftDate = 
              Table.AddColumn(
                  ReplaceBlankWithNull,
                  "Work End Date",
                  each 
                      try 
                          Date.AddDays (
                              [WorkDate],
                              if 
                                  [EndTime] < [StartTime]    
                              then
                                  1
                              else
                                  0
                          ) 
                      otherwise 
                          null
                  ,
                  type date
              ),
          FilterOutIncompleteRecords = Table.SelectRows(AddEndShiftDate, each ([Is Time Off] = null) and ([EndTime] <> null) and ([StartTime] <> null)),
          OverNightShiftColumn = Table.AddColumn(
          FilterOutIncompleteRecords,
          "Overnight Shift",
          each 
              if 
                  [EndTime] < [StartTime]    
              then
                  1
              else
                  0
          ,
          type text
          ),
          FilterOvernightShifts = Table.SelectRows(OverNightShiftColumn, each ([Overnight Shift] = 0)),
          AddTypeColumn = Table.AddColumn(
          FilterOvernightShifts,
          "Type",
          each 
              "Day Shift"
          ,
          type text
          ),
          RemoveColumns = Table.RemoveColumns(AddTypeColumn,{"Overnight Shift", "Work End Date"}),
          AddMinutesWorkedColumn = 
              Table.AddColumn(
                  RemoveColumns,
                  "Minutes Worked",
                  each 
                      try
                          Duration.TotalMinutes([EndTime] - [StartTime])
                      otherwise
                          null
                  ,
                  type number 
              )
      in
          AddMinutesWorkedColumn
  
  , HoursTimeOff =
      // Hours Time Off
      let
          Source = PowerPlatform.Dataflows(null),
          Workspaces = Source{[Id="Workspaces"]}[Data],
          #"a6717a81-d48a-48c7-bafa-d33d04d08433" = Workspaces{[workspaceId="a6717a81-d48a-48c7-bafa-d33d04d08433"]}[Data],
          #"f3e170fd-1590-4850-9245-a25c896cd495" = #"a6717a81-d48a-48c7-bafa-d33d04d08433"{[dataflowId="f3e170fd-1590-4850-9245-a25c896cd495"]}[Data],
          FactEmployeeHours_ = #"f3e170fd-1590-4850-9245-a25c896cd495"{[entity="FactEmployeeHours",version=""]}[Data],
          ReplaceBlankWithNull = 
              Table.ReplaceValue(
                  FactEmployeeHours_, 
                  "", 
                  null, 
                  Replacer.ReplaceValue, 
                  Table.ColumnNames(FactEmployeeHours_)
              ),
          AddEndShiftDate = 
              Table.AddColumn(
                  ReplaceBlankWithNull,
                  "Work End Date",
                  each 
                      try 
                          Date.AddDays (
                              [WorkDate],
                              if 
                                  [EndTime] < [StartTime]    
                              then
                                  1
                              else
                                  0
                          ) 
                      otherwise 
                          null
                  ,
                  type date
              ),
          FilterTimeOff = Table.SelectRows(AddEndShiftDate, each ([Is Time Off] = "Y")),
          AddTypeColumn = Table.AddColumn(
          FilterTimeOff,
          "Type",
          each 
              "Time Off"
          ,
          type text
          ),
          AddMinutesWorkedColumn = Table.AddColumn(
              AddTypeColumn,
              "Minutes Worked",
              each 
                  try
                      [HoursWorked] * 60
                  otherwise
                      null
              ,
              type number 
          )
      in
          AddMinutesWorkedColumn

  , HoursIncomplete = 
    // Hours Incomplete
    let
        Source = PowerPlatform.Dataflows(null),
        Workspaces = Source{[Id="Workspaces"]}[Data],
        #"a6717a81-d48a-48c7-bafa-d33d04d08433" = Workspaces{[workspaceId="a6717a81-d48a-48c7-bafa-d33d04d08433"]}[Data],
        #"f3e170fd-1590-4850-9245-a25c896cd495" = #"a6717a81-d48a-48c7-bafa-d33d04d08433"{[dataflowId="f3e170fd-1590-4850-9245-a25c896cd495"]}[Data],
        FactEmployeeHours_ = #"f3e170fd-1590-4850-9245-a25c896cd495"{[entity="FactEmployeeHours",version=""]}[Data],
        PriorStep = FactEmployeeHours_,
        ReplaceBlankWithNull = 
            Table.ReplaceValue(
                PriorStep, 
                "", 
                null, 
                Replacer.ReplaceValue, 
                Table.ColumnNames(PriorStep)
            ),
        AddEndShiftDate = 
            Table.AddColumn(
                ReplaceBlankWithNull,
                "Work End Date",
                each 
                    try 
                        Date.AddDays (
                            [WorkDate],
                            if 
                                [EndTime] < [StartTime]    
                            then
                                1
                            else
                                0
                        ) 
                    otherwise 
                        null
                ,
                type date
            ),
        FilterIncompleteRecords = Table.SelectRows(AddEndShiftDate, each ([Is Time Off] <> "Y") and ( ([EndTime] = null) or ([StartTime] = null)) ),
        AddTypeColumn = Table.AddColumn(
        FilterIncompleteRecords,
        "Type",
        each 
            "Incomplete Records"
        ,
        type text
        ),
        AddMinutesWorkedColumn = Table.AddColumn(
            AddTypeColumn,
            "Minutes Worked",
            each 
                try
                    [HoursWorked] * 60
                otherwise
                    null
            ,
            type number 
        ),
        FilteredRows = Table.SelectRows(AddMinutesWorkedColumn, each ([WorkDate] <> null))
    in
        FilteredRows
  
  , CombineResults = Table.Combine ({HoursOverNightStartShift, HoursOverNightEndShift, HoursSameDayShift, HoursTimeOff, HoursIncomplete})

in
  CombineResults


