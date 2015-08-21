## UI Automation v 1.10 -- REQUIRES the Reflection module
## 
# WASP 2.0 is getting closer, but this is still just a preview:
# -- a lot of the commands have weird names still because they're being generated ignorantly
# -- eg: Invoke-Toggle.Toggle and  Invoke-Invoke.Invoke

# v 1.7  - Fixes using multiple checks like: Select-UIElement Red: Edit
# v 1.8  - Fixes .Net version problems: specifying CSharpVersion3 when in PowerShell 2
# v 1.9  - Fix bug with Select-UIElement by processName / processId
# v 1.10 - Add the super-flexible but super-user-only -PropertyValue parameter to Select-UIElement

# IF your PowerShell is running in .Net 4
if($PSVersionTable.CLRVersion -gt "4.0") {
    $Language = "CSharp" # Version 4
    Add-Type -AssemblyName "UIAutomationClient, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Add-Type -AssemblyName "UIAutomationTypes, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
} else {
    # In PowerShell 2, we need to use the .Net 3 version
    $Language = "CSharpVersion3" 
    Add-Type -AssemblyName "UIAutomationClient, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Add-Type -AssemblyName "UIAutomationTypes, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
}


$SWA = "System.Windows.Automation"
#  Add-Accelerator InvokePattern      "$SWA.InvokePattern"                -EA SilentlyContinue
#  Add-Accelerator ExpandPattern      "$SWA.ExpandCollapsePattern"        -EA SilentlyContinue
#  Add-Accelerator WindowPattern      "$SWA.WindowPattern"                -EA SilentlyContinue
#  Add-Accelerator TransformPattern   "$SWA.TransformPattern"             -EA SilentlyContinue
#  Add-Accelerator ValuePattern       "$SWA.ValuePattern"                 -EA SilentlyContinue
#  Add-Accelerator TextPattern        "$SWA.TextPattern"                  -EA SilentlyContinue

# This is what requires the Reflection module:
Add-Accelerator Automation         "$SWA.Automation"                   -EA SilentlyContinue
Add-Accelerator AutomationElement  "$SWA.AutomationElement"            -EA SilentlyContinue
Add-Accelerator TextRange          "$SWA.Text.TextPatternRange"        -EA SilentlyContinue
#####  Conditions
Add-Accelerator Condition          "$SWA.Condition"                    -EA SilentlyContinue
Add-Accelerator AndCondition       "$SWA.AndCondition"                 -EA SilentlyContinue
Add-Accelerator OrCondition        "$SWA.OrCondition"                  -EA SilentlyContinue
Add-Accelerator NotCondition       "$SWA.NotCondition"                 -EA SilentlyContinue
Add-Accelerator PropertyCondition  "$SWA.PropertyCondition"            -EA SilentlyContinue
#####  IDentifiers
Add-Accelerator AutoElementIds     "$SWA.AutomationElementIdentifiers" -EA SilentlyContinue
Add-Accelerator TransformIds       "$SWA.TransformPatternIdentifiers"  -EA SilentlyContinue

##### Patterns:
$patterns = Get-Type -Assembly UIAutomationClient -Base System.Windows.Automation.BasePattern 
            #| Where { $_ -ne [System.Windows.Automation.InvokePattern] }


Add-Type -Language $Language -ReferencedAssemblies UIAutomationClient, UIAutomationTypes -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Management.Automation;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Windows.Automation;
using System.Runtime.InteropServices;


