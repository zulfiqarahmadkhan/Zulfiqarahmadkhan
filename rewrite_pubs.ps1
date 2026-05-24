$content = Get-Content -Raw publications.html
$regex = "(?s)<script>.*?</script>"
$scriptMatch = [regex]::Match($content, $regex).Value

$newHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Zulfiqar Ahmad Khan - Publications</title>
  <link rel="shortcut icon" href="./assets/images/logo.png" type="image/x-icon">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="./assets/css/bento.css">
  <style>
    .year-header {
        color: #00f2fe;
        font-size: 24px;
        font-weight: 700;
        margin-top: 30px;
        margin-bottom: 15px;
        border-bottom: 1px solid rgba(0, 242, 254, 0.3);
        padding-bottom: 5px;
    }
    #publication-list li {
        background: rgba(255, 255, 255, 0.02);
        padding: 20px;
        border-radius: 12px;
        margin-bottom: 15px;
        border: 1px solid rgba(255,255,255,0.05);
        color: #d4d4d8;
        line-height: 1.6;
        transition: transform 0.2s, background 0.3s;
    }
    #publication-list li:hover {
        background: rgba(0, 242, 254, 0.05);
        transform: translateY(-2px);
    }
    #publication-list li strong {
        color: #fff;
        font-size: 18px;
        display: block;
        margin-bottom: 8px;
    }
  </style>
</head>
<body>
  <div class="bento-container">
    
    <!-- Hero / Profile -->
    <div class="bento-item bento-hero delay-1">
      <img src="./assets/images/profile.jpg" alt="Zulfiqar Ahmad Khan" class="avatar-huge">
      <h1 class="bento-title">Zulfiqar Ahmad Khan</h1>
      <p class="bento-subtitle">Postdoctoral Researcher</p>
      
      <div class="social-links">
        <a href="https://www.linkedin.com/in/zulfiqar-ahmad-khan-0124501b9/"><img src="assets/images/Linkdinn .png" alt="LinkedIn"></a>
        <a href="https://github.com/zulfiqarahmadkhan"><img src="assets/images/GitHub.png" alt="GitHub"></a>
        <a href="https://scholar.google.com/citations?user=TmDD6z8AAAAJ&hl=en"><img src="assets/images/GoogleSchoular.png" alt="Google Scholar"></a>
        <a href="https://www.researchgate.net/profile/Zulfiqar-Khan-11"><img src="assets/images/ResearchGate.png" alt="Research Gate"></a>
      </div>
    </div>

    <!-- Navigation -->
    <div class="bento-item bento-nav delay-2">
      <a href="index.html" class="nav-link">About</a>
      <a href="CV.html" class="nav-link">CV</a>
      <a href="publications.html" class="nav-link active">Publications</a>
      <a href="Contact.html" class="nav-link">Contact</a>
    </div>

    <!-- Publications List -->
    <div class="bento-item bento-wide delay-3">
      <h2 class="bento-title" style="margin-bottom: 20px;">Publications</h2>
      <ul id="publication-list" style="list-style: none; padding: 0;">
        <!-- Publications dynamically added here -->
      </ul>
    </div>
  </div>
  <script src="./assets/js/bento.js"></script>
  $scriptMatch
</body>
</html>
"@

Set-Content -Path publications.html -Value $newHtml -Encoding UTF8
