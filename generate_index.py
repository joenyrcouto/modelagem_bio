import os
import urllib.parse

def generate():
    html_template = """
    <!DOCTYPE html>
    <html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Laboratório de Física Biomolecular</title>
        <style>
            body {{ 
                font-family: 'Inter', -apple-system, sans-serif; 
                background: #f8f9fa; color: #212529; 
                margin: 0; padding: 50px; line-height: 1.5;
            }}
            .container {{ max-width: 800px; margin: auto; }}
            header {{ border-bottom: 1px solid #dee2e6; margin-bottom: 30px; padding-bottom: 20px; }}
            h1 {{ font-weight: 700; font-size: 24px; color: #000; margin: 0; }}
            .subtitle {{ color: #6c757d; font-size: 14px; margin-top: 5px; }}
            ul {{ list-style: none; padding: 0; }}
            li {{ 
                background: #fff; 
                margin-bottom: 12px; 
                padding: 16px; 
                border-radius: 8px; 
                border: 1px solid #e9ecef;
                transition: all 0.2s ease;
            }}
            li:hover {{ border-color: #adb5bd; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.05); }}
            .folder-tag {{ 
                font-size: 10px; font-weight: 700; text-transform: uppercase; 
                color: #495057; background: #e9ecef; 
                padding: 2px 8px; border-radius: 4px; margin-bottom: 8px; display: inline-block;
            }}
            a {{ 
                color: #007bff; text-decoration: none; 
                font-weight: 500; font-size: 16px; display: block; 
            }}
            a:hover {{ text-decoration: underline; }}
            .footer {{ margin-top: 60px; font-size: 12px; color: #adb5bd; text-align: center; }}
        </style>
    </head>
    <body>
        <div class="container">
            <header>
                <h1>Modelagem Biomolecular</h1>
                <div class="subtitle">Repositório de Simulações e Notas Acadêmicas • USP São Carlos</div>
            </header>
            <ul>{links}</ul>
            <div class="footer">Gerado via Python 3 • Atualizado em 2026</div>
        </div>
    </body>
    </html>
    """
    links = []
    for root, dirs, files in os.walk("."):
        if ".git" in root or root == ".": continue
        for file in files:
            if file.lower().endswith(".html") and file != "index.html":
                path = os.path.join(root, file).replace("./", "")
                safe_path = urllib.parse.quote(path)
                name = os.path.splitext(os.path.basename(path))[0].replace("_", " ").title()
                folder = os.path.basename(os.path.dirname(path))
                links.append(f'<li><span class="folder-tag">{folder if folder else "Raiz"}</span><a href="{safe_path}">{name}</a></li>')
    
    content = html_template.replace("{links}", "\n".join(sorted(links)))
    with open("index.html", "w", encoding="utf-8") as f:
        f.write(content)

if __name__ == "__main__":
    generate()
