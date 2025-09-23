param (
    [string]$runUrl,
    [string]$runDate,
    [string]$suiteName
)

$indexFile = "reports/index.html"

$totalTestsOverall = 0
$passedTestsOverall = 0

@"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Reports Index</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(to right, #e3f2fd, #ffffff);
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        h1 {
            color: #004085;
            text-align: center;
            margin-bottom: 30px;
            text-shadow: 1px 1px 2px #b3d7ff;
        }

        .bottom-section {
            display: flex;
            justify-content: space-between;
            flex-grow: 1;
        }

        .report-links, .execution-details {
            width: 48%;
            background: linear-gradient(135deg, #ffffff, #e7f1ff);
            border: 1px solid #b3d7ff;
            border-radius: 12px;
            padding: 20px;
            box-sizing: border-box;
            box-shadow: 0 4px 10px rgba(0, 123, 255, 0.2);
            transition: transform 0.2s ease-in-out;
        }

        .report-links:hover, .execution-details:hover {
            transform: translateY(-2px);
        }

        .report-links h2, .execution-details h2 {
            margin-top: 0;
            color: #0056b3;
            font-size: 20px;
            border-bottom: 2px solid #b3d7ff;
            padding-bottom: 5px;
            margin-bottom: 15px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        th, td {
            text-align: left;
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
            font-size: 16px;
        }

        th {
            background: linear-gradient(145deg, #007bff, #339bff);
            color: white;
            border-radius: 4px 4px 0 0;
            text-shadow: 1px 1px 1px rgba(0,0,0,0.1);
        }

        tr:hover {
            background-color: #f1f9ff;
            transition: background-color 0.2s;
        }

        td a {
            color: #007bff;
            text-decoration: none;
        }

        td a:hover {
            text-decoration: underline;
        }

        .percentage {
            font-weight: bold;
            font-size: 16px;
            color: #333;
        }
    </style>
</head>
<body>
    <h1>Test Suite Reports</h1>

    <div class="bottom-section">
        <div class="report-links">
            <h2>Report Links</h2>
            <table>
                <thead>
                    <tr>
                        <th>Report</th>
                        <th>Pass %</th>
                    </tr>
                </thead>
                <tbody>
"@ | Out-File $indexFile -Encoding utf8

# Process each report folder
Get-ChildItem -Directory "reports" | ForEach-Object {
    $artifactName = $_.Name
    $artifactPath = $_.FullName

    $totalTests = 0
    $passedTests = 0
    $passPercentageText = ""

    $reportFilePath = Join-Path $artifactPath "artifacts/test-report.txt"
    if (Test-Path $reportFilePath) {
        $reportText = Get-Content $reportFilePath -Raw
        if ($reportText -match "Total Tests\s*:\s*(\d+)\s*,\s*Passed Tests\s*:\s*(\d+)\s*,\s*Failed Tests\s*:\s*(\d+)") {
            $totalTests = [int]$matches[1]
            $passedTests = [int]$matches[2]

            $totalTestsOverall += $totalTests
            $passedTestsOverall += $passedTests

            if ($totalTests -gt 0) {
                $passPercent = [math]::Round(($passedTests / $totalTests) * 100, 2)
                $passPercentageText = "<span class='percentage'>$passPercent%</span>"
            }
        }
    }

    Get-ChildItem -Path $artifactPath -Filter *.html -Recurse | ForEach-Object {
        $relativePath = Resolve-Path -Relative $_.FullName | ForEach-Object { $_ -replace "^.*?reports[\\/]", "" -replace "\\", "/" }
        $linkText = "$artifactName"
        "<tr><td><a href=""$relativePath"">$linkText</a></td><td>$passPercentageText</td></tr>" | Out-File $indexFile -Append -Encoding utf8
    }
}

@"
                </tbody>
            </table>
        </div>

        <div class="execution-details">
            <h2>Execution Details</h2>
            <table>
                <tbody>
"@ | Out-File $indexFile -Append -Encoding utf8

if ($suiteName) {
    "                    <tr><td><strong>Suite Name:</strong></td><td>$suiteName</td></tr>" | Out-File $indexFile -Append -Encoding utf8
}
if ($runDate) {
    "                    <tr><td><strong>Date:</strong></td><td>$runDate</td></tr>" | Out-File $indexFile -Append -Encoding utf8
}
if ($runUrl) {
    "                    <tr><td><strong>GitHub Run:</strong></td><td><a href='$runUrl' target='_blank'>Click Here</a></td></tr>" | Out-File $indexFile -Append -Encoding utf8
}

if ($totalTestsOverall -gt 0) {
    $overallPass = [math]::Round(($passedTestsOverall / $totalTestsOverall) * 100, 2)
    "                    <tr><td><strong>Total Tests:</strong></td><td>$totalTestsOverall</td></tr>" | Out-File $indexFile -Append -Encoding utf8
    "                    <tr><td><strong>Passed Tests:</strong></td><td>$passedTestsOverall</td></tr>" | Out-File $indexFile -Append -Encoding utf8
    "                    <tr><td><strong>Overall Pass Percentage:</strong></td><td>$overallPass%</td></tr>" | Out-File $indexFile -Append -Encoding utf8
}

@"
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
"@ | Out-File $indexFile -Append -Encoding utf8
