import os
import re
from scholarly import scholarly

def clean_title(title):
    if not title: return ''
    return re.sub(r'[^a-zA-Z0-9]', '', title).lower()

def main():
    scholar_id = 'TmDD6z8AAAAJ'
    html_file_path = 'publications.html'
    
    # Read existing HTML
    with open(html_file_path, 'r', encoding='utf-8') as f:
        html_content = f.read()
        
    # Extract existing BibTeX block
    bibtex_pattern = re.compile(r'(const publicationsText = `/\*\s*)(.*?)(\s*\*/`;)', re.DOTALL)
    match = bibtex_pattern.search(html_content)
    
    if not match:
        print("Could not find publicationsText block in HTML.")
        return
        
    prefix = match.group(1)
    existing_bibtex = match.group(2)
    suffix = match.group(3)

    print(f"Fetching author ID {scholar_id}...")
    try:
        author = scholarly.search_author_id(scholar_id)
        author = scholarly.fill(author, sections=['publications', 'indices', 'counts'])
    except Exception as e:
        print(f"Error fetching author: {e}")
        return

    # Build a dictionary of titles to citation counts from Google Scholar
    live_citations = {}
    for pub in author.get('publications', []):
        title = pub.get('bib', {}).get('title', '')
        if not title: continue
        c_title = clean_title(title)
        num_citations = pub.get('num_citations', 0)
        live_citations[c_title] = num_citations

    # 1. Update EXISTING entries with new citation counts
    entries = existing_bibtex.split('\n\n')
    updated_entries = []
    existing_titles = []
    
    print("Updating citations for existing papers...")
    for entry in entries:
        if not entry.strip(): continue
        
        t_match = re.search(r'title=\{([^}]+)\}', entry, re.IGNORECASE)
        if t_match:
            title = t_match.group(1)
            c_title = clean_title(title)
            existing_titles.append(c_title)
            
            if c_title in live_citations:
                real_cites = live_citations[c_title]
                
                # Check if citation_count exists
                if re.search(r'citation_count=\{[^}]*\}', entry):
                    entry = re.sub(r'citation_count=\{[^}]*\}', f'citation_count={{{real_cites}}}', entry)
                else:
                    # Safely inject at the end
                    entry = re.sub(r'\}\s*$', f",\n  citation_count={{{real_cites}}}\n}}", entry)
                    
        updated_entries.append(entry)

    # 2. Add NEW publications
    new_bibtex_entries = []
    for pub in author.get('publications', []):
        title = pub.get('bib', {}).get('title', '')
        if not title: continue
            
        if clean_title(title) not in existing_titles:
            print(f"New publication found: {title}")
            try:
                # Fetch full details for the new publication ONLY
                pub_filled = scholarly.fill(pub)
                bib = pub_filled.get('bib', {})
                
                year = bib.get('pub_year', 'nodate')
                if str(year).isdigit() and int(year) < 2020:
                    continue
                
                author_names = bib.get('author', '').split(' and ')
                first_author_last_name = author_names[0].split(',')[-1].strip().split(' ')[-1].lower() if author_names else 'unknown'
                title_first_word = clean_title(title.split(' ')[0]) if title else 'notitle'
                cite_key = f"{first_author_last_name}{year}{title_first_word}"
                
                entry_type = 'article'
                if 'journal' not in bib and 'booktitle' in bib:
                    entry_type = 'inproceedings'
                    
                bib_lines = [f"@{entry_type}{{{cite_key},"]
                for key, value in bib.items():
                    bib_key = key
                    if key == 'pub_year': bib_key = 'year'
                    if key == 'venue': bib_key = 'journal'
                    bib_lines.append(f"  {bib_key}={{{value}}},")
                
                num_citations = pub_filled.get('num_citations', 0)
                bib_lines.append(f"  citation_count={{{num_citations}}}")
                bib_lines.append("}")
                
                new_bibtex_entries.append('\n'.join(bib_lines))
                existing_titles.append(clean_title(title))
                
            except Exception as e:
                print(f"Error processing publication '{title}': {e}")
                
    # Reassemble BibTeX
    final_bibtex = '\n\n'.join(new_bibtex_entries + updated_entries)
    updated_html = html_content[:match.start(2)] + final_bibtex + html_content[match.end(2):]
    
    with open(html_file_path, 'w', encoding='utf-8') as f:
        f.write(updated_html)
        
    print("publications.html updated successfully with ALL citations synced.")

    # 3. Update index.html and publications.html with global stats
    try:
        citations = author.get('citedby', 0)
        hindex = author.get('hindex', 0)
        i10index = author.get('i10index', 0)
        
        if citations or hindex or i10index:
            for filepath in ['index.html', 'publications.html']:
                with open(filepath, 'r', encoding='utf-8') as f:
                    file_content = f.read()
                
                # Replace data-target for the counter animations
                file_content = re.sub(r'(id="scholar-citations" data-target=")[^"]*(")', rf'\g<1>{citations}\g<2>', file_content)
                file_content = re.sub(r'(id="scholar-hindex" data-target=")[^"]*(")', rf'\g<1>{hindex}\g<2>', file_content)
                file_content = re.sub(r'(id="scholar-i10index" data-target=")[^"]*(")', rf'\g<1>{i10index}\g<2>', file_content)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(file_content)
            print(f"Updated global stats: Citations: {citations}, h-index: {hindex}, i10-index: {i10index}")
    except Exception as e:
        print(f"Error updating global stats: {e}")

if __name__ == "__main__":
    main()
