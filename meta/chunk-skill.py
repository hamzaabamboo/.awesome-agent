import os
import re
import sys

def chunk_skill(skill_path):
    with open(skill_path, 'r') as f:
        content = f.read()

    # Split metadata and content
    # Look for the closing --- of the frontmatter
    match = re.search(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
    if not match:
        print("Invalid skill format (missing frontmatter)")
        return
    
    metadata = match.group(1)
    body = content[match.end():]

    docs_dir = os.path.join(os.path.dirname(skill_path), 'docs')
    os.makedirs(docs_dir, exist_ok=True)

    # Split body by "# " headers at the start of a line
    # This usually indicates major categories
    category_parts = re.split(r'\n# ([^\n]+)\n', '\n' + body)
    
    chunks = {}
    
    # index 0 is preamble before first # header
    preamble = category_parts[0].strip()
    if preamble:
        with open(os.path.join(docs_dir, 'introduction.md'), 'w') as f:
            f.write(preamble)
        chunks['Introduction'] = 'introduction.md'
    
    for i in range(1, len(category_parts), 2):
        cat_name = category_parts[i].strip()
        cat_content = category_parts[i+1].strip()
        
        file_name = cat_name.lower().replace(' ', '-').replace('.', '') + '.md'
        # Prevent overwriting introduction if it somehow matches
        if file_name == 'introduction.md': file_name = 'intro.md'
        
        with open(os.path.join(docs_dir, file_name), 'w') as f:
            f.write(f"# {cat_name}\n\n{cat_content}")
        chunks[cat_name] = file_name

    # Create new SKILL.md (Router)
    skill_name = os.path.basename(os.path.dirname(skill_path))
    new_skill_content = f"---\n{metadata}\n---\n\n# {skill_name} - Router\n\n"
    new_skill_content += "This is a SMART SKILL. Documentation is chunked to save context.\n"
    new_skill_content += "Use `list_directory` on `./docs` to see available documentation.\n"
    new_skill_content += "Use `read_file` or `grep_search` on `./docs/<file>.md` for specific info.\n\n"
    new_skill_content += "## Available Categories\n\n"
    for cat_name, file_name in chunks.items():
        new_skill_content += f"- **{cat_name}**: `docs/{file_name}`\n"
    
    with open(skill_path, 'w') as f:
        f.write(new_skill_content)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        chunk_skill(sys.argv[1])
