param (
    [string]$runUrl
)

$indexFile = "reports/index.html"

@"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Reports Index</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px; margin: 0; }
        h1 { color: #333; text-align: center; margin-bottom: 10px; }
        p { text-align: center; margin-bottom: 30px; }
        ul { list-style-type: none; padding: 0; max-width: 800px; margin: 0 auto; }
        li { margin: 10px 0; }
        a { display: block; padding: 15px 20px; background-color: #007BFF; color: white; text-decoration: none; border-radius: 5px; transition: background-color 0.3s ease; font-size: 16px; }
        a:hover { background-color: #0056b3; }
    </style>
</head>
<body>
    <h1>Test Suite Reports</h1>
"@ | Out-File $indexFile -Encoding utf8

# Optional GitHub Actions Run URL section
if ($runUrl) {
    "    <p><a href='$runUrl' target='_blank'>🔗 View this GitHub Actions Run</a></p>" | Out-File $indexFile -Append -Encoding utf8
}

# Start the list of reports
"    <ul>" | Out-File $indexFile -Append -Encoding utf8

# Loop through subfolders inside reports/
Get-ChildItem -Directory "reports" | ForEach-Object {
    $artifactName = $_.Name
    Get-ChildItem -Path $_.FullName -Filter *.html -Recurse | ForEach-Object {
        $relativePath = Resolve-Path -Relative $_.FullName | ForEach-Object { $_ -replace "^.*?reports[\\/]", "" -replace "\\", "/" } 
        $linkText = "$artifactName - $($_.Name)"
        "        <li><a href=""$relativePath"">$linkText</a></li>" | Out-File $indexFile -Append -Encoding utf8
    }
}

# Close HTML
@"
    </ul>
</body>
</html>
"@ | Out-File $indexFile -Append -Encoding utf8
