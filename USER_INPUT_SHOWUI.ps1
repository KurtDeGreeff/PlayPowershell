function Get-UIInput {
      #.Synopsis
      #  Prompt the user for input with a pretty dialog
      #.Parameter PromptText
      #  The text to prompt the user for (an array of one or more strings)
      #.Example
      #  Get-UIInput "First Name:", "Last Name:", "Age:"
      Param([string[]]$PromptText = "Please enter your name:")

      Show-UI -Parameter @(,$PromptText) {
         Param([string[]]$PromptText)

         $global:UIInputWindow = $this
         function global:Get-UIInputOutput {
            $stack = Select-UIElement $UIInputWindow "Wrapper"
            $Output = @{}
            ## Loop through the stack of prompts and get the user's input
            $inputs = $stack.Children
            while($inputs.Count) {
               $label, $value, $inputs = $inputs
               $Output.($label.Content) = $value.Text
            }
            Write-UIOutput $Output
         }
         
         Border -BorderThickness 4 -BorderBrush "#BE8" -Background "#EFC" {
            Grid -Margin 10 -Name "Wrapper" -Columns Auto,150 -Rows (@("Auto") * ($PromptText.Count + 1)) {

               ## Loop through the prompts and create input boxes for them
               for($i=0;$i -lt $PromptText.Count;$i++) {
                  Label   -Grid-Row $i $PromptText[$i]
                  TextBox -Grid-Row $i -Grid-Column 1 -Width 150 -On_KeyDown { 
                     if($_.Key -eq "Return") { 
                        Get-UIInputOutput
                        $UIInputWindow.Close()
                     }
                  }
               }
               Button "Ok" -Grid-Row $PromptText.Count -Grid-Column 1 -Width 60 -On_Click { 
                  Get-UIInputOutput
                  $UIInputWindow.Close()
               }
            }
         }
      } -On_Load { (Select-UIElement $this "Wrapper").Children[1].Focus() }`
      -WindowStyle None -AllowsTransparency `
      -On_PreviewMouseLeftButtonDown { 
         if($_.Source -notmatch ".*\.(TextBox|Button)") 
         {
            $ShowUI.ActiveWindow.DragMove() 
         }
      }
   }
Get-UIInput