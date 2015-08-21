[xml]$xml=@'
<QueryList>
<Query Id="0" Path="System">
<Select Path="System">*[System[(EventID=6005)]]</Select>
</Query>
</QueryList>
'@
# 6005=startup, 6006=shutdown
Get-WinEvent -FilterXml $xml -MaxEvents 5