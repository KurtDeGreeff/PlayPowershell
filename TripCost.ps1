Ipmo ShowUI
New-Window -Title "Trip Cost" -WindowStartupLocation CenterScreen `
  -Width 300 -Height 200 -Show {
 
  New-Grid -Rows 32, 32*, 32*, 32* -Columns 100, 100* {
    New-Button -Content "_Calculate" -Row 0 -Column 0 -Margin 3 -On_Click {
      $txtTotalCost      = $Window | Get-ChildControl txtTotalCost
      $txtMiles          = $Window | Get-ChildControl txtMiles
      $txtMilesPerGallon = $Window | Get-ChildControl txtMilesPerGallon
      $txtCostPerGallon  = $Window | Get-ChildControl txtCostPerGallon
     
      $txtTotalCost.Text = `
        "{0:n2}" -f (($txtMiles.Text / $txtMilesPerGallon.Text) * $txtCostPerGallon.Text)
    }
   
  New-TextBox -Name txtTotalCost -Row 0 -Column 1 -Margin 3
 
  New-TextBlock -Text "Miles" -Row 1 -Column 0 -VerticalAlignment Center -Margin 3       
  New-TextBox -Name txtMiles -Row 1 -Column 1 -Margin 3 -Text 100
 
  New-TextBlock -Text "Miles Per Gallon" -Row 2 -Column 0 -VerticalAlignment Center -Margin 3
  New-TextBox -Name txtMilesPerGallon -Row 2 -Column 1 -Margin 3 -Text 23
 
  New-TextBlock -Text "Cost Per Gallon" -Row 3 -Column 0 -VerticalAlignment Center -Margin 3
  New-TextBox -Name txtCostPerGallon -Row 3 -Column 1 -Margin 3 -Text 2.50
  }
}

