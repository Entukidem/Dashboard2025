let
    // Risk recon API. 
    // QH's TOE ID can be found on the RR website or by finding it in this API response https://api.riskrecon.com/v1/toes
    url = "https://api.riskrecon.com/v1/toe/" & QHTOEID,
    
    // Making the API call and returning the results as a JSON object
    response = Json.Document(Web.Contents(url, [
        Headers = [
            Authorization = "Bearer " & #"Risk Recon token",
            #"Content-Type" = "application/json",
            Accept = "application/json"
        ]
    ])),
    // Converting the data to a table to work with it
    #"Converted to Table" = Record.ToTable(response),
    #"Transposed Table" = Table.Transpose(#"Converted to Table"),
    #"Promoted Headers" = Table.PromoteHeaders(#"Transposed Table", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"toe_id", type text}, {"subscription_level", type text}, {"internal_name", type any}, {"internal_id", type any}, {"seed_hostnames", type any}, {"toe_short_name", type text}, {"analysis_id", Int64.Type}, {"risk_configurations", type any}, {"network_filtering_rating", Int64.Type}, {"web_encryption_rating", type number}, {"web_app_security_rating", type number}, {"threat_intell_rating", Int64.Type}, {"system_hosting_rating", type number}, {"software_patching_rating", Int64.Type}, {"governance_rating", Int64.Type}, {"email_security_rating", Int64.Type}, {"dns_security_rating", type number}, {"defensibility_rating", Int64.Type}, {"data_loss_rating", Int64.Type}, {"ticker_symbols", type any}, {"rating_numeric", type number}, {"rating_v2", type text}, {"rating", type text}, {"duns_numbers", type any}, {"analysis_ts", type text}, {"analysis_type", type text}})
    
in
    #"Changed Type"
