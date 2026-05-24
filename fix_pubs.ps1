$content = Get-Content -Raw publications.html
$scriptStart = $content.IndexOf("  // Split the text into individual publications")

$goodScript = @'
  // Split the text into individual publications
  const publications = publicationsText.split('\n\n');

  // Create a dictionary to store publications by year
  const publicationsByYear = {};

  // Iterate over each publication
  publications.forEach(publication => {
    // Extract year from each publication
    const yearMatch = publication.match(/year={([^}]*)}/);
    if (yearMatch) {
      const year = parseInt(yearMatch[1]);
      // Add publication to the respective year array in the dictionary
      if (!publicationsByYear[year]) {
        publicationsByYear[year] = [];
      }
      publicationsByYear[year].push(publication);
    }
  });

  const publicationList = document.getElementById('publication-list');

  // Iterate over publications by year and display them
  Object.keys(publicationsByYear).sort((a, b) => b - a).forEach(year => {
    // Create header for each year
    const yearHeader = document.createElement('div');
    yearHeader.classList.add('year-header');
    yearHeader.textContent = year;
    publicationList.appendChild(yearHeader);

    // Iterate over publications for the current year
    publicationsByYear[year].forEach(publication => {
      // Extract information from the publication
      const titleMatch = publication.match(/title={([^}]*)}/);
      const authorMatch = publication.match(/author={([^}]*)}/);
      const volumeMatch = publication.match(/volume={([^}]*)}/);
      const publisherMatch = publication.match(/publisher={([^}]*)}/);
      const journalMatch = publication.match(/journal={([^}]*)}/);
      
      const citationMatch = publication.match(/citation={([^}]*)}/);
      const rankMatch = publication.match(/rank={([^}]*)}/i);
      const ifMatch = publication.match(/impactfactor={([^}]*)}/i);

      if (titleMatch && authorMatch) {
        const title = titleMatch[1];
        let authors = authorMatch[1].split(' and ').map(author => {
          const parts = author.split(',');
          if (parts.length > 1) {
            const [lastName, firstName] = parts.map(name => name.trim());
            return `${firstName} ${lastName}`;
          }
          return author.trim();
        }).join(', ');
        
        // Highlight Zulfiqar Ahmad Khan
        authors = authors.replace(/(Zulfiqar Ahmad Khan|Zulfiqar Khan|Z\.?\s*Khan|Zulfiqar A\.? Khan)/gi, '<span style="color: #4facfe;">$1</span>');
        
        let journal = journalMatch ? journalMatch[1] : '';
        const volume = volumeMatch ? volumeMatch[1] : '';
        const publisher = publisherMatch ? publisherMatch[1] : '';
        
        // Fix Mojibake/Korean characters
        if (/[^\x00-\x7F]/.test(journal)) {
            journal = 'Korean Local Journal';
        }
        
        // Extract URL or DOI if present
        const urlMatch = publication.match(/url={([^}]*)}/);
        const doiMatch = publication.match(/doi={([^}]*)}/);
        
        let link = "";
        if (urlMatch) {
            link = urlMatch[1];
        } else if (doiMatch) {
            link = "https://doi.org/" + doiMatch[1];
        } else {
            link = `https://scholar.google.com/scholar?q=${encodeURIComponent(title)}`;
        }

        let extraInfo = [];
        if (volume) extraInfo.push(`Volume: ${volume}`);
        if (publisher) extraInfo.push(`Publisher: ${publisher}`);
        if (journal) extraInfo.push(`Journal: ${journal}`);

        let citationText = citationMatch ? citationMatch[1] : '';
        let rankText = rankMatch ? rankMatch[1] : '';
        let ifText = ifMatch ? ifMatch[1] : '';

        let citationHtml = '';
        if (citationText) {
            citationHtml = `<div style="font-size: 15px; font-style: italic; margin-bottom: 6px; color: #e0e0e0;">${citationText}</div>`;
        }

        let metricsHtml = '';
        let metricsArray = [];
        if (rankText) metricsArray.push(`<span style="background: rgba(0,242,254,0.1); border: 1px solid rgba(0,242,254,0.3); padding: 2px 8px; border-radius: 4px; font-weight: 600;">Rank: ${rankText}</span>`);
        if (ifText) metricsArray.push(`<span style="background: rgba(0,242,254,0.1); border: 1px solid rgba(0,242,254,0.3); padding: 2px 8px; border-radius: 4px; font-weight: 600;">IF: ${ifText}</span>`);
        
        if (metricsArray.length > 0) {
            metricsHtml = `<div style="font-size: 13px; color: #00f2fe; margin-top: 8px; display: flex; gap: 10px;">${metricsArray.join('')}</div>`;
        }

        // Create list item for the publication
        const listItem = document.createElement('li');
        listItem.innerHTML = `<a href="${link}" target="_blank" style="color: #00f2fe; text-decoration: none; display: block; font-size: 18px; margin-bottom: 4px; font-weight: 700; transition: color 0.2s;" onmouseover="this.style.color='#fff';" onmouseout="this.style.color='#00f2fe';">${title}</a>
        ${citationHtml}
        <div style="margin-bottom: 6px; font-size: 15px;">Authors: ${authors}</div>
        <div style="opacity: 0.8; font-size: 14px;">${extraInfo.join('<br>')}</div>
        ${metricsHtml}`;

        // Append list item to the publication list
        publicationList.appendChild(listItem);
      }
    });
  });
</script>
</body>
</html>
'@

$newContent = $content.Substring(0, $scriptStart) + $goodScript
Set-Content -Path publications.html -Value $newContent -Encoding UTF8
