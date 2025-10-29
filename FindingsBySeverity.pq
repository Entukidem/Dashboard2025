// This is Power Query in Power BI to retreive findings numbers by their severity.

// The endpoint and body for this request was found by inspecting the webpage,
// going to the network tab and looking for the query that correlated with the 
// 'FindingsBySeverity' chart. The other charts on the webpage can be recreated using the same method.
let
    // Code for getting date of exactly a month ago.
    CurrentDate = DateTime.Date(DateTime.LocalNow()),
    OneMonthAgo = Date.AddMonths(CurrentDate, -1),
    FormattedDate = Date.ToText(OneMonthAgo, "yyyy-MM-dd"),

    // This api endpoint provides lets you get data based on time.
    url = "https://platform.netspi.ai/api/time-series?timeout=60",
    headers = [
        #"Content-Type" = "application/json",
        #"Accept" = "*/*",
        // App name seems to be necessary to make Netspi API calls.
        #"X-app-name" = "Test",
        #"Authorization" = NStoken
    ],
    // This endpoint is a POST request and allows you to customize the response
    body = "{
    ""model"": ""finding_count_time_series"",
    ""clientId"": 1066,
    ""columns"": [
        {
            ""column"": ""day""
        },
        {
            ""column"": ""publishedUnresolvedUrgentFindings"",
            ""groupBy"": true
        },
        {
            ""column"": ""publishedUnresolvedCriticalFindings"",
            ""groupBy"": true
        },
        {
            ""column"": ""publishedUnresolvedHighFindings"",
            ""groupBy"": true
        },
        {
            ""column"": ""publishedUnresolvedMediumFindings"",
            ""groupBy"": true
        },
        {
            ""column"": ""publishedUnresolvedLowFindings"",
            ""groupBy"": true
        },
        {
            ""column"": ""publishedUnresolvedInformationalFindings"",
            ""groupBy"": true
        }
    ],
    ""filters"": [
        {
            ""column"": ""identifiedBy"",
            ""condition"": ""EQ"",
            ""values"": [
                ""1""
            ]
        },
        {
            ""column"": ""day"",
            ""condition"": ""GTE"",
            ""values"": [
                """&FormattedDate&"""
            ]
        }
    ]
}",
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
    // The output is converted to a table so the data can be used in a graph. Some of the column names are changed for readability.
    #"Converted to Table" = Table.FromList(content, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"day", "publishedUnresolvedUrgentFindings", "publishedUnresolvedCriticalFindings", "publishedUnresolvedHighFindings", "publishedUnresolvedMediumFindings", "publishedUnresolvedLowFindings", "publishedUnresolvedInformationalFindings"}, {"Column1.day", "Column1.publishedUnresolvedUrgentFindings", "Column1.publishedUnresolvedCriticalFindings", "Column1.publishedUnresolvedHighFindings", "Column1.publishedUnresolvedMediumFindings", "Column1.publishedUnresolvedLowFindings", "Column1.publishedUnresolvedInformationalFindings"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Column1",{{"Column1.publishedUnresolvedCriticalFindings", Int64.Type}, {"Column1.publishedUnresolvedHighFindings", Int64.Type}, {"Column1.publishedUnresolvedMediumFindings", Int64.Type}, {"Column1.publishedUnresolvedLowFindings", Int64.Type}, {"Column1.publishedUnresolvedInformationalFindings", Int64.Type}, {"Column1.day", type datetime}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Column1.publishedUnresolvedUrgentFindings", "urgent"}, {"Column1.publishedUnresolvedCriticalFindings", "Critical"}, {"Column1.publishedUnresolvedHighFindings", "High"}, {"Column1.publishedUnresolvedMediumFindings", "Medium"}, {"Column1.publishedUnresolvedLowFindings", "Low"}, {"Column1.publishedUnresolvedInformationalFindings", "Informational"}}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Renamed Columns",{{"urgent", Int64.Type}})
in
    #"Changed Type1"