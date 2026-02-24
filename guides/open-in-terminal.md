# Open CL4R1T4S in Your Terminal

A quick-start guide for cloning and exploring this repository locally.

## Clone the Repository

```bash
git clone https://github.com/strodriguez0128/CL4R1T4S.git
cd CL4R1T4S
```

## Explore the Structure

```
CL4R1T4S/
├── ANTHROPIC/        # Claude system prompts & instructions
├── OPENAI/           # GPT / ChatGPT system prompts
├── CURSOR/           # Cursor IDE agent prompts
├── WINDSURF/         # Windsurf prompts
├── DEVIN/            # Devin AI prompts
├── GOOGLE/           # Gemini / Google AI prompts
├── XAI/              # Grok / xAI prompts
├── PERPLEXITY/       # Perplexity AI prompts
├── REPLIT/           # Replit AI prompts
├── MANUS/            # Manus agent prompts
├── ...               # and more
└── guides/           # How-to guides (you are here)
```

## Search Through Prompts

Find any keyword across all extracted prompts:

```bash
# Search for a specific instruction or phrase
grep -ri "you are" ANTHROPIC/ --include="*.md" --include="*.txt"

# Search across all AI providers
grep -ri "do not" . --include="*.md" --include="*.txt" | grep -v ".git"

# List all files by provider
ls ANTHROPIC/ OPENAI/ CURSOR/ GOOGLE/
```

## Read a Prompt

```bash
# View a specific system prompt
cat ANTHROPIC/Claude_Code_03-04-24.md

# Page through a long prompt
less OPENAI/ChatGPT_*.md

# Count lines in a prompt
wc -l ANTHROPIC/*.txt
```

## Stay Up to Date

```bash
git pull origin main
```

## Contribute a New Prompt

```bash
# 1. Create a branch
git checkout -b add/<model-name>-<date>

# 2. Add your file (use the provider folder, name it clearly)
# Example: ANTHROPIC/Claude_Opus_4_Feb-2026.md

# 3. Commit with context
git add ANTHROPIC/Claude_Opus_4_Feb-2026.md
git commit -m "Add Claude Opus 4 system prompt (Feb 2026)"

# 4. Push and open a pull request
git push origin add/<model-name>-<date>
```

### File naming convention

```
<Provider>/<ModelName>_<Version>_<Mon-YYYY>.md
```

Example: `ANTHROPIC/Claude_Sonnet_4.5_Sep-2025.md`

Include at the top of every new file:

```
Model: <model name and version>
Date extracted: <YYYY-MM-DD or approximate>
Source / context: <how it was obtained, optional>
```

## Related Guides

- [Debugging npm on WSL2](./wsl-react-npm.md)
