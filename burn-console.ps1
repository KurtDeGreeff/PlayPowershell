############################################################################### 
## burn-console.ps1 
## 
## Create a fire effect in PowerShell, using the Console text buffer as the  
## rendering surface. 
## 
## Great overview of the fire effect algorithm here:  
## http://freespace.virgin.net/hugo.elias/models/m_fire.htm 
## 
############################################################################### 

function main 
{ 
    write-debug “ENTER main” 
    ## Rather than a simple red fire, we’ll introduce oranges and yellows 
    ## by including Yellow as one of the base colours 
    $colours = “Yellow”,“Red”,“DarkRed”,“Black” 
     
    ## The four characters that we use to dither with, along with the  
    ## percentage of the foreground colour that they show 
    $dithering = “█”,“▓”,“▒”,“░” 
    $ditherFactor = 1,0.75,0.5,0.25 
     
    ## Hold the palette.  We actually store each entry as a BufferCell, 
    ## since we need to retain a foreground colour, background colour, 
    ## and dithering character. 
    [System.Management.Automation.Host.BufferCell[]] $palette = ` 
        new-object System.Management.Automation.Host.BufferCell[] 256 
     
    ## Resize the console to 70, 61 so we have a consistent buffer 
    ## size for performance comparison. 
    # $bufferSize = new-object System.Management.Automation.Host.Size 70,61 
    # $host.UI.RawUI.WindowSize = $bufferSize 

    ## Retrieve some commonly used dimensions 
    $windowWidth = $host.UI.RawUI.WindowSize.Width 
    $windowHeight = $host.UI.RawUI.WindowSize.Height 
    $origin = ` 
        new-object System.Management.Automation.Host.Coordinates 0,0 
    $dimensions = ` 
        new-object System.Management.Automation.Host.Rectangle ` 
            0,0,$windowWidth,$windowHeight 
     
    ## Create our random number generator 
    $random = new-object Random 
    $workingBuffer = new-object System.Int32[] ($windowHeight * $windowWidth) 
    $screenBuffer = new-object System.Int32[] ($windowHeight * $windowWidth) 

    ## Store a reference to the Invoke-Inline script to save lookup time 
    ## since we run it so often. 
    $inline = Get-Command Invoke-Inline.ps1 
     
    clear-host 
     
    ## Generate the palette 
    generatePalette 
    # displayPalette 
    # return; 

    ## Update the buffer, then update the screen until the user presses a key.   
    ## Keep track of the total time and frames generated to let us display 
    ## performance statistics. 
    $frameCount = 0 
    $totalTime = measure-command { 
        while(! $host.UI.RawUI.KeyAvailable) 
        { 
            updateBuffer 
            updateScreen 
            $frameCount++ 
        } 
    } 
     
    ## Clean up and exit 
    $host.UI.RawUI.ForegroundColor = “Gray” 
    $host.UI.RawUI.BackgroundColor = “Black” 
     
    write-host 
    write-host “$($frameCount / $totalTime.TotalSeconds) frames per second.” 
    write-debug “EXIT” 
} 