[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
public class StaticFieldAttribute : ArgumentTransformationAttribute {
   private Type _class;

   public override string ToString() {
      return string.Format("[StaticField(OfClass='{0}')]", OfClass.FullName);
   }

   public override Object Transform( EngineIntrinsics engineIntrinsics, Object inputData) {
      if(inputData is string && !string.IsNullOrEmpty(inputData as string)) {
         System.Reflection.FieldInfo field = _class.GetField(inputData as string, BindingFlags.Static | BindingFlags.Public);
         if(field != null) {
            return field.GetValue(null);
         }
      }
      return inputData;
   }
   
   public StaticFieldAttribute( Type ofClass ) {
      OfClass = ofClass;
   }

   public Type OfClass {
      get { return _class; }
      set { _class = value; }
   }   
}

public static class UIAutomationHelper {

   [DllImport ("user32.dll", CharSet = CharSet.Auto)]
   static extern IntPtr FindWindow (string lpClassName, string lpWindowName);

   [DllImport ("user32.dll", CharSet = CharSet.Auto)]
   static extern bool AttachThreadInput (int idAttach, int idAttachTo, bool fAttach);

   [DllImport ("user32.dll", CharSet = CharSet.Auto)]
   static extern int GetWindowThreadProcessId (IntPtr hWnd, IntPtr lpdwProcessId);

   [DllImport ("user32.dll", CharSet = CharSet.Auto)]
   static extern IntPtr SetForegroundWindow (IntPtr hWnd);

   public static AutomationElement RootElement {
      get { return AutomationElement.RootElement; }
   }


   ///<synopsis>Using Win32 to set foreground window because AutomationElement.SetFocus() is unreliable</synopsis>
   public static bool SetForeground(this AutomationElement element)
   {
      if(element == null) { 
         throw new ArgumentNullException("element");
      }

      // Get handle to the element
      IntPtr other = FindWindow (null, element.Current.Name);

      // // Get the Process ID for the element we are trying to
      // // set as the foreground element
      // int other_id = GetWindowThreadProcessId (other, IntPtr.Zero);
      // 
      // // Get the Process ID for the current process
      // int this_id = GetWindowThreadProcessId (Process.GetCurrentProcess().Handle, IntPtr.Zero);
      // 
      // // Attach the current process's input to that of the 
      // // given element. We have to do this otherwise the
      // // WM_SETFOCUS message will be ignored by the element.
      // bool success = AttachThreadInput(this_id, other_id, true);

      // Make the Win32 call
      IntPtr previous = SetForegroundWindow(other);

      return !IntPtr.Zero.Equals(previous);
   }
}
"@
            
## TODO: Write Get-SupportedPatterns or rather ... 
## Get-SupportedFunctions (to return the names of the functions for the supported patterns)
## TODO: Support all the "Properties" too
## TODO: Figure out why Notepad doesn't support SetValue
## TODO: Figure out where the menus support went
ForEach($pattern in $patterns){
   $pattern | Add-Accelerator
   $PatternFullName = $pattern.FullName
   $PatternName = $Pattern.Name -Replace "Pattern","."
   $newline = "`n`t`t"
   
   New-Item "Function:ConvertTo-$($Pattern.Name)" -Value "
   param(
      [Parameter(ValueFromPipeline=`$true)][Alias('Element','AutomationElement')][AutomationElement]`$InputObject
   )
   process { 
      trap { 
         if(`$_.Exception.Message -like '*Unsupported Pattern.*') {
            Write-Error `"Cannot get ```"$($Pattern.Name)```" from that AutomationElement, `$(`$_)` You should try one of: `$(`$InputObject.GetSupportedPatterns()|%{```"'```" + (`$_.ProgrammaticName.Replace(```"PatternIdentifiers.Pattern```",```"```")) + ```"Pattern'```"})`"; continue;
         }
      }
      Write-Output `$InputObject.GetCurrentPattern([$PatternFullName]::Pattern).Current
   }"
   
   $pattern.GetMethods() | 
   Where { $_.DeclaringType -eq $_.ReflectedType -and !$_.IsSpecialName } | 
   ForEach {
      $FunctionName = "Function:Invoke-$PatternName$($_.Name)"
      $Position = 1
      
      if (test-path $FunctionName) { remove-item $FunctionName }
      $Parameters = @("$newline[Parameter(ValueFromPipeline=`$true)]"+
                      "$newline[Alias('Parent','Element','Root','AutomationElement')]"+
                      "$newline[AutomationElement]`$InputObject"
                      ) + 
                    @(
                      "[Parameter()]$newline[Switch]`$Passthru"
                     ) + 
                    @($_.GetParameters() | % { "[Parameter(Position=$($Position; $Position++))]$newline[$($_.ParameterType.FullName)]`$$($_.Name)" })
      $Parameters = $Parameters -Join "$newline,$newline"
      $ParameterValues = '$' + (@($_.GetParameters() | Select-Object -Expand Name ) -Join ', $')

      $definition = @"
   param(
      $Parameters
   )
   process { 
      ## trap { Write-Warning "`$(`$_)"; break }
      `$pattern = `$InputObject.GetCurrentPattern([$PatternFullName]::Pattern)
      if(`$pattern) {
         `$Pattern.$($_.Name)($(if($ParameterValues.Length -gt 1){ $ParameterValues }))
      }
      if(`$passthru) {
         `$InputObject
      }
   }
"@
      
      trap {
         Write-Warning $_
         Write-Host $definition -fore cyan
      }
      New-Item $FunctionName -value $definition
   }
   
   $pattern.GetProperties() | 
   Where { $_.DeclaringType -eq $_.ReflectedType -and $_.Name -notmatch "Cached|Current"} |
   ForEach {
      $FunctionName = "Function:Get-$PatternName$($_.Name)".Trim('.')
      if (test-path $FunctionName) { remove-item $FunctionName }
      New-Item $FunctionName -value "
      param(
         [Parameter(ValueFromPipeline=`$true)]
         [AutomationElement]`$AutomationElement
      )      
      process { 
         trap { Write-Warning `"$PatternFullName `$_`"; continue }
         `$pattern = `$AutomationElement.GetCurrentPattern([$PatternFullName]::Pattern)
         if(`$pattern) {
            `$pattern.'$($_.Name)'
         }
      }"
   }
   ## So far this seems to be restricted to Text (DocumentRange) elements
   $pattern.GetFields() |
   Where { $_.FieldType.Name -like "*TextAttribute"} |
   ForEach {
      $FunctionName = "Function:Get-Text$($_.Name -replace 'Attribute')"
      if (test-path $FunctionName) { remove-item $FunctionName }
      New-Item $FunctionName -value "
      param(
         [Parameter(ValueFromPipeline=`$true)]
         [AutomationElement]`$AutomationElement
      )
      process { 
         trap { Write-Warning `"$PatternFullName `$_`"; continue }
         `$AutomationElement.GetAttributeValue([$PatternFullName]::$($_.Name))
      }"
   }
   
   $pattern.GetFields() | Where { $_.FieldType -eq [System.Windows.Automation.AutomationEvent] } |
   ForEach {
      $Name = $_.Name -replace 'Event$'
      $FunctionName = "Function:Register-$($PatternName.Trim('.'))$Name"
      if (test-path $FunctionName) { remove-item $FunctionName }
      New-Item $FunctionName -value "
      param(
         [Parameter(ValueFromPipeline=`$true)]
         [AutomationElement]`$AutomationElement
      ,
         [System.Windows.Automation.TreeScope]`$TreeScope = 'Element'
      ,
         [ScriptBlock]`$EventHandler
      )
      process { 
         trap { Write-Warning `"$PatternFullName `$_`"; continue }
         [Automation]::AddAutomationEventHandler( [$PatternFullName]::$Name, `$AutomationElement, `$TreeScope, `$EventHandler )
      }"
   }
}

$FalseCondition = [Condition]::FalseCondition
$TrueCondition  = [Condition]::TrueCondition

Add-Type -AssemblyName System.Windows.Forms
Add-Accelerator SendKeys           System.Windows.Forms.SendKeys       -EA SilentlyContinue

$AutomationProperties = [system.windows.automation.automationelement+automationelementinformation].GetProperties()

Set-Alias Invoke-UIElement Invoke-Invoke.Invoke

function formatter  { END {
   $input | Format-Table @{l="Text";e={$_.Text.SubString(0,25)}}, ClassName, FrameworkId -Auto
}}

function Get-ClickablePoint {
[CmdletBinding()]
param(
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
)
   process {
      $InputObject.GetClickablePoint()
   }
}

function Show-Window {
[CmdletBinding()]
param(
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
,
   [Parameter()]
   [Switch]$Passthru   
)
   process {
      Set-UIFocus $InputObject
      if($passthru) {
         $InputObject
      }        
   }
}

function Set-UIFocus {
[CmdletBinding()]
param(
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
,
   [Parameter()]
   [Switch]$Passthru   
)
   process {
      try {
         [UIAutomationHelper]::SetForeground( $InputObject )
         $InputObject.SetFocus()
      } catch {
         Write-Verbose "SetFocus fail, trying SetForeground"
      }
      if($passthru) {
         $InputObject
      }        
   }
}

function Send-UIKeys {
[CmdletBinding()]
param(
   [Parameter(Position=0)]
   [string]$Keys
,
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
,
   [Parameter()]
   [Switch]$Passthru
,
   [Parameter()]
   [Switch]$Async
)
   process {
      if(!$InputObject.Current.IsEnabled)
      {
         Write-Warning "The Control is not enabled!"
      }
      if(!$InputObject.Current.IsKeyboardFocusable)
      {
         Write-Warning "The Control is not focusable!"
      }
      Set-UIFocus $InputObject
      
      if($Async) {
         [SendKeys]::Send( $Keys )
      } else {
         [SendKeys]::SendWait( $Keys )
      }
      
      if($passthru) {
         $InputObject
      }      
   }
}

function Set-UIText {
[CmdletBinding()]
param(
   [Parameter(Position=0)]
   [string]$Text
,
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
,
   [Parameter()]
   [Switch]$Passthru   
)
   process {
      if(!$InputObject.Current.IsEnabled)
      {
         Write-Warning "The Control is not enabled!"
      }
      if(!$InputObject.Current.IsKeyboardFocusable)
      {
         Write-Warning "The Control is not focusable!"
      }
      
      $valuePattern = $null
      if($InputObject.TryGetCurrentPattern([ValuePattern]::Pattern,[ref]$valuePattern)) {
         Write-Verbose "Set via ValuePattern!"
         $valuePattern.SetValue( $Text )
      } 
      elseif($InputObject.Current.IsKeyboardFocusable) 
      {
         Set-UIFocus $InputObject
         [SendKeys]::SendWait("^{HOME}");
         [SendKeys]::SendWait("^+{END}");
         [SendKeys]::SendWait("{DEL}");
         [SendKeys]::SendWait( $Text )
      }
      if($passthru) {
         $InputObject
      }      
   }
}

function Select-UIElement {
[CmdletBinding(DefaultParameterSetName="FromParent")]
PARAM (
   [Parameter(ParameterSetName="FromWindowHandle", Position="0", Mandatory=$true)] 
   [Alias("MainWindowHandle","hWnd","Handle","Wh")]
   [IntPtr[]]$WindowHandle=[IntPtr]::Zero
,
   [Parameter(ParameterSetName="FromPoint", Position="0", Mandatory=$true)]
   [System.Windows.Point[]]$Point
,
   [Parameter(ParameterSetName="FromParent", ValueFromPipeline=$true, Position=100)]
   [System.Windows.Automation.AutomationElement]$Parent = [UIAutomationHelper]::RootElement
,
   [Parameter(ParameterSetName="FromParent", Position="0")]
   [Alias("WindowName")]
   [String[]]$Name
,
   [Parameter(ParameterSetName="FromParent", Position="1")]
   [Alias("Type","Ct")]
   [System.Windows.Automation.ControlType]
   [StaticField(([System.Windows.Automation.ControlType]))]$ControlType
,
   [Parameter(ParameterSetName="FromParent")]
   [Alias("UId")]
   [String[]]$AutomationId
,
   ## Removed "Id" alias to allow get-process | Select-Window pipeline to find just MainWindowHandle
   [Parameter(ParameterSetName="FromParent", ValueFromPipelineByPropertyName=$true )]
   [Alias("Id")]
   [Int[]]$PID
,
   [Parameter(ParameterSetName="FromParent")]
   [Alias("Pn")]
   [String[]]$ProcessName
,
   [Parameter(ParameterSetName="FromParent")]
   [Alias("Cn")]
   [String[]]$ClassName
,
   [switch]$Recurse
,
   [switch]$Bare,

   [Parameter(ParameterSetName="FromParent")]
   [Alias("Pv")]
   [Hashtable]$PropertyValue

)
process {

   Write-Debug "Parameters Found"
   Write-Debug ($PSBoundParameters | Format-Table | Out-String)

   $search = "Children"
   if($Recurse) { $search = "Descendants" }
   
   $condition = [System.Windows.Automation.Condition]::TrueCondition
   
   Write-Verbose $PSCmdlet.ParameterSetName
   switch -regex ($PSCmdlet.ParameterSetName) {
      "FromWindowHandle" {
         Write-Verbose "Finding from Window Handle $HWnd"
         $Element = $(
            foreach($hWnd in $WindowHandle) {
               [System.Windows.Automation.AutomationElement]::FromHandle( $hWnd )
            }
         )
         continue
      }
      "FromPoint" {
         Write-Verbose "Finding from Point $Point"
         $Element = $(
            foreach($pt in $Point) {
               [System.Windows.Automation.AutomationElement]::FromPoint( $pt )
            }
         )
         continue
      }
      "FromParent" {
         Write-Verbose "Finding from Parent!"
         ## [System.Windows.Automation.Condition[]]$conditions = [System.Windows.Automation.Condition]::TrueCondition
         [ScriptBlock[]]$filters = @()
         if($AutomationId) {
            [System.Windows.Automation.Condition[]]$current = $(
               foreach($aid in $AutomationId) {
                  new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::AutomationIdProperty), $aid
               }
            )
            if($current.Length -gt 1) {
               [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
            } elseif($current.Length -eq 1) {
               [System.Windows.Automation.Condition[]]$conditions += $current[0]
            }  
         }
         if($PID) {
            [System.Windows.Automation.Condition[]]$current = $(
               foreach($p in $PID) {
                  new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ProcessIdProperty), $p
               }
            )
            if($current.Length -gt 1) {
               [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
            } elseif($current.Length -eq 1) {
               [System.Windows.Automation.Condition[]]$conditions += $current[0]
            }         
         }
         if($ProcessName) {
            if($ProcessName -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($p in $ProcessName){ (Get-Process -id $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ProcessIdProperty)).ProcessName -like $p }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current = $(
                  foreach($p in Get-Process -Name $ProcessName) {
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ProcessIdProperty), $p.id
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }               
            }
         }
         if($Name) {
            Write-Verbose "Name: $Name"
            if($Name -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($n in $Name){ $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::NameProperty) -like $n }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current = $(
                  foreach($n in $Name){
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::NameProperty), $n, "IgnoreCase"
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }   
            }
         }
         if($ClassName) {
            if($ClassName -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($c in $ClassName){ $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ClassNameProperty) -like $c }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current = $(
                  foreach($c in $ClassName){
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ClassNameProperty), $c, "IgnoreCase"
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }                  
            }
         }
         if($ControlType) {
            if($ControlType -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($c in $ControlType){ $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ControlTypeProperty) -like $c }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current = $(
                  foreach($c in $ControlType){
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ControlTypeProperty), $c
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }                  
            }
         }
         if($PropertyValue) {
            $Property = $PropertyValue.Keys[0]
            $Value = $PropertyValue.Values[0]
            if($Value -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($c in $PropertyValue.GetEnumerator()){
                  $_.GetCurrentPropertyValue(  
                     [System.Windows.Automation.AutomationElement].GetField(
                        $c.Key).GetValue(([system.windows.automation.automationelement]))
                  ) -like $c.Value }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current = $(
                  foreach($c in $PropertyValue.GetEnumerator()){
                     new-object System.Windows.Automation.PropertyCondition (
                        [System.Windows.Automation.AutomationElement].GetField(
                        $c.Key).GetValue(([system.windows.automation.automationelement]))), $c.Value
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }                  
            }
         }         
         
         if($conditions.Length -gt 1) {
            [System.Windows.Automation.Condition]$condition = New-Object System.Windows.Automation.AndCondition $conditions
         } elseif($conditions) {
            [System.Windows.Automation.Condition]$condition = $conditions[0]
         } else {
            [System.Windows.Automation.Condition]$condition = [System.Windows.Automation.Condition]::TrueCondition
         }
         
         If($VerbosePreference -gt "SilentlyContinue") {
         
            function Write-Condition {
               param([Parameter(ValueFromPipeline=$true)]$condition, $indent = 0)
               process {
                  Write-Debug ($Condition | fl *  | Out-String)               
                  if($condition -is [System.Windows.Automation.AndCondition] -or $condition -is [System.Windows.Automation.OrCondition]) {
                     Write-Verbose ((" "*$indent) + $Condition.GetType().Name )
                     $condition.GetConditions().GetEnumerator() | Write-Condition -Indent ($Indent+4)
                  } elseif($condition -is [System.Windows.Automation.PropertyCondition]) {
                     Write-Verbose ((" "*$indent) + $Condition.Property.ProgrammaticName + " = '" + $Condition.Value + "' (" + $Condition.Flags + ")")
                  } else {
                     Write-Verbose ((" "*$indent) + $Condition.GetType().Name + " where '" + $Condition.Value + "' (" + $Condition.Flags + ")")
                  }
               }
            }
         
            Write-Verbose "CONDITIONS ============="
            $global:LastCondition = $condition
            foreach($c in $condition) {            
               Write-Condition $c
            }
            Write-Verbose "============= CONDITIONS"
         }
         
         if($filters.Count -gt 0) {
            $Element = $Parent.FindAll( $search, $condition ) | Where-Object { $item = $_;  foreach($f in $filters) { $item = $item | Where $f }; $item }
         } else {
            $Element = $Parent.FindAll( $search, $condition )
         }
      }  
   }
   
   Write-Verbose "Element Count: $(@($Element).Count)"
   if($Element) {
      foreach($el in $Element) {
         if($Bare) {
            Write-Output $el
         } else {
            $e = New-Object PSObject $el
            foreach($prop in $e.GetSupportedProperties() | Sort ProgrammaticName)
            {
               ## TODO: make sure all these show up: [System.Windows.Automation.AutomationElement] | gm -sta -type Property
               $propName = [System.Windows.Automation.Automation]::PropertyName($prop)
               Add-Member -InputObject $e -Type ScriptProperty -Name $propName -Value ([ScriptBlock]::Create( "`$this.GetCurrentPropertyValue( [System.Windows.Automation.AutomationProperty]::LookupById( $($prop.Id) ))" )) -EA 0
            }
            foreach($patt in $e.GetSupportedPatterns()| Sort ProgrammaticName)
            {
               Add-Member -InputObject $e -Type ScriptProperty -Name ($patt.ProgrammaticName.Replace("PatternIdentifiers.Pattern","") + "Pattern") -Value ([ScriptBlock]::Create( "`$this.GetCurrentPattern( [System.Windows.Automation.AutomationPattern]::LookupById( '$($patt.Id)' ) )" )) -EA 0
            }
            Write-Output $e
         }
      }
   }
}

}

