// This is Power Query in Power BI to retreive current critical findings from Netspi.
let
    // Returning the findings that have a severity rating of critical using the POST query endpoint.
    url = "https://platform.netspi.ai/api/query?timeout=60",
    headers = [
        #"Content-Type" = "application/json",
        #"Accept" = "*/*",
        #"X-app-name" = "Test",
        #"Authorization" = NStoken
    ],
    // the body of the response can be customized for the desired output.
    // In this case I retreive all findings that are critical and currently not tagged as remediated.
    body = "{
""model"": ""finding"",
    ""columns"": [
    {
    ""column"": ""id""
    },
    {
    ""column"": ""name""
    },
    {
    ""column"": ""assetLabel""
    },
    {
    ""column"": ""severityId""
    },
    {
    ""column"": ""affectedUrl""
    },
    {
    ""column"": ""verificationCount""
    },
    {
    ""column"": ""assetName""
    },
    {
    ""column"": ""attackParameter""
    },
    {
    ""column"": ""remediationInstructions""
    },
    {
    ""column"": ""state""
    },
    {
    ""column"": ""updatedAt""
    },
    {
    ""column"": ""verificationInstructions""
    },
    {
    ""column"": ""affectedSource""
    },
    {
    ""column"": ""affectedSourceLine""
    },
    {
    ""column"": ""description""
    },
    {
    ""column"": ""businessImpact""
    },
    {
    ""column"": ""cvssV2Vector""
    },
    {
    ""column"": ""cvssV3Vector""
    },
    {
    ""column"": ""references""
    },
    {
    ""column"": ""firstSeenAt""
    },
    {
    ""column"": ""lastSeenAt""
    },
    {
    ""column"": ""remediationDueDate""
    },
    {
    ""column"": ""verifications""
    },
    {
    ""column"": ""globalFindingId""
    },
    {
    ""column"": ""consolidatedFindingId""
    },
    {
    ""column"": ""findingGroupId""
    },
    {
    ""column"": ""owasp2021""
    },
    {
    ""column"": ""owaspApi2023""
    },
    {
    ""column"": ""owaspMobile2016""
    },
    {
    ""column"": ""tags""
    },
    {
    ""column"": ""state""
    }
    ],
    ""filters"": [
    {
    ""column"": ""severityId"",
    ""condition"": ""EQ"",
    ""values"": [
    ""4""
    ]
    },
    {
    ""column"": ""state"",
    ""condition"": ""neq"",
    ""values"": [
    ""remediated""
    ]
    }
    
    ],
    ""pagination"": true,
    ""offset"": 1,
    ""limit"": 1000,
    ""clientId"": ""1066""

    }",
    // Severity ID:
    // Critical == 4
    // high == 3
    // medium == 2
    // Low == 1
    // Informational == -2
    response = Json.Document(
        Web.Contents(
            url,
            [
                Headers = headers,
                Content = Text.ToBinary(body),
                ManualStatusHandling = {400, 404, 500}
            ]
        )
    ),
    content = response[content],
    // Conversion to a table for use in Power BI charts.
    #"Converted to Table" = Table.FromList(content, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"id", "name", "assetLabel", "severityId", "affectedUrl", "verificationCount", "assetName", "attackParameter", "remediationInstructions", "state", "updatedAt", "affectedSource", "affectedSourceLine", "description", "businessImpact", "cvssV2Vector", "cvssV3Vector", "references", "firstSeenAt", "lastSeenAt", "remediationDueDate", "verifications", "globalFindingId", "consolidatedFindingId", "findingGroupId", "owasp2021", "owaspMobile2016", "tags"}, {"id", "name", "assetLabel", "severityId", "affectedUrl", "verificationCount", "assetName", "attackParameter", "remediationInstructions", "state", "updatedAt", "affectedSource", "affectedSourceLine", "description", "businessImpact", "cvssV2Vector", "cvssV3Vector", "references", "firstSeenAt", "lastSeenAt", "remediationDueDate", "verifications", "globalFindingId", "consolidatedFindingId", "findingGroupId", "owasp2021", "owaspMobile2016", "tags"})
in
    #"Expanded Column1"
