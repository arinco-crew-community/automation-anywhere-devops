param (
    [Parameter(Mandatory = $true)]
    [string]$ControlRoomAPIUrl,
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [Parameter(Mandatory = $true)]
    [string]$BotIds
)

$baseUri = New-Object System.Uri($ControlRoomAPIUrl)
$relativeUri = New-Object System.Uri("v2/blm/export", [System.UriKind]::Relative)
$exportUrl = New-Object System.Uri($baseUri, $relativeUri)
Write-Host "exportUrl: $exportUrl"

$exportName = "AutomationAnywherePipeline$(Get-Date -Format 'yyyyMMddHHmmss')"
Write-Host "exportName: $exportName"

$archivePassword = [guid]::NewGuid().ToString()

Write-Host "BotIds: $BotIds"
if($BotIds -like "*,*") {
    $botIdsArray = @($BotIds -split ",") | ForEach-Object { , [int]$_ }
} else {
    $botIdsArray = @([int]$BotIds)
}

# Use Invoke-WebRequest to get the response
$requestBody = @{
    name = $exportName
    fileIds = $botIdsArray
    includePackages = $true
    archivePassword = $archivePassword
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri $exportUrl -Method Post -ContentType "application/json" -Headers @{"X-Authorization" = "$AccessToken"} -Body $requestBody

$result = @{
    ArchivePassword = $archivePassword
    Success = $false
    RequestId = $null
}

if ($response.StatusCode -eq 202) {
    $responseBody = $response.Content | ConvertFrom-Json
    $requestId = $responseBody.requestId
    $result.RequestId = $requestId
    $result.Success = $true
    Write-Host "Export Request was accepted with ID: $requestId"
} else {
    Write-Host "HTTP request failed with status code: $($response.StatusCode)"
}

return $result
