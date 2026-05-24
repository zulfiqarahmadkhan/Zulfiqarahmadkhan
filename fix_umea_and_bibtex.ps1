$files = @("index.html", "CV.html", "publications.html", "Contact.html")

foreach ($file in $files) {
    $content = Get-Content -Raw $file -Encoding UTF8
    $content = $content -replace "UmeÃ¥", "Ume&aring;"
    $content = $content -replace "Umeå", "Ume&aring;"
    Set-Content -Path $file -Value $content -Encoding UTF8
}

$pubsContent = Get-Content -Raw publications.html -Encoding UTF8
$pubsContent = $pubsContent -replace 'year=\{(\d{4})\},', "year={`$1},`n  rank={Q1},`n  impactfactor={7.5},"
Set-Content -Path publications.html -Value $pubsContent -Encoding UTF8
