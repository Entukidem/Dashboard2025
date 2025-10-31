# Authorization for API (retrieve token safely)
$token = “”
$headers = @{
    " Authorization"  = " Bearer $token" 
    " Content-Type"   = " application/json" 
    " Accept"         = " application/json" 
}

# Gathering data from phishing campaigns
$campaigns = Invoke-RestMethod -Uri
" https://us.api.knowbe4.com/v1/phishing/campaigns"  -Method Get -Headers $headers

# Filtering campaigns by active status.
$activeCampaigns = $campaigns #| Where-Object { $_.status -eq " Active"  }

# Outputting data to the terminal
$activeCampaigns | Format-List -Property campaign_id, name,
last_phish_prone_percentage, Last_run, status

# Creating Directory for CSV files if it does not exist
if (-not (Test-Path -Path " ./ScriptOutput"  )) {
    New-item -Path " ./"  -Name " ScriptOutput"  -ItemType " Directory" 
}

# Clearing data in CSV file so it doesn&#39 t replicate data when script is run again
if ((Test-Path -Path " ./ScriptOutput/Knowbe4CampaignsData.csv"  )) {

    Clear-Content -Path ./ScriptOutput/Knowbe4CampaignsData.csv
}

# Loop through list of active campaigns and assign to an object
foreach ($i in $activeCampaigns) {
    $campaignCsvObject = [PSCustomObject]@{
    Campaign_id = $i.campaign_id
    Name = $i.name
    PhishPronePercentage = $i.last_phish_prone_percentage
    Last_run = $i.Last_run
    Status = $i.status
    RoundedPercentage = [Math]::Round($i.last_phish_prone_percentage , 1)
    Create = $i.create_date
    }

    # Creating/adding data to Knowbe4CampaignsData.csv file
    $campaignCsvObject | Export-Csv -Path ./ScriptOutput/Knowbe4CampaignsData.csv
-NoTypeInformation -Append
}
