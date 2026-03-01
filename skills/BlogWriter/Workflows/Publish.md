# Publish Workflow

> **Trigger:** "publish the blog post", "push the post live", "deploy the blog"

Takes a drafted blog post (from WriteFromTopic or WriteFromWork) and deploys it to your blog site via a Docusaurus blog repo on a remote server.

## Configuration

| Setting | Value |
|---|---|
| Blog repo (remote server) | `~/Documents/git/your-org/your-blog-repo` |
| SSH host | `your-dev-server` |
| Post format | Docusaurus `.mdx` |
| Post directory | `blog/YYYY-MM-DD-slug/index.mdx` |
| Image directory | `static/img/blog/YYYY-MM-DD-slug/` |
| Author | `[jon]` |
| Bun path | `export PATH=$HOME/.bun/bin:$PATH` |

## Steps

### Step 1: Write Post to Devbox

```bash
SLUG="the-post-slug"
DATE=$(date +%Y-%m-%d)
DIR="blog/${DATE}-${SLUG}"
BLOG_REPO="~/Documents/git/your-org/your-blog-repo"

ssh your-dev-server "mkdir -p ${BLOG_REPO}/${DIR}"

ssh your-dev-server "cat > ${BLOG_REPO}/${DIR}/index.mdx" << 'EOF'
[post content]
EOF

# Verify it wrote correctly
ssh your-dev-server "head -10 ${BLOG_REPO}/${DIR}/index.mdx"
```

### Step 2: Generate Hero Banner (MANDATORY)

Use the **Art skill** to create the hero image:

```
/Art "Create a hero banner image for a blog post about [TOPIC].
[Visual description matching the post content]. Excalidraw hand-drawn style.
Save to ~/Downloads/hero-banner.png"
```

Then convert to JPG and place it on your-dev-server:

```bash
SLUG="the-post-slug"
DATE=$(date +%Y-%m-%d)
IMG_DIR="static/img/blog/${DATE}-${SLUG}"
BLOG_REPO="~/Documents/git/your-org/your-blog-repo"

ssh your-dev-server "mkdir -p ${BLOG_REPO}/${IMG_DIR}"

# Convert PNG → JPG (REQUIRED — homepage useBlogPosts.ts hardcodes .jpg extension)
# Art skill saves image locally. Use scp to transfer to the remote server.
# Works even if already on the remote server (scp to localhost).
# The remote server may have `convert` (ImageMagick v6) or `magick` (v7) — check before using
scp ~/Downloads/hero-banner.png your-dev-server:/tmp/hero-banner.png
ssh your-dev-server "convert /tmp/hero-banner.png -quality 85 ${BLOG_REPO}/${IMG_DIR}/hero-banner.jpg && rm /tmp/hero-banner.png"
```

### Step 3: Hero Image Gate (MANDATORY — DO NOT SKIP)

All three checks must pass before proceeding:

```bash
POST_FILE="${BLOG_REPO}/${DIR}/index.mdx"
IMG_FILE="${BLOG_REPO}/${IMG_DIR}/hero-banner.jpg"

# CHECK 1: Image file exists on disk
ssh your-dev-server "test -f ${IMG_FILE} && echo 'CHECK 1 PASS' || echo 'CHECK 1 FAIL'"

# CHECK 2: Frontmatter has image: field
ssh your-dev-server "grep -q '^image:' ${POST_FILE} && echo 'CHECK 2 PASS' || echo 'CHECK 2 FAIL'"

# CHECK 3: Inline image tag exists in post body
ssh your-dev-server "grep -q '!\[.*\](.*hero-banner.jpg)' ${POST_FILE} && echo 'CHECK 3 PASS' || echo 'CHECK 3 FAIL'"
```

**Failure recovery:**
- CHECK 1 fails → go back to Step 2 and regenerate the image
- CHECK 2 fails → add `image:` field to frontmatter
- CHECK 3 fails → add inline `![alt](...)` right before `{/* truncate */}`

**Do NOT proceed until all 3 checks pass.**

### Step 4: Local Build Test (MANDATORY)

```bash
ssh your-dev-server "export PATH=\$HOME/.bun/bin:\$PATH && cd ~/Documents/git/your-org/your-blog-repo && bun run build 2>&1"
```

Build MUST succeed with no errors. Warnings about `tags.yml` are OK.

**Local serve verification (MANDATORY before push):**

```bash
ssh your-dev-server "export PATH=\$HOME/.bun/bin:\$PATH && cd ~/Documents/git/your-org/your-blog-repo && npx docusaurus serve --port 3333 &"
sleep 5

# CRITICAL: Verify post appears on HOMEPAGE (catches date ordering issues)
# The homepage shows the 3 most recent posts via useBlogPosts.ts → recent-blog-posts-plugin.ts
ssh your-dev-server "curl -s http://localhost:3333/ | grep -o '${SLUG}' | head -3"

# Verify hero image renders on homepage cards (catches .jpg vs .png mismatch)
ssh your-dev-server "curl -s http://localhost:3333/ | grep -oP 'img/blog/[^\"]+' | head -5"

# Verify post page loads
ssh your-dev-server "curl -sI http://localhost:3333/blog/${SLUG} | head -3"

# Cleanup
ssh your-dev-server "pkill -f 'docusaurus serve'"
```

**If the post does NOT appear on the homepage:** The date is likely not the newest. Docusaurus sorts by date descending, then alphabetically by slug within the same date. Bump the date to be more recent than all existing posts.

### Step 5: Commit and Push

```bash
ssh your-dev-server "cd ~/Documents/git/your-org/your-blog-repo && \
  git add blog/${DATE}-${SLUG}/index.mdx static/img/blog/${DATE}-${SLUG}/hero-banner.jpg && \
  git commit -m 'Add blog post: ${TITLE}' && \
  git push"
```

### Step 6: Verify Live Site (MANDATORY)

GitHub Pages takes ~3-5 minutes to rebuild after a push.

1. Wait 5 minutes after push
2. Use **AgentBrowser** to verify:
   - `https://yourdomain.com/blog/<slug>` — page loads, images render, tables/code blocks look correct
   - `https://yourdomain.com` — "Latest Blog Posts" section shows the new post with hero image
3. If not updated yet, wait 2 more minutes and retry

### Step 7: Report to User

```
## Published!

**Title:** [title]
**URL:** https://yourdomain.com/blog/<slug>
**Status:** Live and verified

Checks passed:
- [x] Hero image present (frontmatter + inline)
- [x] Build succeeded
- [x] Live page renders correctly
- [x] Homepage shows new post
```

## Final Checklist

- [ ] Post written to correct directory on the remote server (date from `$(date +%Y-%m-%d)`)
- [ ] Hero banner generated via Art skill and converted to `.jpg`
- [ ] Hero image referenced in frontmatter AND inline before `{/* truncate */}`
- [ ] All 3 hero image gate checks pass
- [ ] `{/* truncate */}` marker present
- [ ] At least one table and one code block in post
- [ ] Post is 80-120 lines
- [ ] HIPAA guardrails applied (if healthcare content)
- [ ] Local build succeeds with no errors
- [ ] Local serve test: post appears on homepage AND post page loads correctly
- [ ] Post date is newest (otherwise homepage won't show it in top 3)
- [ ] Committed and pushed to GitHub
- [ ] Waited for GitHub Pages rebuild (~3-5 min)
- [ ] AgentBrowser verified: post page + homepage render correctly
- [ ] Live URL reported to user