Export-ModuleMember -cmdlet * -Function * -Alias *

#   [Cmdlet(VerbsCommon.Add, "UIAHandler")]
#   public class AddUIAHandlerCommand : PSCmdlet
#   {
#      private AutomationElement _parent = AutomationElement.RootElement;
#      private AutomationEvent _event = WindowPattern.WindowOpenedEvent;
#      private TreeScope _scope = TreeScope.Children;
#
#      [Parameter(ValueFromPipeline = true)]
#      [Alias("Parent", "Element", "Root")]
#      public AutomationElement InputObject { set { _parent = value; } get { return _parent; } }
#
#      [Parameter()]
#      public AutomationEvent Event { set { _event = value; } get { return _event; } }
#
#      [Parameter()]
#      public AutomationEventHandler ScriptBlock { set; get; }
#
#      [Parameter()]
#      public SwitchParameter Passthru { set; get; }
#
#      [Parameter()]
#      public TreeScope Scope { set { _scope = value; } get { return _scope; } }
#
#      protected override void ProcessRecord()
#      {
#         Automation.AddAutomationEventHandler(Event, InputObject, Scope, ScriptBlock);
#
#         if (Passthru.ToBool())
#         {
#            WriteObject(InputObject);
#         }
#
#         base.ProcessRecord();
#      }
#   }