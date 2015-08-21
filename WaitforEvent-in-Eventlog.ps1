$seclog = Get-EventLog -List | Where-Object {$_.Log -eq 'Security'}
Register-ObjectEvent -InputObject $seclog -SourceIdentifier NewEventLogEntry -EventName EntryWritten -Action {

    $entry = $event.SourceEventArgs.Entry

    if($entry.EventID -eq 4776)
    {
        if($entry.EntryType -eq 'SuccessAudit')
        {
            'code for SuccessAudit'
        }
        elseif($entry.EntryType -eq 'FailureAudit')
        {
            'code for FailureAudit'
        }
    }
}
#Unregister-Event -SourceIdentifier NewEventLogEntry