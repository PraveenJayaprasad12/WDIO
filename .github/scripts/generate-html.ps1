param (
    [string]$runUrl,
    [string]$runDate,
    [string]$suiteName
)

$indexFile = "reports/index.html"

# Initialize counters for overall pass calculation
$totalTestsOverall = 0
$passedTestsOverall = 0

# Start writing HTML
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
        .details { background-color: #fff; border: 1px solid #ccc; max-width: 800px; margin: 0 auto 30px auto; padding: 20px; border-radius: 8px; }
        .details h2 { margin-top: 0; color: #555; font-size: 20px; border-bottom: 1px solid #ccc; padding-bottom: 5px; }
        .details p { margin: 8px 0; font-size: 16px; }
        ul { list-style-type: none; padding: 0; max-width: 800px; margin: 0 auto; }
        li { margin: 10px 0; }
        a { display: inline-block; padding: 15px 20px; background-color: #007BFF; color: white; text-decoration: none; border-radius: 5px; transition: background-color 0.3s ease; font-size: 16px; margin-right: 10px; }
        a:hover { background-color: #0056b3; }
        .percentage { font-weight: bold; font-size: 16px; color: #333; }
    </style>
</head>
<body>
    <h1>Test Suite Reports</h1>
"@ | Out-File $indexFile -Encoding utf8

# Add "Execution Details" section
@"
    <div class="details">
        <h2>Execution Details</h2>
"@ | Out-File $indexFile -Append -Encoding utf8

if ($suiteName) {
    "        <p><strong>Suite Name:</strong> $suiteName</p>" | Out-File $indexFile -Append -Encoding utf8
}
if ($runDate) {
    "        <p><strong>Date:</strong> $runDate</p>" | Out-File $indexFile -Append -Encoding utf8
}
if ($runUrl) {
    "        <p><strong>GitHub Run:</strong> <a href='$runUrl' target='_blank'>$runUrl</a></p>" | Out-File $indexFile -Append -Encoding utf8
}

# Start list for report links
"</div><ul>" | Out-File $indexFile -Append -Encoding utf8

# Process each report folder
Get-ChildItem -Directory "reports" | ForEach-Object {
    $artifactName = $_.Name
    $artifactPath = $_.FullName

    # Initialize per-report values
    $totalTests = 0
    $passedTests = 0
    $passPercentageText = ""

    $reportFilePath = Join-Path $artifactPath "artifacts/test-report.txt"
    if (Test-Path $reportFilePath) {
        $reportText = Get-Content $reportFilePath -Raw

        if ($reportText -match "Total Tests\s*:\s*(\d+)\s*,\s*Passed Tests\s*:\s*(\d+)\s*,\s*Failed Tests\s*:\s*(\d+)") {
            $totalTests = [int]$matches[1]
            $passedTests = [int]$matches[2]

            # Add to overall counters
            $totalTestsOverall += $totalTests
            $passedTestsOverall += $passedTests

            if ($totalTests -gt 0) {
                $passPercent = [math]::Round(($passedTests / $totalTests) * 100, 2)
                $passPercentageText = "<span class='percentage'>Pass: $passPercent%</span>"
            }
        }
    }

    # Add HTML report links
    Get-ChildItem -Path $artifactPath -Filter *.html -Recurse | ForEach-Object {
        $relativePath = Resolve-Path -Relative $_.FullName | ForEach-Object { $_ -replace "^.*?reports[\\/]", "" -replace "\\", "/" } 
        $linkText = "$artifactName - $($_.Name)"
        "<li><a href=""$relativePath"">$linkText</a> $passPercentageText</li>" | Out-File $indexFile -Append -Encoding utf8
    }
}

# Close the list
"</ul>" | Out-File $indexFile -Append -Encoding utf8

# Add overall pass percentage
if ($totalTestsOverall -gt 0) {
    $overallPass = [math]::Round(($passedTestsOverall / $totalTestsOverall) * 100, 2)
    "<div class='details'><p><strong>Total Tests:</strong> $totalTestsOverall%</p></div>" | Out-File $indexFile -Append -Encoding utf8
    "<div class='details'><p><strong>Passed Tests:</strong> $passedTestsOverall%</p></div>" | Out-File $indexFile -Append -Encoding utf8
    "<div class='details'><p><strong>Overall Pass Percentage:</strong> $overallPass%</p></div>" | Out-File $indexFile -Append -Encoding utf8
}

# Close HTML
@"
</body>
</html>
"@ | Out-File $indexFile -Append -Encoding utf8
