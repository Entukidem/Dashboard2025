let

    url = "https://api.riskrecon.com/v1/analysis/history/" & QHTOEID,

    // Making the API call and returning the results as a JSON object
    response = Json.Document(Web.Contents(url, [
        Headers = [
            Authorization = "Bearer " & #"Risk Recon token",
            #"Content-Type" = "application/json",
            Accept = "application/json"
        ]
    ])),
    #"Converted to Table" = Table.FromList(response, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"analysis_id", "security_domain_ratings", "trend", "rating_numeric", "rating_v2", "rating", "analysis_ts"}, {"Column1.analysis_id", "Column1.security_domain_ratings", "Column1.trend", "Column1.rating_numeric", "Column1.rating_v2", "Column1.rating", "Column1.analysis_ts"}),
    #"Replaced Value" = Table.ReplaceValue(#"Expanded Column1"," UTC","",Replacer.ReplaceText,{"Column1.analysis_ts"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Replaced Value",{{"Column1.analysis_ts", type datetime}, {"Column1.rating_numeric", type number}})
in
    #"Changed Type"