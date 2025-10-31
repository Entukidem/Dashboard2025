// This is Power Query that is on Power BI. It is reliant on the output of SecurityScoreData.
let
    // Pulling the latest value from the list of security scores
    Source = #"SecurityScoreData via Secret",
    value = Source[value],
    
    // Since the API call populates the list with newest first just grab the latest 
    Latest = List.First(value),
    #"Converted to Table" = Record.ToTable(Latest),
    #"Filtered Rows" = Table.SelectRows(#"Converted to Table", each ([Name] = "createdDateTime" or [Name] = "currentScore" or [Name] = "id" or [Name] = "maxScore")),
    #"Pivoted Column" = Table.Pivot(#"Filtered Rows", List.Distinct(#"Filtered Rows"[Name]), "Name", "Value"),
    #"Changed Type" = Table.TransformColumnTypes(#"Pivoted Column",{{"currentScore", type number}, {"maxScore", type number}})
in
    #"Changed Type"
