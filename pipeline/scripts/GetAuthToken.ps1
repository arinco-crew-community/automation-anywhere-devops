param(
    [Parameter(Mandatory = $true)]
    [string]$ControlRoomAPIUrl,
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [Parameter(Mandatory = $true)]
    [string]$ApiKey
)

$baseUri = New-Object System.Uri($ControlRoomAPIUrl)
$relativeUri = New-Object System.Uri("v1/authentication", [System.UriKind]::Relative)
$authUrl = New-Object System.Uri($baseUri, $relativeUri)
Write-Host "authUrl: $authUrl"

$usernameJson = $Username | ConvertTo-Json
$apiKeyJson = $ApiKey | ConvertTo-Json
$requestBody = ('{{"username": {0}, "apiKey": {1}}}' -f $usernameJson, $apiKeyJson)
 
# Use Invoke-WebRequest to get the response
$response = Invoke-WebRequest -Uri $authUrl -Method Post -ContentType "application/json" -Body $requestBody

$result = @{
  Token = $null
  Success = $false
}
 
# Check the status code
if ($response.StatusCode -eq 200) {
    $responseBody = $response.Content | ConvertFrom-Json
    $result.AccessToken = $responseBody.token
    $result.Success = $true
} else {
    Write-Host "HTTP request failed with status code: $($response.StatusCode)"
}

return $result