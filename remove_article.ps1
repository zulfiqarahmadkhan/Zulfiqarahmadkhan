$content = Get-Content -Raw publications.html -Encoding UTF8

$articleStart = "@article{yar2021vision,"
$articleBlock = "@article{yar2021vision,
  title={Vision sensor-based real-time fire detection in resource-constrained IoT environments},
  author={Yar, Hikmat and Hussain, Tanveer and Khan, Zulfiqar Ahmad and Koundal, Deepika and Lee, Mi Young and Baik, Sung Wook and others},
  journal={Computational intelligence and neuroscience},
  volume={2021},
  year={2021},
  publisher={Hindawi}
,
  rank={Q1},
  impactfactor={4.5},
  citation_count={80}
}"

# We will just replace it if we find it exactly, or use regex
$pattern = '(?s)@article\{yar2021vision,.*?citation_count=\{80\}\r?\n\}'
$content = $content -replace $pattern, ""

Set-Content -Path publications.html -Value $content -Encoding UTF8
