
Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param([string]$FilePath, [int]$Size)
    
    Write-Host "Resizing $FilePath to ${Size}x${Size}..."
    
    $image = [System.Drawing.Image]::FromFile($FilePath)
    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
    $graph = [System.Drawing.Graphics]::FromImage($bitmap)
    
    $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graph.DrawImage($image, 0, 0, $Size, $Size)
    
    $image.Dispose()
    
    # Save as PNG
    $tempName = $FilePath + ".temp.png"
    $bitmap.Save($tempName, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $bitmap.Dispose()
    $graph.Dispose()
    
    Remove-Item $FilePath
    Rename-Item $tempName (Split-Path $FilePath -Leaf)
}

$icons = @{
    "icon-72.png"  = 72
    "icon-96.png"  = 96
    "icon-128.png" = 128
    "icon-144.png" = 144
    "icon-152.png" = 152
    "icon-192.png" = 192
    "icon-384.png" = 384
    "icon-512.png" = 512
}

foreach ($name in $icons.Keys) {
    $path = "d:\fullstack\icons\$name"
    if (Test-Path $path) {
        Resize-Image -FilePath $path -Size $icons[$name]
    }
    else {
        Write-Host "Warning: $name not found."
    }
}
