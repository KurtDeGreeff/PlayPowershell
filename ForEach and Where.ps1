﻿#-------------------
# The foreach method
#------------------

#________
# ForEach(scriptblock expression) and ForEach(scriptblock expression, object[] arguments)
#________

# Get all the files from 'C:\Program Files\Internet Explorer'
$Files = Get-ChildItem 'C:\Program Files\Internet Explorer' -Recurse -file

# ForEach(scriptblock expression example
# Display the names and description of all files in the collection
$Files.foreach{"$($_.Name) ($($_.VersionInfo.FileDescription))"}

# Same results as the following previous methods 
$Files | Foreach-object {"$($_.Name) ($($_.VersionInfo.FileDescription))"}
foreach ($File in $Files) {"$($File.Name) ($($FIle.DisplayName))"}

#ForEach(scriptblock expression, object[] arguments) example
# Here we create a script block with parameters that selects a property name to expand 
$Files.foreach({param([string]$PropertyName);$_.$PropertyName}, 'Name')
# This might be a little easier to understand when broken out
$Files.foreach(
        #Script block will run as on $services with the foreach method
        {
            param([string]$PropertyName);
            $_.$PropertyName
        }, 
        # That takes the following as the value for the $PropertyName Parameter
        'Name')


# Just like foreach and foreach-object, the variables assigments you make are in the current scope
# meaning they will persist after the foreach method has finished executing
# So lets do a quick speed test, in this case we can see that Foreach statment is the fastest
Measure-Command -Expression {$Files.foreach{"$($_.Name) ($($_.LastWriteTime))"}} | Select @{N='Method';E={"Foreach method"}}, Milliseconds
Measure-Command -Expression {$Files | Foreach-object {"$($_.Name) ($($_.LastWriteTime))"}} | Select @{N='Method';E={"Foreach-object"}}, Milliseconds
Measure-Command -Expression {foreach ($File in $Files) {"$($File.Name) ($($File.LastWriteTime))"}} | Select @{N='Method';E={"Foreach statement"}},Milliseconds



#________
# ForEach(type convertToType)
#________

# Get a collection of processes
$processes = Get-Process
# Convert the objects in that collection into their string equivalent
$processes.foreach([string])
# Same results as the following previous methods 
$processes | ForEach-Object {[string]$_}
foreach ($process in $processes) {[string]$process}
# you could also just type cast the whole thing
[String[]]$processes
# So lets do a quick speed test, in this case we can see that Foreach method is faster then the previous methods
# But type casting is much faster
$Files = Get-ChildItem 'C:\Program Files' -Recurse -file
Measure-Command -Expression {$Files.foreach([string])} | Select @{N='Method';E={"Foreach method"}}, Milliseconds
Measure-Command -Expression {$Files | ForEach-Object {[string]$_}} | Select @{N='Method';E={"Foreach-object"}}, Milliseconds
Measure-Command -Expression {foreach ($files in $Files) {[string]$Files}} | Select @{N='Method';E={"Foreach statement"}},Milliseconds
Measure-Command -Expression {[String[]]$Files} | Select @{N='Method';E={"Casting"}},Milliseconds


#________
# ForEach(string propertyName)
#________

# Slighty redundat to the automatic foreach introduced, but is easier to read
# Get all services whose name starts with "w"
$services = Get-Service w*
# Return the names of those services
$services.foreach('Name')
# PSv3 automatic foreach
$Services.Name
# How to accomplish the same thing in PSv2 and prior
$services | ForEach-Object {$_.Name}
foreach ($Service in $services) {$service.name}
# So lets do a quick speed test,  in this case we can see that Foreach statment is the fastest
# But the automatic foreach is much faster
$Files = Get-ChildItem 'C:\Program Files' -Recurse -file
Measure-Command -Expression {$Files.foreach('Name')} | Select @{N='Method';E={"Foreach method"}}, Milliseconds
Measure-Command -Expression {$Files | ForEach-Object ($_.Name)} | Select @{N='Method';E={"Foreach-object"}}, Milliseconds
Measure-Command -Expression {foreach ($file in $Files) {$file.name}} | Select @{N='Method';E={"Foreach statement"}}, Milliseconds
Measure-Command -Expression {$Files.Name} | Select @{N='Method';E={"Automatic Foreach"}},Milliseconds

