##############################################################################
#  Script: HelloWorld-Explained.ps1
#    Date: 27.Mar.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Explains how the traditional "Hello World!" script in PowerShell
#          actually works under the hood.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# A quoted string by itself will automatically be displayed:

"Hello World!"



# But that's because a string is really an object in the .NET Class Library
# of type System.String.  This object has methods and properties from
# .NET that we can directly access in PowerShell:

"Hello World!".GetType().FullName



# You can cast it as a string object with no change in output:

[System.String] "Hello World!"



# But why is it printed on-screen at all?  When an object is not piped anywhere 
# else, PowerShell pipes it into the Out-Default cmdlet by default:

"Hello World!" | Out-Default



# Out-Default examines the objects fed into it to determine what to do with them.
# If the objects are just strings, the strings go straight to Out-Host.  If the 
# objects have been tagged with a preferred formatter, then that formatter is
# used.  If no formatter is specified and the first object has five or more
# properties, then Format-List is used; four or less, then Format-Table.  The
# output of a formatter are strings, which go straight to Out-Host.  Because
# our "Hello World!" is a single string, the formatter is skipped and the
# output goes straight to Out-Host, the default outputter.  Formatters are
# the Format-* cmdlets that format object data as strings, while Outputters are
# the Out-* cmdlets that actually display/print/redirect that data somewhere.


"Hello World!" | Out-Default | Out-Host



# The following lines all result in the exact same output:

"Hello World!"
[System.String] "Hello World!"
"Hello World!" | out-default
"Hello World!" | format-list
"Hello World!" | out-host
"Hello World!" | format-list | out-host
"Hello World!" | out-default | format-list | out-host
[System.String] "Hello World!" | out-default | out-host




# But there are other formatters available which can be called:

"Hello World!" | Format-List 
"Hello World!" | Format-Wide 
"Hello World!" | Format-Custom 



# And there are other outputters too:

"Hello World!" | Format-List | Out-Null                     # Deletes data.
"Hello World!" | Format-List | Out-String                   # Renders as text strings, not objects.
# "Hello World!" | Format-List | Out-File C:\file.txt       # Saves to file.
# "Hello World!" | Format-List | Out-Printer                # Goes to default printer.


