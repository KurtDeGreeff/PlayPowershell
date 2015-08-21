<#
.Synopsis
  Allows user selection of objects to continue down the pipeline.
.DESCRIPTION
   Implements a manual filter of pipeline objects by presenting the user with
    a table of the input objects, by selected properties.
    One or more objects can be selected.

  The function will return the orignal objects the display objects were derived from,
   not the display objects, so all the original properties and methods will be intact 
   on the returned objects.

.Parameter By 
    The objects will be returned in the order they were selected.


   Use the -By parameter to specify the properies of the input objects you wish
     to use for the selection display.  Any properties specified that do not exist
     on the first object will be discarded and a warning issued.
     
    If the -By parameter is omitted, or no valid parameters are listed in the parameter
     arguments, a default property list will be used.

    The default property list will be the first 5 default display properties of the object type.


.Parameter Multi
  
    The default is to allow selection of only one object

    Use the -Multi switch to enable selection of multiple objects.

.Parameter Prompt

    Specifies a text string to use for the selection prompt.  Default selection help text will be appended
     to the string in the console prompt.
     
.Parameter Color

    Use the -Color switch to display a colorized table.
     If the switch is omitted, Format-Table will be used to display the selection table.

.Parameter Verify

    This -Verify parameter will re-display the selected display objects and prompt the user to
     accept the selection to continue.  If the user elects not to accept the selection, the
     selection table will be re-displayed and the user propted to re-enter their selection.

       
.EXAMPLE
   Get-Childitem -Recurse -Include *.log |
     Sort LastWriteTime |
     Select-Item -By Name,Length,Lastwritetime -Multi -Verify -Color -Prompt 'Select log files to delete'|
     Select -ExpandProperty FullName |
     Remove-Item -Verbose
      
.INPUTS
   Array of objects from the pipeline to select from.
.OUTPUTS
   User-selected objects from the array of input objects.
.NOTES
   Author: Rob Campbell (@mjolinor)
   Version: 1.1
   Last updated: 01/16/2013
#>

