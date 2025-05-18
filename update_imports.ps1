# PowerShell script to update package imports
Write-Host "Starting to update package imports from 'hook_up_rent' to 'rent_share'"

# Get all Dart files in the lib directory
$dartFiles = Get-ChildItem -Path "D:\flutterProject\hook_up_rent_migrated\lib" -Filter "*.dart" -Recurse

$count = 0
foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Check if the file contains the old import
    if ($content -match "package:hook_up_rent/") {
        # Replace all occurrences of the old import with the new one
        $newContent = $content -replace "package:hook_up_rent/", "package:rent_share/"
        
        # Write the updated content back to the file
        Set-Content -Path $file.FullName -Value $newContent
        
        $count++
        Write-Host "Updated imports in: $($file.FullName)"
    }
}

Write-Host "Completed updating imports in $count files."