## Update a back-buffer to hold all of the information we want to display on 
## the screen.  To do this, we first re-generate the fire pixels on the bottom  
## row.  With that done, we visit every pixel in the screen buffer, and figure 
## out the average heat of its neighbors.  Once we have that average, we move 
## that average heat one pixel up. 
function updateBuffer 
{ 
    ## This function takes the most of our time, so we’ll do it inline. 
    ## Inputs: 
    ##  Window Height 
    ##  Window Width 
    ##  Screen Buffer 
    ##  Random Number Generator 
    ## Output: 
    ##  Working Buffer 
     
    [System.Collections.ArrayList] $inputs = ` 
        new-object System.Collections.ArrayList 
    [void] $inputs.Add([int] $windowHeight) 
    [void] $inputs.Add([int] $windowWidth) 
    [void] $inputs.Add([int[]] $screenBuffer) 
    [void] $inputs.Add([System.Random] $random) 
     
    $code = @” 
    // Unpack the inputs from our input object 
    int windowHeight = (int) ((System.Collections.ArrayList) arg)[0]; 
    int windowWidth = (int) ((System.Collections.ArrayList) arg)[1]; 
    int[] screenBuffer = (int[]) ((System.Collections.ArrayList) arg)[2]; 
    Random random = (Random) ((System.Collections.ArrayList) arg)[3]; 
     
    // Start fire on the last row of the screen buffer 
    for(int column = 0; column < windowWidth; column++) 
    { 
        // There is an 80% chance that a pixel on the bottom row will 
        // start new fire. 
        if(random.NextDouble() >= 0.20) 
        { 
            // The chosen pixel gets a random amount of heat.  This gives 
            // us a lot of nice colour variation. 
            screenBuffer[(windowHeight - 2) * (windowWidth) + column] =  
                (int) (random.NextDouble() * 255); 
        } 
    } 
     
    int[] tempWorkingBuffer = (int[]) screenBuffer.Clone(); 
     
    // Propigate the fire 
    int baseOffset = windowWidth + 1; 
    for(int row = 1; row < (windowHeight - 1); row++) 
    { 
        for(int column = 1; column < (windowWidth - 1); column++) 
        { 
            // Get the average colour from the four pixels surrounding 
            // the current pixel 
            double colour =  
                ( 
                    screenBuffer[baseOffset] +  
                    screenBuffer[baseOffset - 1] +  
                    screenBuffer[baseOffset + 1] +  
                    screenBuffer[baseOffset + windowWidth] 
                 ) / 4.0; 

            // Cool it off a little.  We apply uneven cooling, otherwise 
            // the cool dark red tends to stretch up for too long. 
            if(colour > 0) 
            { 
                if(colour > 70) 
                {  
                    colour -= 1;  
                } 
                else 
                { 
                    colour -= 3; 
                     
                    if(colour < 1) 
                    { 
                        colour = 0; 
                    } 
                    else if(colour < 20) 
                    { 
                        colour -= 1; 
                    } 
                } 
            } 

            // Store the result into the previous row – that is, one buffer  
            // cell up. 
            tempWorkingBuffer[baseOffset - windowWidth] = (int) colour; 
            baseOffset ++; 
        } 
         
        baseOffset += 2; 
    } 

    returnValue = tempWorkingBuffer; 
“@ 

    $returned = & $inline $code $inputs 
    $SCRIPT:workingBuffer = $returned 
} 

## Take the contents of our working buffer and blit it to the screen 
## We do this in one highly-efficent step (the SetBufferContents) so that 
## users don’t see each individial pixel get updated. 
function updateScreen 
{ 
    write-debug “ENTER updateScreen” 
     
    ## This function takes up a lot of time, so we’ll do it inline. 
    ## Inputs: 
    ##  host.UI.RawUI 
    ##  palette 
    ##  workingBuffer 
    ##  origin 
    ##  dimensions 
    ##  windowHeight 
    ##  windowWidth 
    ## Output: 
    ##  None 
     
    [System.Collections.ArrayList] $inputs = ` 
        new-object System.Collections.ArrayList 
    [void] $inputs.Add([System.Management.Automation.Host.PSHostRawUserInterface] $host.UI.RawUI) 
    [void] $inputs.Add([System.Management.Automation.Host.BufferCell[]] $palette) 
    [void] $inputs.Add([int[]] $workingBuffer) 
    [void] $inputs.Add([System.Management.Automation.Host.Coordinates] $origin) 
    [void] $inputs.Add([System.Management.Automation.Host.Rectangle] $dimensions) 
    [void] $inputs.Add([int] $windowHeight) 
    [void] $inputs.Add([int] $windowWidth) 
     
    $code = @” 

    System.Management.Automation.Host.PSHostRawUserInterface rawUI =  
        (System.Management.Automation.Host.PSHostRawUserInterface) 
            ((System.Collections.ArrayList) arg)[0]; 
    System.Management.Automation.Host.BufferCell[] palette = 
        (System.Management.Automation.Host.BufferCell[])  
            ((System.Collections.ArrayList) arg)[1]; 
    int[] workingBuffer =  
        (int[]) ((System.Collections.ArrayList) arg)[2]; 
    System.Management.Automation.Host.Coordinates origin =  
        (System.Management.Automation.Host.Coordinates) 
            ((System.Collections.ArrayList) arg)[3]; 
    System.Management.Automation.Host.Rectangle dimensions =  
        (System.Management.Automation.Host.Rectangle) 
            ((System.Collections.ArrayList) arg)[4]; 
    int windowHeight = (int) ((System.Collections.ArrayList) arg)[5]; 
    int windowWidth = (int) ((System.Collections.ArrayList) arg)[6]; 

    // Create a working buffer to hold the next screen that we want to 
    // create. 
    System.Management.Automation.Host.BufferCell[,] nextScreen =  
        rawUI.GetBufferContents(dimensions); 
     
    // Go through our working buffer (that holds our next animation frame) 
    // and place its contents into the buffer that we will soon blast into 
    // the real RawUI 
    for(int row = 0; row < windowHeight; row++) 
    { 
        for(int column = 0; column < windowWidth; column++) 
        { 
            nextScreen[row, column] = palette[workingBuffer[(row * windowWidth) + column]]; 
        } 
    } 
     
    // Bulk update the RawUI’s buffer with the contents of our next screen 
    rawUI.SetBufferContents(origin, nextScreen); 
“@ 
    & $inline $code $inputs 
     
    ## And finally update our representation of the screen buffer to hold 
    ## what actually is on the screen 
    $SCRIPT:screenBuffer = $workingBuffer.Clone() 

    write-debug “EXIT” 
} 

