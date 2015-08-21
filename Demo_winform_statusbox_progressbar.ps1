#requires -version 3.0

#demo winform status box with a progress bar control

#path to report on
$path = "C:\windows"


#this line may not be necessary
#[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
Add-Type -assembly System.Windows.Forms

#title for the winform
$Title = "Directory Usage Analysis: $Path"
#winform dimensions
$height=100
$width=400
#winform background color
$color = "White"

#create the form
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = $title
$form1.Height = $height
$form1.Width = $width
$form1.BackColor = $color

$form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle 
#display center screen
$form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# create label
$label1 = New-Object system.Windows.Forms.Label
$label1.Text = "not started"
$label1.Left=5
$label1.Top= 10
$label1.Width= $width - 20
#adjusted height to accommodate progress bar
$label1.Height=15
$label1.Font= "Verdana"
#optional to show border 
#$label1.BorderStyle=1

#add the label to the form
$form1.controls.add($label1)

$progressBar1 = New-Object System.Windows.Forms.ProgressBar
$progressBar1.Name = 'progressBar1'
$progressBar1.Value = 0
$progressBar1.Style="Continuous"

#Setting the style to "Continuous" will give us a nice looking and smooth progress bar. Next, I need to create a drawing object and use that to give the progress bar its size.

$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = $width - 40
$System_Drawing_Size.Height = 20
$progressBar1.Size = $System_Drawing_Size

#Using the values for the label and some trial and error, I specify where the progress bar should start on the form.

$progressBar1.Left = 5
$progressBar1.Top = 40
#Finally, like the other controls, the progress bar needs to be added to the form.
$form1.Controls.Add($progressBar1)
#Now I can show the form and start the main part of my PowerShell script.
$form1.Show()| out-null

#give the form focus
$form1.Focus() | out-null

#update the form
$label1.text="Preparing to analyze $path"
$form1.Refresh()

start-sleep -Seconds 1

#run code and update the status form

#get top level folders
$top = Get-ChildItem -Path $path -Directory

#initialize a counter
$i=0

#As I've been doing all along, I'll use ForEach to process each item, calculate my percentage complete and use that value for the progress bar.

foreach ($folder in $top) {

#calculate percentage
$i++
[int]$pct = ($i/$top.count)*100
#update the progress bar
$progressbar1.Value = $pct

$label1.text="Measuring size: $($folder.Name)"
$form1.Refresh()

start-sleep -Milliseconds 100
$stats = Get-ChildItem -path $folder -Recurse -File | 
Measure-Object -Property Length -Sum -Average
[pscustomobject]@{
Path=$folder.Name
Files = $stats.count
SizeKB = [math]::Round($stats.sum/1KB,2)
Avg = [math]::Round($stats.average,2)
} 
} #foreach

#At the end of the script I clean up after myself and close the form.

$form1.Close()