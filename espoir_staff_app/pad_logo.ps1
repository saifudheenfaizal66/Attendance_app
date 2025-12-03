
Add-Type -AssemblyName System.Drawing

$sourcePath = "c:\Users\saifu\Desktop\attendence\espoir_staff_app\asset\Espoir_Logo.png"
$destPath = "c:\Users\saifu\Desktop\attendence\espoir_staff_app\asset\Espoir_Logo_Padded.png"

# Load original image
$original = [System.Drawing.Image]::FromFile($sourcePath)

# Define new size (same as original to keep resolution, but we will scale down the content)
# Actually, for adaptive icons, we want the content to be about 66% of the full size.
# So if we keep the canvas size the same, we shrink the logo.
# Or we make the canvas bigger. Let's make the canvas bigger.
# If original is WxH, new canvas should be W*1.5 x H*1.5 roughly.

$width = $original.Width
$height = $original.Height
$paddingFactor = 1.5 # The canvas will be 1.5x the logo size, effectively adding padding

$newWidth = [int]($width * $paddingFactor)
$newHeight = [int]($height * $paddingFactor)

$bitmap = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
$graph = [System.Drawing.Graphics]::FromImage($bitmap)

# Clear with transparent background
$graph.Clear([System.Drawing.Color]::Transparent)

# Calculate center position
$x = ($newWidth - $width) / 2
$y = ($newHeight - $height) / 2

# Draw original image in center
$graph.DrawImage($original, [int]$x, [int]$y, $width, $height)

# Save
$bitmap.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)

$original.Dispose()
$bitmap.Dispose()
$graph.Dispose()

Write-Host "Created padded image at $destPath"