#________
# ForEach(string propertyName, object[] newValue)
#________
 
#Allows you to change a property of all the objects in a collection 
$Files = Get-ChildItem 'C:\Program Files' -Recurse
$RemoteFileTable = @()
$Files |  
    Foreach-object {
        $RemoteFileTable += New-Object psobject -Property  @{'Name' =$_.Name;'DirectoryName' = $_.DirectoryName}
    }

$RemoteFileTable.ForEach('DirectoryName','LocalHost')
$RemoteFileTable
#I tried to do some scripting on the changing of the property, but it appears to not work
$RemoteFileTable.ForEach('DirectoryName',{$_.DirectoryName -replace "C:","Z:"})
$RemoteFileTable.ForEach('DirectoryName',{$This.DirectoryName -replace "C:","Z:"})
$RemoteFileTable.ForEach('DirectoryName',({param([string]$PropertyName);$_.$PropertyName -replace "C:","Z:"}, 'DirectoryName'))
$RemoteFileTable.ForEach('DirectoryName',$this.DirectoryName -replace 'C:','Z:')

#________
# ForEach(string methodName) and ForEach(string methodName, object[] arguments)
#________

# create a bunch of instances of notepad
1..10 | ForEach-Object {notepad}

# Get all processes assocaited with notepad.exe
$processes = Get-Process -Name notepad
# Now kill all of those processes
$processes.foreach('Kill')
# How to accomplish the same thing in the previous versions
1..10 | ForEach-Object {notepad} 
$processes = Get-Process -Name notepad
$processes | foreach-object {$_.Kill()}
1..10 | ForEach-Object {notepad} 
$processes = Get-Process -Name notepad
foreach ($process in $processes) {$process.Kill()}
# So lets do a quick speed test,  in this case we can see that Foreach statment is the fastest
1..20 | ForEach-Object {notepad}
$processes = Get-Process -Name notepad
Measure-Command -Expression {$processes.foreach('Kill')} | Select @{N='Method';E={"Foreach method"}}, ticks
1..20 | ForEach-Object {notepad} 
$processes = Get-Process -Name notepad
Measure-Command -Expression {$processes | foreach-object {$_.Kill()}} | Select @{N='Method';E={"Foreach-object"}}, ticks
1..20 | ForEach-Object {notepad} 
$processes = Get-Process -Name notepad
Measure-Command -Expression {foreach ($process in $processes) {$process.Kill()}} | Select @{N='Method';E={"Foreach statement"}}, ticks

#ForEach(string methodName, object[] arguments) example
# this shows how to arguments to methods 
# Get all commands that have a ComputerName parameter
$cmds = Get-Command -ParameterName ComputerName
$cmds
$cmds[0].ResolveParameter('ComputerName')
# Now show a table making sure the parameter names and aliases are consistent
$cmds.foreach('ResolveParameter','ComputerName') | Format-Table Name,Aliases

#-------------------
# The Where method
#------------------

#________
# Where(scriptblock expression) and Where(scriptblock expression),'Default',[int numberToReturn]])  )
#________

$services = Get-Service

# Now filter out any services that are not running
$services.where({$_.Status -eq 'Running'})
# When not setting the mode it's the same as saying the following
$services.where({$_.Status -eq 'Running'},'Default')
#You can also select the number of filtered items to return
$services.where({$_.Status -eq 'Running'},'Default', 5)

# The same can be accomplished using Where-Object and select-object 
#PSv3+
$services | where-object Status -eq 'Running'
#PSv2 and older
$services | where-object {$_.Status -eq 'Running'}

# So lets do a quick speed test,  in this case we can see that where method is the fastest
Measure-Command -Expression {$services = Get-Service} | Select @{N='Method';E={"Where method"}}, Milliseconds
Measure-Command -Expression {$services | where-object Status -eq 'Running'} | Select @{N='Method';E={"Where-object"}}, Milliseconds

