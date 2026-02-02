
Add-Type -AssemblyName System.Drawing

$files = Get-ChildItem "d:\fullstack\icons\*.png"

foreach ($file in $files) {
    Write-Host "Converting $($file.Name) to real PNG..."
    
    # Load Image (works even if ext is wrong)
    $img = [System.Drawing.Image]::FromFile($file.FullName)
    
    # Create new filename (temp)
    $tempName = $file.FullName + ".temp"
    
    # Save as PNG
    $img.Save($tempName, [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Dispose()
    
    # Replace original
    Remove-Item $file.FullName
    Rename-Item $tempName $file.Name
}

Write-Host "All icons converted to proper PNG format!"
