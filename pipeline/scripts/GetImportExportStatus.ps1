param (
    [Parameter(Mandatory = $true)]
    [string]$ControlRoomAPIUrl,
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [Parameter(Mandatory = $true)]
    [string]$RequestId
)

$baseUri = New-Object System.Uri($ControlRoomAPIUrl)
$relativeUri = New-Object System.Uri("v2/blm/status/$RequestId", [System.UriKind]::Relative)
$statusUrl = New-Object System.Uri($baseUri, $relativeUri)
Write-Host "statusUrl: $statusUrl"

$statusResponse = Invoke-WebRequest -Uri $statusUrl -Method Get -ContentType "application/json" -Headers @{"X-Authorization" = "$AccessToken"}

$result = @{
    DownloadFileId = $null
    Status = "InProgress"
}

if ($statusResponse.StatusCode -eq 200) {
    $responseBody = $statusResponse.Content | ConvertFrom-Json
    $status = $responseBody.status
    if ($status -eq "COMPLETED") {
        $result.DownloadFileId = $responseBody.downloadFileId
        $result.Status = "Completed"
    }
    
    if ($status -eq "FAILED") {
        $result.Status = "Failed"
        Write-Host "Export failed with status: $status and message: $($responseBody.errorMessage)"
    }
} else {
    $result.Status = "Failed"
    Write-Host "HTTP request failed with status code: $($statusResponse.StatusCode)"
}

return $result