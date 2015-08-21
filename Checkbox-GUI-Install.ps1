# This is just a shortcut to setting these properties over and over
Set-UIStyle "L1" @{ FontFamily = "Helvetica"; FontSize = 10; TextWrapping = "WrapWithOverflow" }
Set-UIStyle "C1" @{ FontFamily = "Helvetica"; FontSize = 12 }

# Now show the UI and collect the results:
$Options = New-StackPanel -Margin 5 {

    New-TextBlock "Office 365 Migration Tool" -FontFamily Helvetica -FontSize 20
    New-TextBlock "I would like to migrate the following from Exchange 2010 to Office 365:" -VisualStyle C1 -TextWrapping "WrapWithOverflow"

    New-UniformGrid -Columns 2 -Margin "5,10" {

        New-CheckBox "Mailbox Properties`n" -Name "MailboxProperties" -VisualStyle C1
        New-TextBlock "This is a really long description of the Mailbox Properties that will be migrated if you check that box..."  -VisualStyle L1
        
        New-CheckBox "Mailbox Permissions" -Name "MailboxPermissions" -VisualStyle C1
        New-TextBlock "This is a Description of the Mailbox Permissions"  -VisualStyle L1
        
        New-CheckBox "Contacts" -Name "Contacts" -VisualStyle C1
        New-TextBlock "This is a Description of the Contacts" -VisualStyle L1

        New-CheckBox "Contact Permissions" -Name "ContactPermissions" -VisualStyle C1
        New-TextBlock "This is a Description of the Contact Permissions"  -VisualStyle L1
        
        New-CheckBox "Distribution Groups" -Name "DistributionGroups" -VisualStyle C1
        New-TextBlock "This is a Description of the Distribution Groups"  -VisualStyle L1
        
        New-CheckBox "Calendar Permissions" -Name "CalendarPermissions" -VisualStyle C1
        New-TextBlock "This is a Description of the Calendar Permissions" -VisualStyle L1
    }

    New-TextBlock "This program must be run from a server with administrative access to Microsoft Exchange. When you are ready to proceed, click OK." -VisualStyle L1
        
    New-Button "OK" -FontSize 15 -Margin 5 -Width 120 -On_Click {    
        Get-ParentControl | Set-UIValue -passThru | Close-Control
        if($Options.MailboxProperties) { 
           # Code here for Mailbox Properties
        }
        if($Options.MailboxPermissions) {
           # Code here for Mailbox Permissions
        }
    }

} -Width 500 -Show