## Generates a palette of 256 colours.  We create every combination of  
## foreground colour, background colour, and dithering character, and then 
## order them by their visual intensity. 
## 
## The visual intensity of a colour can be expressed by the NTSC luminance  
## formula.  That formula depicts the apparent brightness of a colour based on  
## our eyes’ sensitivity to different wavelengths that compose that colour. 
## http://en.wikipedia.org/wiki/Luminance_%28video%29 
function generatePalette 
{ 
    ## The apparent intensities of our four primary colours. 
    ## However, the formula under-represents the intensity of our straight 
    ## red colour, so we artificially inflate it. 
    $luminances = 225.93,106.245,38.272,0 
    $apparentBrightnesses = @{} 

    ## Cycle through each foreground, background, and dither character 
    ## combination.  For each combination, find the apparent intensity of the  
    ## foreground, and the apparent intensity of the background.  Finally, 
    ## weight the contribution of each based on how much of each colour the 
    ## dithering character shows. 
    ## This provides an intensity range between zero and some maximum. 
    ## For each apparent intensity, we store the colours and characters 
    ## that create that intensity. 
    $maxBrightness = 0 
    for($fgColour = 0; $fgColour -lt $colours.Count; $fgColour++) 
    { 
        for($bgColour = 0; $bgColour -lt $colours.Count; $bgColour++) 
        { 
            for($ditherCharacter = 0;  
                $ditherCharacter -lt $dithering.Count;  
                $ditherCharacter++) 
            { 
                $apparentBrightness = ` 
                    $luminances[$fgColour] * $ditherFactor[$ditherCharacter] + 
                    $luminances[$bgColour] * 
                        (1 - $ditherFactor[$ditherCharacter]) 
                     
                if($apparentBrightness -gt $maxBrightness)  
                {  
                    $maxBrightness = $apparentBrightness  
                } 
                     
                $apparentBrightnesses[$apparentBrightness] = ` 
                    “$fgColour$bgColour$ditherCharacter” 
            } 
       } 
    } 

    ## Finally, we normalize our computed intesities into a pallete of 
    ## 0 to 255.  If a given intensity is 30% towards our maximum intensity, 
    ## then it should be in the palette at 30% of index 255. 
    $paletteIndex = 0 
    foreach($key in ($apparentBrightnesses.Keys | sort)) 
    { 
        $keyValue = $apparentBrightnesses[$key] 
        do 
        { 
            $character = $dithering[[Int32]::Parse($keyValue[2])] 
            $fgColour = $colours[[Int32]::Parse($keyValue[0])] 
            $bgColour = $colours[[Int32]::Parse($keyValue[1])] 
             
            $bufferCell = ` 
                new-object System.Management.Automation.Host.BufferCell ` 
                    $character, 
                    $fgColour, 
                    $bgColour, 
                    “Complete” 
                     
            $palette[$paletteIndex] = $bufferCell 
            $paletteIndex++ 
        } while(($paletteIndex / 256) -lt ($key / $maxBrightness)) 
    } 
} 

## Dump the palette to the screen. 
function displayPalette 
{ 
    for($paletteIndex = 254; $paletteIndex -ge 0; $paletteIndex) 
    { 
        $bufferCell = $palette[$paletteIndex] 
        $fgColor = $bufferCell.ForegroundColor 
        $bgColor = $bufferCell.BackgroundColor 
        $character = $bufferCell.Character 

        $host.UI.RawUI.ForegroundColor = $fgColor 
        $host.UI.RawUI.BackgroundColor = $bgColor 
        write-host -noNewLine $character 
    } 
     
    write-host 
} 

. main