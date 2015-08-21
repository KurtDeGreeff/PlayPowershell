$global:APIkey = "2131a26f84069c7a06521e41d73affd3"

Function Get-WorldCupPlayer ($Country) {
    If ($Country) {
        $TeamID = (Get-WorldCupTeam -Country $Country).id
        Invoke-WebRequest -Uri ("http://worldcup.kimonolabs.com/api/players?teamId=$($TeamID)&apikey=$($ApiKey)") | ConvertFrom-Json
    } Else {
        Invoke-WebRequest -Uri "http://worldcup.kimonolabs.com/api/players?apikey=$($ApiKey)" | ConvertFrom-Json
    }
}

Function Get-WorldCupTeam ($Country, $TeamID) {
    If ($Country) {
        Invoke-WebRequest -Uri ("http://worldcup.kimonolabs.com/api/teams?name=$($Country)&apikey=$($ApiKey)") | ConvertFrom-Json
    }
    If ($TeamID) {
        Invoke-WebRequest -Uri ("http://worldcup.kimonolabs.com/api/teams?id=$($TeamID)&apikey=$($ApiKey)") | ConvertFrom-Json
    }

    If (!$country -and !$TeamID) {
        Invoke-WebRequest -Uri "http://worldcup.kimonolabs.com/api/teams?apikey=$($ApiKey)" | ConvertFrom-Json
    }
}

Function Get-WorldCupStat {
    Invoke-WebRequest -Uri ("http://worldcup.kimonolabs.com/api/teams?sort=goalsFor,-1&apikey=$($ApiKey)") | ConvertFrom-Json
}