#________
# Where(scriptblock expression),'First',[int numberToReturn]])  )
#________

$services = Get-Service

# Now filter out any services that are not running and only return the first one
$services.where({$_.Status -eq 'Running'},'First')
# Now filter out any services that are not running and only return the first 5 items
$services.where({$_.Status -eq 'Running'},'first',5)
#Note that using 0 or 1 in the numertoReturn always returns just one item
$services.where({$_.Status -eq 'Running'},'first',0)
$services.where({$_.Status -eq 'Running'},'first',1)

# The same can be accomplished using Where-Object and select-object 
#PSv3+
$services | where-object Status -eq 'Running' | Select-Object -First 5
#PSv2 and older
$services | where-object {$_.Status -eq 'Running'}  | Select-Object -First 5

# So lets do a quick speed test,
# in this case we can see that where method is the fastest especially since it doesn't need to travel through multiple pipelines
Measure-Command -Expression {$services.where({$_.Status -eq 'Running'},'Default',5)} | Select @{N='Method';E={"Where method"}}, ticks
Measure-Command -Expression {$services | where-object {$_.Status -eq 'Running'}  | Select-Object -First 5} | Select @{N='Method';E={"Where-object"}}, ticks

#________
# Where(scriptblock expression),'Last',[int numberToReturn]])  )
#________

$services = Get-Service

# Now filter out any services that are not running and only return the Last one
$services.where({$_.Status -eq 'Running'},'Last')
# Now filter out any services that are not running and only return the Last 5 items
$services.where({$_.Status -eq 'Running'},'Last',5)
#Note that using 0 or 1 in the numertoReturn always returns just one item
$services.where({$_.Status -eq 'Running'},'last',0)
$services.where({$_.Status -eq 'Running'},'last',1)

# The same can be accomplished using Where-Object and select-object 
#PSv3+
$services | where-object Status -eq 'Running' | Select-Object -Last 5
#PSv2 and older
$services | where-object {$_.Status -eq 'Running'}  | Select-Object -Last 5

# So lets do a quick speed test,
# in this case we can see that where method is the fastest especially since it doesn't need to travel through multiple pipelines
Measure-Command -Expression {$services.where({$_.Status -eq 'Running'},'Last',5)} | Select @{N='Method';E={"Where method"}}, Milliseconds
Measure-Command -Expression {$services | where-object Status -eq 'Running' | Select-Object -Last 5} | Select @{N='Method';E={"Where-object"}}, Milliseconds

#________
# Where(scriptblock expression),'SkipUntil',[int numberToReturn]])  )
#________

#Once you find an object that passes the filter, SkipUntil mode will either return all objects remaining in the collection
#if no value or a value of 0 was provided to the numberToReturn argument. 
#In all cases the collection will include the 1st object that passed the filter 


# Get a collection of services whose name starts with "c"
$services = Get-Service c*
# Skip all services until we find one with a status of "Running", then return that entry and everything everything after that
$services.where({$_.Status -eq 'Running'},'SkipUntil')
# Skip all services until we find one with a status of "Running", then return that entry and the next one for a total of 2
$services.where({$_.Status -eq 'Running'},'SkipUntil',2)

#Personally, I couldn't find an elegant way to do this without creating a function or script.
#Example
$services = Get-Service c*
$Skipuntil = 0
$Status = 'Running'
$Count = 0
Foreach ($Service in $Services) {
    If ($Skipuntil -le 1) {
        If ($Service.Status -ne $Status) {
            $Service
            Break
        }
    }
    Else{ 
        if ($Count -lt $Skipuntil -and $_.Status -ne $Status) {
                $Service
                $Count++
            }
        Elseif ($Count -gt $Skipuntil) {break}
    }
}
#Speed wise we are going to assume the method is faster!

#________
# Where(scriptblock expression),'Until',[int numberToReturn]])  )
#________

#The opposite of SkipUntil
#Returns all the objects in the collection until you hit one that matches the filter
#At tha point the method stops processing objects
#if no value or a value of 0 is provided that it will return all objects before hitting one that matches the filter
#If provided a number then it will only return that many objects even if it doesn't find 
#An object that matches the filter

