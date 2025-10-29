# This python script is put into power query to create a dataframe of Absolute device data
import time
import requests
import pandas as pd
import json
from authlib.jose import JsonWebSignature

# Fill in the token ID for your API token (in power query inject a parameter here)
token_id = ""
# Fill in the secret key for your API token (in power query inject a parameter here)
token_secret = ""


### Code snippet from "Update the request example" defining the "request" variable goes here ...
request = {
    "method": "GET",
    "contentType": "application/json",
    "uri": "/v3/reporting/devices",
    # The queryString is URL encoded
    # Agent status A = Active, This fetches only active devices as that is most relevant and lines up with the report in the console
    "queryString": "agentStatus=A&pageSize=500",
    # For GET requests, the payload is empty
    "payload": {}
}

request_payload_data = {
    "data": request["payload"]
}
headers = {
    "alg": "HS256",
    "kid": token_id,
    "method": request["method"],
    "content-type": request["contentType"],
    "uri": request["uri"],
    "query-string": request["queryString"],
    "issuedAt": round(time.time() * 1000)
}


jws = JsonWebSignature()
signed = jws.serialize_compact(headers, json.dumps(request_payload_data), token_secret)


# Make the actual request
# Update the request_url, if required:
# If you log in to https://cc.absolute.com,
# use https://api.absolute.com/jws/validate.
# If you log in to https://cc.us.absolute.com,
# use https://api.us.absolute.com/jws/validate.
# If you log in to https://cc.eu2.absolute.com,
# use https://api.eu2.absolute.com/jws/validate.
# If you log in to https://cc.fr1.absolutegov.com, 
# use https://api.fr1.absolutegov.com/jws/validate.
request_url = "https://api.absolute.com/jws/validate"
r = requests.post(request_url, signed, {"content-type": "text/plain"})

# format the response as JSON
response_json = r.json()

# Building the DataFrame with desired columns, these can be adjusted as needed.
# Power BI Requires a dataframe or csv to import
df = pd.DataFrame(columns=["deviceUid", "encryptionStatus", "OS name", "OS Version", "OS UBR", "antivirusName", "antivirusVersion", "antivirusDefinition"])

# Process the initial page of data (first 500 records)
for item in response_json["data"]:
    # Append each record to the DataFrame, if you change the columns above, adjust here too
    df = pd.concat([df, pd.DataFrame({
        "deviceUid": item.get("deviceUid", "No Data"),
        "encryptionStatus": item.get("espInfo", {}).get("encryptionStatus", "No Data"),
        "OS name": item.get("operatingSystem", {}).get("name", "No Data"),
        "OS Version": item.get("operatingSystem", {}).get("version", "No Data"),
        "OS UBR": item.get("operatingSystem", {}).get("ubr", ""),
        "antivirusName": item.get("avpInfo", {}).get("antivirusName", "No Data"),
        "antivirusVersion": item.get("avpInfo", {}).get("antivirusVersion", "No Data"),
        "antivirusDefinition": item.get("avpInfo", {}).get("antivirusDefinition", "No Data"),
    }, index=[0])], ignore_index=True)
# Check for nextPage token in the response. This is used for pagination.
next_page = response_json.get("metadata", {}).get("pagination", {}).get("nextPage")


# Handle pagination (Continue to fetch pages while nextPage token is present)
while next_page:
    # Update queryString for next page
    request["queryString"] = "agentStatus=A&pageSize=500&nextPage=" + next_page
    headers["query-string"] = "agentStatus=A&pageSize=500&nextPage=" + next_page
    headers["issuedAt"] = round(time.time() * 1000)  # Update timestamp

    # Re-sign the request with updated headers
    signed = jws.serialize_compact(headers, json.dumps(request_payload_data), token_secret)

    r = requests.post(request_url, signed, {"content-type": "text/plain"})
    response_json = r.json()

    # Process data, if you change the columns above, adjust here too
    for item in response_json["data"]:
        df = pd.concat([df, pd.DataFrame({
            "deviceUid": item.get("deviceUid", "No Data"),
            "encryptionStatus": item.get("espInfo", {}).get("encryptionStatus", "No Data"),
            "OS name": item.get("operatingSystem", {}).get("name", "No Data"),
            "OS Version": item.get("operatingSystem", {}).get("version", "No Data"),
            "OS UBR": item.get("operatingSystem", {}).get("ubr", ""),
            "antivirusName": item.get("avpInfo", {}).get("antivirusName", "No Data"),
            "antivirusVersion": item.get("avpInfo", {}).get("antivirusVersion", "No Data"),
            "antivirusDefinition": item.get("avpInfo", {}).get("antivirusDefinition", "No Data"),
        }, index=[0])], ignore_index=True)

        
    next_page = response_json.get("metadata", {}).get("pagination", {}).get("nextPage")

# Editing the encryption status value names to be more descriptive
# Names based on Absolute documentation https://api.absolute.com/api-doc/doc.html#tag/Device-Reporting/operation/get-devices
# along with the way they are displayed in the Absolute console
df['encryptionStatus'] = df['encryptionStatus'].replace({
    'USENCR': 'Used Space Encrypted',
    'ENCR': 'Encrypted',
    'SUSP': 'Suspended',
    'NO DATA': 'No Data',
    'INPR': 'Encryption In Progress',
    'INST': 'Not Encrypted',
    'DECRINPR': '(Windows only): the system drive is in the process of being decrypted by BitLocker Drive Encryption',
    'UNKN': 'Encryption product not detected',
})





