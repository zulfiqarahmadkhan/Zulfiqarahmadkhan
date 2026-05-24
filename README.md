# Modern Academic Portfolio Template

A sleek, responsive, and dynamic personal portfolio website designed specifically for researchers, postdocs, and academics. It features a modern "Bento Grid" layout with glassmorphism aesthetics, 3D hover tilt effects, and an automated publication management system.

## 🌟 Key Features

- **Bento Grid UI**: A highly modern, tiled layout utilizing CSS Grid that is fully responsive on desktop and mobile.
- **Dynamic Publications System**: 
  - Simply paste your raw BibTeX entries into `publications.html`.
  - The embedded JavaScript engine automatically parses the BibTeX.
  - Automatically highlights your name in the author list.
  - Dynamically renders stylish badges for **Impact Factor (IF)**, **Journal Rank (Q1/Q2)**, and **Live Citations**.
- **Python Automation**: Includes a script (`update_publications.py`) that fetches your latest publications directly from your Google Scholar profile and injects them into the website.
- **Working Contact Form**: Built-in support for FormSubmit. Just change the email address, and you can receive messages directly from the website without any backend setup.
- **Interactive UI**: Includes particle backgrounds, glowing borders, and smooth micro-animations.

---

## 🚀 How to Use & Customize

### 1. Basic Setup
1. Clone or download this repository.
2. Open the project folder and edit the `index.html`, `CV.html`, `publications.html`, and `Contact.html` files using any text editor (like VS Code).
3. Search for "Zulfiqar Ahmad Khan" and replace it with your own name.
4. Replace the social links (LinkedIn, GitHub, Google Scholar, ResearchGate) with your own URLs.
5. Replace `assets/images/profile.jpg` with your own headshot.

### 2. Updating Your Publications
The Publications page is driven entirely by BibTeX. You do **not** need to manually format HTML for each paper.

1. Open `publications.html`.
2. Scroll to the bottom where you see ``const publicationsText = `/* ... */`; ``.
3. Paste your BibTeX entries between the `/*` and `*/`.
4. **To add metrics**: Inside your BibTeX entry, manually add the following fields:
   - `rank={Q1}`
   - `impactfactor={8.5}`
   - `citation_count={42}`
   
   *Example:*
   ```bibtex
   @article{example2025,
     title={An Example Paper Title},
     author={Your Name and Co-Author},
     journal={IEEE Access},
     year={2025},
     rank={Q1},
     impactfactor={3.9},
     citation_count={15}
   }
   ```
   The website will automatically read these fields and generate beautiful cyan badges on the page!

### 3. Automating via Google Scholar
If you want to automatically pull your new papers from Google Scholar:

1. Ensure you have Python installed.
2. Install the required package: `pip install scholarly`
3. Open `update_publications.py` and change the `scholar_id` variable to your own Google Scholar ID.
4. Run the script: `python update_publications.py`
5. The script will find any *new* publications on your profile, fetch the citation count, format it as BibTeX, and inject it into `publications.html`. 

*(Note: Google Scholar does not track Impact Factors or Quartiles, so you will still need to manually type `rank={...}` and `impactfactor={...}` into the BibTeX block for newly added papers).*

### 4. Activating the Contact Form
1. Open `Contact.html`.
2. Locate the form action URL: `<form action="https://formsubmit.co/your-email@gmail.com" method="POST">`
3. Replace the email address with your actual email.
4. Host the website and submit a test message. FormSubmit will send you an activation email. Click the link in that email to activate the form, and you are good to go!

---

## 🎨 Modifying the Theme

The core styling is located in `assets/css/bento.css`. 
- To change the primary cyan color theme, do a find-and-replace for `#00f2fe` and `#4facfe` and swap them with your preferred hex codes.
- The 3D tilt logic and dynamic counter animations are handled in `assets/js/bento.js`.

## 📄 License
This project is open-source. Feel free to use, modify, and distribute it for your own personal academic portfolio!
