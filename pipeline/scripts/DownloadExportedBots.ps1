param (
    [Parameter(Mandatory = $true)]
    [string]$ControlRoomAPIUrl,
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [Parameter(Mandatory = $true)]
    [string]$DownloadFileId,
    [Parameter(Mandatory = $true)]
    [string]$PipelineWorkspace
)

$downloadUrl = "$ControlRoomAPIUrl/v2/blm/download/$DownloadFileId"
Write-Host "downloadUrl: $downloadUrl"
$downloadResponse = Invoke-WebRequest -Uri $downloadUrl -Method Get -ContentType "application/json" -Headers @{"X-Authorization" = "$AccessToken"}

$result = @{
    Success = $false
    ArchivePath = $null
}

if ($downloadResponse.StatusCode -eq 200) {
    $responseBody = $downloadResponse.Content
    $archivePath = "$PipelineWorkspace/$DownloadFileId.zip"
    [System.IO.File]::WriteAllBytes($archivePath, $responseBody)
    Write-Host "Download successful"
    Write-Host "File saved to: $archivePath"
    $result.Success = $true
    $result.ArchivePath = $archivePath
} else {
    Write-Host "HTTP request failed with status code: $($downloadResponse.StatusCode)"
}

return $result