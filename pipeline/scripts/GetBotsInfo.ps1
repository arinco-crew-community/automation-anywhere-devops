param (
    [Parameter(Mandatory = $true)]
    [string]$ControlRoomAPIUrl,
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [Parameter(Mandatory = $true)]
    [string]$BotIds
)

$baseUri = New-Object System.Uri($ControlRoomAPIUrl)
$relativeUri = New-Object System.Uri("v2/repository/workspaces/public/files/list", [System.UriKind]::Relative)
$publicFilesListUrl = New-Object System.Uri($baseUri, $relativeUri)
Write-Host "publicFilesListUrl: $publicFilesListUrl"

Write-Host "BotIds: $BotIds"
if($BotIds -like "*,*") {
    $botIdsArray = @($BotIds -split ",") | ForEach-Object { , [string]$_ }
} else {
    $botIdsArray = @([string]$BotIds)
}

# create the "or" operand for each bot ID
$orOperands = $botIdsArray | ForEach-Object {
    [ordered]@{
        operator = "eq"
        field = "id"
        value = $_
    }
}

# construct the filter
$filter = [ordered]@{
    operator = "and"
    operands = @(
        [ordered]@{
            operator = "eq"
            field = "type"
            value = "application/vnd.aa.taskbot"
        },
        [ordered]@{
            operator = "or"
            operands = $orOperands
        }
    )
}

# construct the sort
$sort = @(
    [ordered]@{
        field = "name"
        direction = "asc"
    }
)

# construct the page
$page = [ordered]@{
    offset = 0
    length = $botIdsArray.Length
}

# construct the final request body
$requestBody = [ordered]@{
    filter = $filter
    sort = $sort
    page = $page
}

# convert to JSON
$jsonRequestBody = $requestBody | ConvertTo-Json -Depth 5

# output the JSON request body
write-host "JSON request body:"
Write-Host $jsonRequestBody

# initialize result
$result = @{
    Success = $false
    Bots = @()
}

try {
    # send the HTTP request
    $response = Invoke-WebRequest -Uri $publicFilesListUrl -Method Post -ContentType "application/json" -Headers @{"X-Authorization" = "$AccessToken"} -Body $jsonRequestBody    

    if ($response.StatusCode -eq 200) {
        # parse the JSON response
        $jsonResponse = $response.Content | ConvertFrom-Json

        # check if the list field exists and is not null
        if ($null -ne $jsonResponse.list) {
            # check if the size of the list is the same as the size of the botIdsArray
            if ($jsonResponse.list.Count -eq $botIdsArray.Length) {
                # iterate over each bot in the response
                foreach ($bot in $jsonResponse.list) {
                    # add the bot's ID, name, and path to the result
                    $result.Bots += [ordered]@{
                        Id = $bot.id
                        Name = $bot.name
                        Path = $bot.path
                    }
                }

                # set Success to true
                $result.Success = $true
            } else {
                Write-Host "The size of the bot list in the response is not the same as the size of the botIdsArray"
            }
        } else {
            Write-Host "The list field in the response is null"
        }
    } else {
        Write-Host "HTTP request failed with status code: $($response.StatusCode)"
    }
}
catch {
    Write-Host "Error occurred during Invoke-WebRequest: $_"
}

return $result

