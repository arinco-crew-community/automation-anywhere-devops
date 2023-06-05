param (
    [Parameter(Mandatory = $true)]
    [string]$ControlRoomAPIUrl,
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [Parameter(Mandatory = $true)]
    [string]$ArchivePath,
    [Parameter(Mandatory = $true)]
    [string]$ArchiveName,    
    [Parameter(Mandatory = $true)]
    [string]$ArchivePassword,
    [Parameter(Mandatory = $false)]
    [string]$ActionIfExisting = "OVERWRITE",
    [Parameter(Mandatory = $false)]
    [bool]$PublicWorkspace = $true
)

$baseUri = New-Object System.Uri($ControlRoomAPIUrl)
$relativeUri = New-Object System.Uri("v2/blm/import", [System.UriKind]::Relative)
$importUrl = New-Object System.Uri($baseUri, $relativeUri)

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Authorization", "$AccessToken")

$multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
$FileStream = [System.IO.FileStream]::new($ArchivePath, [System.IO.FileMode]::Open)
$fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$fileHeader.Name = "upload"
$fileHeader.FileName = "$ArchiveName"
$fileContent = [System.Net.Http.StreamContent]::new($FileStream)
$fileContent.Headers.ContentDisposition = $fileHeader
$multipartContent.Add($fileContent)

$stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$stringHeader.Name = "actionIfExisting"
$stringContent = [System.Net.Http.StringContent]::new($ActionIfExisting)
$stringContent.Headers.ContentDisposition = $stringHeader
$multipartContent.Add($stringContent)

$stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$stringHeader.Name = "publicWorkspace"
$stringContent = [System.Net.Http.StringContent]::new($PublicWorkspace)
$stringContent.Headers.ContentDisposition = $stringHeader
$multipartContent.Add($stringContent)

$stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$stringHeader.Name = "archivePassword"
$stringContent = [System.Net.Http.StringContent]::new("$ArchivePassword")
$stringContent.Headers.ContentDisposition = $stringHeader
$multipartContent.Add($stringContent)

$response = Invoke-WebRequest -Uri $importUrl -Method 'POST' -Headers $headers -Body $multipartContent

$result = @{
    Success = $false
    RequestId = $null
}

if ($response.StatusCode -eq 202) {
    $responseBody = $response.Content | ConvertFrom-Json
    $requestId = $responseBody.requestId
    $result.Success = $true
    $result.RequestId = $requestId
    Write-Host "Import has been accepted with Import ID: $requestId"
} else {
    Write-Host "Import has failed with status code: $response.StatusCode"
}

return $result