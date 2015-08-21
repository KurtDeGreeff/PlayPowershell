function Select-FromGridView {
            <#
            .Synopsis
               Selects objects from an array using a gridview of selected properties.
            .DESCRIPTION
              Offers a gridview to select one or more objects from a an array, 
              by a list of selected properties. Input objects will be added to an
              array, and a display object created.  The display object will have an IDX
              property that is the original object index position in the array, and the
              properties specified in the -By parameter taken from the original object.
              The display objects will appear in the gridview. After the selection is made, 
              the IDX property from the selected display object(s) will be used to select the
               original objects from the array to return - i.e. the return will be the original 
               objects, with all properties and methods intact, not the display objects. 
            .EXAMPLE
              $users | select-fromgridview -by * -single | unlock-adaccount
            .EXAMPLE
              get-childitem *.csv | select-fromgridview -by name,lastwritetime -single | invoke-item
            .EXAMPLE
              get-childitem *.txt |
               select-fromgridview -by name,length,creationtime -Title 'Choose files to open'|
                invoke-item
            #>

            #Requires -Version 3

            Param
            (

             # Objects to select from
             [Parameter(ValueFromPipeline=$true)]

             [object[]]
             $InputObjects,
            
             # Fields to display in gridview
             [Parameter(Mandatory=$true,
                     Position=0)]

             [string[]]
             $By,

             # Title to display on gridview
             [String]
             $Title,

             # Select single object
             [Switch]
             $Single
         )

           Begin

           {
             If ($Single){
            
                   $OutputMode = 'Single'

                   }

             Else {

                   $outputMode = 'Multi'

                   }

           If (-not $Title){

                   If ($Single){
     
                                 $Title = 'Choose one.'

                                }

                     Else {

                                 $Title = 'Choose one or more'

                          }

                }


           $gridview = @{
                          Title = $Title
                          OutputMode = $OutputMode
                        }

           $IDX = 0

           $Display = @()

           $InputArray = @()

           $By = @('IDX') + $By

      
                       
         }

    
         Process

         {

            $InputArray += $_
      
            $DisplayItem =   $_ | Select-Object $By

            $DisplayItem.IDX = $IDX++

            $Display += $DisplayItem
                        
         }

        End 

        { 

         $Selected = $Display | Out-Gridview @GridView
             
           Foreach ($Selection in $Selected){

             $InputArray[$($selection.IDX)]

             }
       }
    }
    get-childitem C:\windows\system32\*.exe | select-fromgridview -by name,length,creationtime -Title 'Choose files to open'| invoke-item
