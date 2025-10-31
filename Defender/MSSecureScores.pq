// This is Power Query that is on Power BI. It is reliant on the output of SecurityScoreData.
// This converts the data to a table and adds a date column so it can be used in a line graph showing Secure Scores for the last 90 days.
let
    Source = #"SecurityScoreData via Secret",
    value = Source[value],
    #"Converted to Table" = Table.FromList(value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"id", "azureTenantId", "activeUserCount", "createdDateTime", "currentScore", "enabledServices", "licensedUserCount", "maxScore", "vendorInformation", "averageComparativeScores", "controlScores"}, {"Column1.id", "Column1.azureTenantId", "Column1.activeUserCount", "Column1.createdDateTime", "Column1.currentScore", "Column1.enabledServices", "Column1.licensedUserCount", "Column1.maxScore", "Column1.vendorInformation", "Column1.averageComparativeScores", "Column1.controlScores"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded Column1",{"Column1.azureTenantId", "Column1.enabledServices", "Column1.licensedUserCount", "Column1.vendorInformation", "Column1.controlScores"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns",{{"Column1.currentScore", type number}, {"Column1.maxScore", type number}}),
    #"Added Index" = Table.AddIndexColumn(#"Changed Type", "Index", 0, 1, Int64.Type),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Index",{{"Column1.createdDateTime", type datetime}})
in
    #"Changed Type1"
