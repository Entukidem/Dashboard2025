// This Power Query exists on Power BI
let
    // Authentication information currently stored in parameters.
    TenantId = SsTenantID,
    ClientId = SsClientID,
    ClientSecret = SsGraphSecret,

    // Building token for accessing graph using the secret.
    TokenUrl = "https://login.microsoftonline.com/" & TenantId & "/oauth2/v2.0/token",
    TokenBody = "client_id=" & ClientId & "&scope=https://graph.microsoft.com/.default" & "&client_secret=" & ClientSecret & "&grant_type=client_credentials",
    TokenResponse = Json.Document(Web.Contents(TokenUrl, [
        Headers = [#"Content-Type" = "application/x-www-form-urlencoded"],
        Content = Text.ToBinary(TokenBody)
    ])),
    AccessToken = TokenResponse[access_token],

    // Calling the Secure Score endpoint using the token.
    ApiUrl = "https://graph.microsoft.com/beta/security/secureScores",
    Source = Json.Document(Web.Contents(ApiUrl, [
        Headers = [Authorization = "Bearer " & AccessToken]
    ]))
in
    // The result is a list of records containing security scores for the last 90 days.
    // This query is used by other queries to get more specific data e.g pulling the latest security score.
    Source
