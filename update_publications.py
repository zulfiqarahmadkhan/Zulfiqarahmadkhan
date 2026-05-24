import os
import re
from scholarly import scholarly

def clean_title(title):
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
    
    # Parse existing titles
    existing_titles = []
    title_pattern = re.compile(r'title={([^}]+)}')
    for title_match in title_pattern.finditer(existing_bibtex):
        existing_titles.append(clean_title(title_match.group(1)))
        
    print(f"Found {len(existing_titles)} existing publications.")

    print(f"Fetching publications for author ID {scholar_id}...")
    try:
        author = scholarly.search_author_id(scholar_id)
        author = scholarly.fill(author, sections=['publications', 'indices', 'counts'])
    except Exception as e:
        print(f"Error fetching author: {e}")
        return

    new_bibtex_entries = []
    
    for pub in author.get('publications', []):
        title = pub.get('bib', {}).get('title', '')
        if not title:
            continue
            
        if clean_title(title) not in existing_titles:
            print(f"New publication found: {title}")
            try:
                # Fetch full details for the publication
                pub_filled = scholarly.fill(pub)
                bib = pub_filled.get('bib', {})
                
                year = bib.get('pub_year', 'nodate')
                if str(year).isdigit() and int(year) < 2020:
                    print(f"Skipping older publication ({year}): {title}")
                    continue
                
                # Construct BibTeX entry
                # Generate a simple cite key
                author_names = bib.get('author', '').split(' and ')
                first_author_last_name = author_names[0].split(',')[-1].strip().split(' ')[-1].lower() if author_names else 'unknown'
                title_first_word = clean_title(title.split(' ')[0]) if title else 'notitle'
                cite_key = f"{first_author_last_name}{year}{title_first_word}"
                
                entry_type = 'article' # Default to article
                if 'journal' not in bib and 'booktitle' in bib:
                    entry_type = 'inproceedings'
                    
                bib_lines = [f"@{entry_type}{{{cite_key},"]
                for key, value in bib.items():
                    # Map scholarly fields to bibtex if necessary
                    bib_key = key
                    if key == 'pub_year':
                        bib_key = 'year'
                    if key == 'venue':
                        bib_key = 'journal'
                        
                    bib_lines.append(f"  {bib_key}={{{value}}},")
                
                num_citations = pub_filled.get('num_citations', 0)
                if num_citations:
                    bib_lines.append(f"  citation_count={{{num_citations}}},")
                
                bib_lines[-1] = bib_lines[-1].rstrip(',') # Remove trailing comma from last item
                bib_lines.append("}")
                
                new_bibtex_entries.append('\n'.join(bib_lines))
                
                # Add to existing titles to prevent duplicates in the same run
                existing_titles.append(clean_title(title))
                
            except Exception as e:
                print(f"Error processing publication '{title}': {e}")
                
    if new_bibtex_entries:
        print(f"Adding {len(new_bibtex_entries)} new publications.")
        new_bibtex_str = '\n\n'.join(new_bibtex_entries)
        
        # Prepend new entries to the existing ones
        updated_bibtex = new_bibtex_str + '\n\n' + existing_bibtex
        
        # Replace in HTML
        updated_html = html_content[:match.start(2)] + updated_bibtex + html_content[match.end(2):]
        
        with open(html_file_path, 'w', encoding='utf-8') as f:
            f.write(updated_html)
            
        print("publications.html updated successfully.")
    else:
        print("No new publications found.")

    # Update index.html with stats
    try:
        index_path = 'index.html'
        with open(index_path, 'r', encoding='utf-8') as f:
            index_content = f.read()
            
        citations = author.get('citedby', 0)
        hindex = author.get('hindex', 0)
        i10index = author.get('i10index', 0)
        
        if citations or hindex or i10index:
            # Replace the contents of the span tags
            index_content = re.sub(r'(<span id="scholar-citations">)[^<]*(</span>)', rf'\g<1>{citations}\g<2>', index_content)
            index_content = re.sub(r'(<span id="scholar-hindex">)[^<]*(</span>)', rf'\g<1>{hindex}\g<2>', index_content)
            index_content = re.sub(r'(<span id="scholar-i10index">)[^<]*(</span>)', rf'\g<1>{i10index}\g<2>', index_content)
            
            with open(index_path, 'w', encoding='utf-8') as f:
                f.write(index_content)
            print(f"Updated index.html with Citations: {citations}, h-index: {hindex}, i10-index: {i10index}")
    except Exception as e:
        print(f"Error updating index.html: {e}")

if __name__ == "__main__":
    main()