# Get a collection of services whose name starts with "p"
$services = Get-Service p*
$services
# Return all services until we find one with a status of "Stopped"
$services.where({$_.Status -eq 'Stopped'},'Until')
# Return the first 2 services unless we find one with a status of
# "Stopped" first
$services.where({$_.Status -eq 'Stopped'},'Until',2)

#Once again I couldn't think of an elegant way to pull the same thing as this method without creating a function

#________
# Where(scriptblock expression),'Split',[int numberToReturn]])  )
#________

#Split allows you to split a collection of objects into two.  
#By default, if you don’t provide a value for the numberToReturn argument or if you provide a value of 0 for the numberToReturn argument, 
#Split will place all objects that pass the script block expression filter into the first nested collection, 
#and all other objects (those that don’t pass the script block expression filter) into the second nested collection
#Example
# Get all services
$services = Get-Service
# Split the services into two groups: Running and not Running
$running,$notRunning = $services.Where({$_.Status -eq 'Running'},'Split')
# Show the Running services
$running
# Show the services that are not Running
$notRunning

#If you do provide a value fo the numberToReturn argument split will limit the size of the first collection to that maximum amount, 
# and all remaining objects in the collection, 
# even those that match the script block expression filter, will be placed into the second collection.

# Split the services into the same two groups, but limit the Running group
# to a maximum of 10 items
$10running,$others = $services.Where({$_.Status -eq 'Running'},'Split',10)
# Show the first 10 Running services
$10running
# Show all other services
$others


#Bouns
#You can actually chain these methods together
1..10 | ForEach-Object {notepad} 
@(Get-Process).Where({ $PSItem.Name -eq 'notepad'; }).ForEach({ $_.Kill(); });
#Also note that if you pull only one object, it won't be a collection and therefore won't have the new methods in PSv4
#THis was fixed in PSv5
$services = Get-Service -Name BITS
$services.where({$_.Status -eq 'Running'})
#A few ways around this is to cast the results as an array
$services = @(Get-Service -Name BITS)
#Or
$services = [Array](Get-Service -Name BITS)
#And then you will get the methods
$services.where({$_.Status -eq 'Running'})

#Note you may run into issues with the orignal objects in some cases
# Here is an example from Simon Wahlin’s blog : http://blog.simonw.se/where-method-in-powershell-4-breaks-my-objects/
$list = New-Object -TypeName System.Collections.ArrayList
1,2 | ForEach-Object {
    $object = [PSCustomObject]@{
        ID = "$_"
        Array = @("first","second")
    }
    [void]$list.Add($object)  
}
#Standard way
$entry1 = $list | Where-Object {$_.ID -eq 1}
$entry1.Array += "third"
$list


#Method  way
$entry2 = $list.Where({$_.ID -eq 2})
$entry2.Array += "third"
$list

#What's the deal? They both are the same TypeName : System.Management.Automation.PSCustomObject
$entry1 | Get-Member
$entry2 | Get-Member 

#But the one created by the where method Is using a different Module, Asembly, and Name among other properties 
$entry1.GetType() | Select Module,Assembly,Name
$entry2.GetType() | Select Module,Assembly,Name

#You can get around this by individually accessing the item via it's index
$entry2[0].Array += "fourth"
$entry2.Item(0).Array += "fifth"
$list

#Currently this appears to be a bug/by design in the way the where methods handles nexted arrays
#Recall that you will get an error trying to access the where methods on any collection of just one object
#This problem only seems to happen with arrays, for example you don't have the same problem with hashtables
$List = @()
1,2 | ForEach-Object {
    $object = [PSCustomObject]@{
        ID = "$_"
        Array = @{"first"=1;"second"=2}
    }
    $list += $object  
}

#Standard way
$entry1 = $list | Where-Object {$_.ID -eq 1}
$entry1.array.Add("Three","3")
$list


#Method  way
$entry2 = $list.Where({$_.ID -eq 2})
$entry2.array.Add("Three","3")
$list