function Select-Item
{

    Param
    (
        # Input objects to select from
         [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
         [object[]]          
         $InputObject,

        # Property list to use for selection display
         [string[]]
         $By,

        # Prompt to display 
         [String]
         $Prompt,


        # Select Multiple Objects
         [Switch]
         $Multi,

        # Use colorized display
         [Switch]
         $Color,

        # Re-display selected objects and prompt to verify selection or retry
         [Switch]
         $Verify
    )

    Begin
    {
      #Array for pipeline input
      [array]$_InputArray = $null


      #Script Blocks and functions



        #Function to get default display properties to use if not specied in -By
         
      function _Get-DefaultDisplayProperties ($_InputObject)
       {

          #Use Format-List to get default property list

           $_FormatListString =
            $_InputObject |
            format-list |
            out-string

           #Parse property list from Format-List string 

           $_FormatListRegex = [regex]'(?ms)^\S+\s+:\s.+?$'

           [regex]::Matches($_FormatListString,$_FormatListRegex) |
           select -ExpandProperty Value |
             foreach {
                      ($_ -split '\s:\s')[0].trim()
                     }
           }
     #End function Get-DefaultPropertyList

     #Set Display format

       if (
           $color
          )
           {
             function _Show-Table ($_TableObjects) {

               $_Colors =
                @{
                  0 = 'Green'
                  1 = 'White'
                 }

              $_DisplayText = 
               $_TableObjects |
               format-table -auto |
               Out-String
              
              $_TextLines =  $_DisplayText -split "`n" 
              Write-Host ''
              Write-Host $_TextLines[1] -BackgroundColor darkcyan -ForegroundColor white

             for ($i=3 ; $i -lt $_TextLines.count ; $i++)
                {
                  Write-Host $_TextLines[$i] -BackgroundColor $_colors[$i % 2] -ForegroundColor Black
                }
           }
         }

         else {
                function _Show-Table ($_TableObjects)
                  {
                   $_TableObjects |
                   format-table -auto |
                   Out-String |
                   Out-Host
                  }
              }
      #End Set display format


     #Function to get selected object list from user

       function _GetSelection  
        {
          [string]$_Selection = $Null

          _Show-Table $_DisplayObjects
             
          $_Selection = Read-Host $_SelectionPrompt

          #Check for Cancel
           
           if ($_Selection -ieq 'C')
             {
              Write-Host 'Selection Cancelled'
              Return
             }

          #Check for All
           
           if (
                ($Multi) -and
                ($_Selection -ieq 'A')
              )
               {
                 $_InputArray
                 Return
               }         

             
          #Check for Single item

            If (
                (-not $Multi) -and
                ($_Selection.Trim() -notmatch '^\d+')
               )
                 {
                   Write-host "`nInvalid selection. Enter the Item number you wish to select" -ForegroundColor Yellow
                   Write-Host 'You may only select a single Item' -ForegroundColor Yellow
                   . _GetSelection
                   Return
                 }



           #Check for invalid characters and syntax

             if (
                 ($_Selection -notmatch '[0-9,.]') -or
                 ($_Selection.Split(',') -notmatch '^((?:\d+\.\.\d+)|(?:\d+))$')
                )
                 {
                   Write-Host 'Enter selection numbers as a range and/or comma separated list.' -ForegroundColor Yellow
                   Write-Host 'Examples: 3,1,2,4  1..3,7   5,1..2,4' -ForegroundColor Gray
                   . _GetSelection
                   Return
                 }

             #Check for out of range values

             [int[]]$_Values = ($_Selection -split '\.\.|,' ) |
                 sort

               if (
                    ($_DisplayObjects.count -lt $_Values[-1]) -or
                    ($_Values[0] -eq 0)
                  )
                     {
                       Write-Host 'Selection is out of range.' -ForegroundColor Yellow
                       . _GetSelection
                       Return
                     }

                  
               #Valid array elements are selected

                  #create index array from user selection string

                  foreach ($_SelectedElement in ($_Selection.split(',')))
                          {
                           $_SelectedIndexes +=
                             (Invoke-Expression $_SelectedElement)
                         }
                    
                    $_SelectedIndexes =
                     $_SelectedIndexes|
                      foreach {
                               $_ -1
                              }

                   if ($Verify)
                     {
                       $_GetConfirmation = 
                         {
                           $_Continue = 
                           Read-Host 'Continue using selected objects (Y\N)'
                                
                           Switch ($_Continue)
                             {
                               'Y'      {
                                          $_InputArray[$_SelectedIndexes]
                                        }

                               'N'      {
                                           Write-Host 'Selection Cancelled. Retry selection.'
                                            $_SelectedIndexes = $null
                                            . _GetSelection
                                        }

                                Default {
                                          Write-Host 'Invalid selection' -ForegroundColor Yellow
                                          .$_GetConfirmation
                                        }
                              }
                          }

                        Write-Host 'Selected Objects:'
                        _Show-Table $_DisplayObjects[$_SelectedIndexes]
                        .$_GetConfirmation
                     }
                  
                     else {            
                            $_InputArray[$_SelectedIndexes]
                            Return
                          }
               }

    }

    Process
    {
      $_InputArray += $InputObject
    }

    End
    {
      if ($_InputArray)
        {

         [string[]]$_InputObjectProperties = $null

         [string[]]$_DisplayProperties = $null

         [object[]]$_DisplayObjects = $null

         [String]$_SelectionPromptAppend = ' (C to Cancel)'

         [String]$_multiSelectionPromptAppend = ' (A for all, C to Cancel)'

         [String]$_DefaultSinglePrompt = 'Select one'

         [String]$_DefaultMultiPrompt = 'Select one or more'

         [String[]]$_Selection = $null

         [int[]]$_SelectedIndexes = $null


         #Get property list from first input object
           $_InputObjectProperties = 
             $_InputArray[0].psobject.properties |
             select -ExpandProperty Name
        
         #Validate parameter property list
          if ($By) 
            {
              foreach ($_PropName in $By)
               {
                 if (
                       $_InputObjectProperties -notcontains $_PropName
                    )
                      {
                       Write-Warning "Invalid property name in -By: $_PropName"
                      }

                  else
                      { 
                       $_DisplayProperties += $_PropName
                      }
                  } 


              if (
                  $_DisplayProperties.count -eq 0
                 ) 
                  {
                    Write-Warning 'No valid propery names found in -By. Using defult property list'
                  }
            }

         #Get default property list
          if (-not $_DisplayProperties)
            {
             $_DisplayProperties = 
              _Get-DefaultDisplayProperties $_InputArray[0] |
              select -First 5
            }
         
     
          #Create display objects

          [int]$_DisplayItem = 1

          #Use specified or default properties
          If ($_DisplayProperties)
            {
              $_DisplayProperties =
               @('Item') + $_DisplayProperties
           
              $_DisplayObjects = 
               $_InputArray |         
               select $_DisplayProperties 
          
              $_DisplayObjects |
               ForEach-Object {
                $_.Item = $_DisplayItem++
                }
            }

             #No display properties.  Create objects using string values of input objects

               else {
                      $_DisplayObjects = 
                       &{foreach ($_InputObject in $_InputArray)
                          {
                            New-Object PSObject -Property @{
                                                         Item = $_DisplayItem++
                                                         Value = $_InputObject.tostring()
                                                         }
                          } 
                        } | select Item,Value
                     }

         #Set Selection Prompt
          
          if ($Prompt)
            {
              $_SelectionPrompt= $Prompt
            }
           
           else
             {
               if ($Multi)
                {
                 $_SelectionPrompt = $_DefaultMultiPrompt 
                }

                else {
                       $_SelectionPrompt = $_DefaultSinglePrompt
                     }
              }

          if ($Multi)
            {
             $_SelectionPrompt += $_MultiSelectionPromptAppend 
            }
            
            else {
                  $_SelectionPrompt += $_SelectionPromptAppend 
                 }


     #Get User selection
       . _GetSelection                        
          
      
     }

       else {
              Write-Warning 'Select-Item: No input objects to select from'
            }
    }

  } 