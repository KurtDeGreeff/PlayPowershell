function Select-FromTextMenu {
            <#
            .Synopsis
               Selects objects from an array using a text menu of selected properties.
            .DESCRIPTION
              Offers a text menu to select one or more objects from a an array, 
              by a list of selected properties. The display object will have an Item number,
              and the properties specified in the -By parameter taken from the original object.
              After the selection is made, the select Item numers will be used to select the
              original objects from the array to return - i.e. the return will be the original 
              objects, with all properties and methods intact, not the display objects.
              

              The default is to allow only a single object to be selectd.

              Use -Multi to allow selection of one or more entries from the menu.
                When selecting multiple objects, PowerShell range and/or array syntax can be used
                to specify the Items to select.

            .EXAMPLE
              $users | Select-FromTextMenu -by * | unlock-adaccount
            .EXAMPLE
              get-childitem *.csv | Select-FromTextMenu -by name,lastwritetime | invoke-item
            .EXAMPLE
              get-childitem *.txt |
               Select-FromTextMenu -Multi -by name,length,creationtime -Prompt 'Choose files to open'|
                invoke-item
            #>

            Param
            (

             # Objects to select from
             [Parameter(ValueFromPipeline=$true)]

             [object[]]
             $InputObjects,
            
             # Fields to display 
             [Parameter(Mandatory=$false,
                     Position=0)]

             [string[]]
             $By,

             # Prompt to display 
             [String]
             $Prompt,


             # Select Multiple Objects
             [Switch]
             $Multi
         )

           Begin

           {

             if (-not $Multi){$Single = $true}

             $GetSelection =  {
             
                $Selection = $Null

                $Display | ft -auto | Out-Host
             
                $Selection = Read-Host $Prompt
             
               #Check for Single item
                If (
                     $Single -and
                     $Selection.Split('.,').count -gt 1
                     )
                       {
                         Write-Host 'You may only select a single Item' -ForegroundColor Yellow
                         .$GetSelection
                       }

                #Check for Cancel
             
                if ($Selection -eq 'C'){
                   Write-Host 'Selection Cancelled'
                   Return 'Cancelled'
                   }        

                #Check for invalid characters and syntax

                if (
                    ($Selection -notmatch '[0-9,.]') -or
                    ($Selection.Split(',') -notmatch '^((?:\d+\.\.\d+)|(?:\d+))$')
                    )
                     {
                     Write-Host 'Enter selection numbers as a range and/or comma separated list.' -ForegroundColor Yellow
                     Write-Host 'Examples: 3,1,2,4  1..3,7   5,1..2,4' -ForegroundColor Gray
                     .$GetSelection
                    }

                #Check for out of range values

                $HighVal =   [int[]]($Selection.Split('.,')) -match '\d+' | 
                  Sort | 
                    select -last 1
         

                if (
                    $HighVal -gt $Display.count
                    )
                    {
                      Write-Host 'Selection is out of range.' -ForegroundColor Yellow
                      .$GetSelection
                    }

                  
               else {$Selection}
            
          } # End Get-Selection


           If (-not $Prompt){

                   If ($Single){
     
                                 $Prompt = 'Choose one'

                                }

                     Else {

                                 $Prompt = 'Choose one or more'

                          }

                }


           $Prompt = $Prompt += ' (C to Cancel)'

           $Item = 1

           $Display = @()

           $InputArray = @()


           if ($By)           
             {$By = @('Item') + $By}

            else {$By = @('Item')}


           $FirstObject = $true

         }
             
         Process

         {
           #Validate -By property list from first object
           if ($FirstObject) 
              {
               
               #-By contains property list
               if ($By.count -gt 1)
                  {
                   $Object_Props = $_.psobject.properties |
                     select -expand Name

                   $Selected_Props = $By |
                     select -skip 1 

                   $Invalid_Props = $Selected_Props |
                     Where {$Object_Props -notcontains $_}

                  if ($Invalid_Props){
                    #Invalid property name(s) found in -By list
                    Write-Warning "Select-FromTextMenu: One or more invalid property names found in -By list: $([string]$Invalid_Props)" 
                    $Validate_Failed = $true
                    }

                  }

               # No properties specified for -By. Use default
               if ($By.Count -eq 1)
                 {
                   $Default_Prop_String = $_  |
                   format-list |
                   out-string 

                   ($Default_Prop_String -split "`n") -match '^\S+\s+:\s.+?$' |
                     select -first 5 |
                     foreach {$By += ($_ -split ' : ')[0].trim()}
                 }
             
               $FirstObject = $false

              } #End FirstObject

            if ($Validate_Failed){return}

            $InputArray += $_
      
            $DisplayItem =   $_ | Select-Object $By

            $DisplayItem.Item = [string]($Item++)

            $Display += $DisplayItem

                                    
         }

        End 

       { 

       if ($Validate_Failed){Return}
                 
       $Selection = &$GetSelection

       if ($Selection -ne 'Cancelled')

          {
       
           $Selection = ($Selection.split(',')|% {iex $_} | Get-Unique)

           $Index_Array = $Selection |
            foreach {$_ -1}

           $InputArray[$Index_Array]
       
          }

        }

    }
