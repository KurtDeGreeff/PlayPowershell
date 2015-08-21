function Show-GridView {
#.Synopsis
#  Creates a ListView with a GridView
#.Example
#  Get-ChildItem | 
#     Show-GridView -Property Mode, Length, Name -Show
#
#  Description
#  -----------
#  Creates a GridView of Files with the specified properties 
param(
   # The data to be displayed in the GridView
   [Parameter(ValueFromPipeline=$true)]
   $InputObject,
   # The columns desired for the GridVew should be specified 
   # as an array of property names
   [Parameter(Position=0, Mandatory=$true)]
   [String[]]$Property,
#### ShowUI Common Parameters ##############################
   [string]$Name, [Int]$Row, [Int]$Column, [Int]$RowSpan,
   [Int]$ColumnSpan, [Int]$Width, [Int]$Height, 
   [Double]$Top, [Double]$Left, 
   [Windows.Controls.Dock]$Dock,
   [Switch]$Show, [Switch]$AsJob, [Switch]$OutputXaml
)
begin {
   # Make a copy of PSBoundParameters to pass to our control
   $Parameters = @{} + $PSBoundParameters
   # Remove parameters that aren't valid for ListView
   $null = $Parameters.Remove('InputObject')
   $null = $Parameters.Remove('Property')
   # Create an ObservableCollection for data binding
   $Items = New-Object `
      Collections.ObjectModel.ObservableCollection[PSObject]
}
process {
   # Add the input object(s) to the ObservableCollection
   foreach($item in @($InputObject)){
      $Items.Add( $item )
   }
}
end {
   # Create a ListView, passing on the PSBoundParameters
   # But specify a GridView View and the ItemsSource
   ListView @Parameters -ItemsSource $Items -View {
      GridView -Columns {
         # We need to turn the $Property array into headers:
         foreach($col in $Property) {
            # Put spaces in there to pretty it up
            $header = $col -csplit "(?<=[^ ])(?=[A-Z][a-z])"
            $header = ($header -join " ").Trim()
            # Create a column with a header
            GridViewColumn -Header $header -DisplayMember { 
               Binding $col
            }
         }
      }
   } -On_Loaded {
      # Set-UIValue so our control has output!
      Set-UIValue -UI $this -value $this.Items
   # We'll re-set it whenever the Selection changes
   } -On_SelectionChanged {
      # If there's nothing selected
      if($this.SelectedItems.Count -eq 0) {
         # Output all the items
         Set-UIValue -UI $this -Value $this.Items
      } else {
         # Otherwise output the selected items
         Set-UIValue -UI $this -value $this.SelectedItems
      } 
   }
}
}
