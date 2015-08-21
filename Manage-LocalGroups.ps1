# Managing Local Groups
# Source: https://goo.gl/cAcRtN

#Creating a Local Group
$Group = $ADSI.Create('Group', 'TestGroup')
$Group.SetInfo() 
$Group.Description  = 'This is a  test group for whatever'
$Group.SetInfo() 

#Removing a Local Group
$Computer = $env:COMPUTERNAME
$GroupName = 'TestGroup'
$ADSI = [ADSI]("WinNT://$Computer")
$Group = $ADSI.Children.Find($GroupName, 'group')
$ADSI.Children.Remove($Group)

#Adding a User to a Group
$Computer = $env:COMPUTERNAME
$GroupName = 'TestGroup'
$ADSI = [ADSI]("WinNT://$Computer")
$Group = $ADSI.Children.Find($GroupName, 'group') 

$User = $env:USERNAME
$Group.Add(("WinNT://$computer/$user"))

#verify membership
$Group.psbase.invoke('members')  | ForEach {
$_.GetType().InvokeMember("Name","GetProperty",$Null,$_,$Null)
}

#remove a user from a local group
$Computer = $env:COMPUTERNAME
$GroupName = 'TestGroup'
$ADSI = [ADSI]("WinNT://$Computer")
$Group = $ADSI.Children.Find($GroupName, 'group')
$User = $env:USERNAME
$Group.Remove(("WinNT://$computer/$user"))



