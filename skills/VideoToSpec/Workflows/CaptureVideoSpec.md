# CaptureVideoSpec Workflow

**Purpose:** Generate comprehensive specification documents from video demonstrations

**Input:** Video URL (Loom, YouTube, Vimeo, etc.) and optional transcript

**Output:** Comprehensive spec document with screenshots and feature descriptions

---

## Process Overview

This workflow automates the creation of detailed product specifications from demo videos by:
1. Navigating to the video and maximizing the player for clear screenshots
2. Systematically capturing screenshots at key timestamps
3. Analyzing video content and transcript
4. Generating a comprehensive specification document

---

## Step 1: Setup and Navigation

### 1.1 Navigate to Video

Use chrome-devtools MCP to navigate to the video URL:

```javascript
// Navigate to video page
mcp__chrome-devtools__navigate_page({
  url: VIDEO_URL,
  type: "url",
  timeout: 30000
})
```

### 1.2 Maximize Video Player

**For Loom videos:**
1. Click transcript tab to access timestamps
2. Modify page HTML to maximize video:

```javascript
// Hide sidebar and maximize video
() => {
  const sidebar = document.querySelector('[role="complementary"]');
  if (sidebar) sidebar.style.display = 'none';

  const video = document.querySelector('video');
  const body = document.body;

  body.innerHTML = '';
  body.style.margin = '0';
  body.style.padding = '0';
  body.style.overflow = 'hidden';
  body.style.backgroundColor = 'black';

  const container = document.createElement('div');
  container.style.width = '100vw';
  container.style.height = '100vh';
  container.style.display = 'flex';
  container.style.alignItems = 'center';
  container.style.justifyContent = 'center';

  video.style.width = '100%';
  video.style.height = '100%';
  video.style.objectFit = 'contain';
  video.controls = true;

  container.appendChild(video);
  body.appendChild(container);

  return { success: true };
}
```

**For YouTube videos:**
- Use theatre mode or fullscreen button
- Or modify page HTML similarly to maximize player

**For other platforms:**
- Identify video container element
- Apply similar maximization technique

### 1.3 Resize Browser Viewport

```javascript
mcp__chrome-devtools__resize_page({
  width: 1920,
  height: 1080
})
```

---

## Step 2: Identify Key Timestamps

### Option A: Use Transcript (Recommended)

If video has a transcript (Loom, YouTube with captions):

1. **Analyze transcript** to identify feature demonstrations
2. **Extract timestamps** where key features are shown
3. **Map features to timestamps:**
   - Dashboard/UI overview
   - Data entry forms
   - Search/filtering capabilities
   - Reports/analytics
   - Settings/configuration
   - Integration points
   - Special features

### Option B: Manual Timestamp Selection

If no transcript available:
1. **Scrub through video** at 10-15 second intervals
2. **Identify distinct UI screens**
3. **Note timestamps** for each unique view
4. **Focus on:**
   - Main navigation/dashboard
   - Core workflows (create, edit, delete)
   - Settings and configuration
   - Reports and analytics
   - Any unique/differentiating features

### Option C: User-Provided Timestamps

User may provide specific timestamps to capture:
```
Capture screenshots at:
- 0:15 - Dashboard
- 1:30 - Patient intake
- 5:45 - Billing interface
```

---

## Step 3: Capture Screenshots

### 3.1 Create Screenshot Directory

```bash
mkdir -p .agent/specs/{product-name}/screenshots
```

Use descriptive directory name based on product (e.g., `urgentiq`, `salesforce`, `stripe-dashboard`).

### 3.2 Navigate and Capture

For each timestamp:

```javascript
// Navigate to timestamp
async () => {
  const video = document.querySelector('video');
  if (video) {
    video.currentTime = TIMESTAMP_IN_SECONDS;
    await new Promise(resolve => setTimeout(resolve, 2500)); // Wait for video to load
    return { success: true, currentTime: video.currentTime };
  }
  return { success: false };
}

// Capture screenshot
mcp__chrome-devtools__take_screenshot({
  format: "png",
  filePath: ".agent/specs/{product-name}/screenshots/{sequence}-{description}-{minutes}min.png"
})
```

**Screenshot Naming Convention:**
- **Sequence number:** 00, 01, 02... (for ordering)
- **Description:** Short feature name (e.g., `dashboard`, `patient-intake`, `billing`)
- **Timestamp:** Minutes into video (e.g., `17min`, `42min`)

**Examples:**
- `00-dashboard-overview-15min.png`
- `01-patient-list-17min.png`
- `05-insurance-verification-32min.png`
- `14-ai-coding-42min.png`

### 3.3 Screenshot Coverage Guidelines

Capture screenshots for:

**Core Navigation**
- Main dashboard/home screen
- Primary navigation menu
- Search functionality

**Data Entry Workflows**
- Create/add new record forms
- Edit existing record forms
- Bulk import/upload interfaces

**Data Display**
- List views with filters/sorting
- Detail views
- Different view modes (table, card, calendar)

**Reports & Analytics**
- Dashboard widgets/KPIs
- Report builder interfaces
- Chart/graph visualizations

**Settings & Configuration**
- User preferences
- System settings
- Integration setup screens

**Special Features**
- AI/automation features
- Mobile views (if shown)
- API/developer tools
- Unique differentiators

**Aim for 15-25 screenshots** for comprehensive coverage.

---

## Step 4: Analyze Video Content

### 4.1 Review Transcript

If transcript available:
1. **Identify feature descriptions** in narration
2. **Note technical details** mentioned (e.g., "Uses Stedi API for verification")
3. **Capture pricing/licensing** information
4. **Record integrations** mentioned
5. **Note limitations** or caveats

### 4.2 Organize Feature List

Create structured outline:

```markdown
## Feature Categories
1. Dashboard & Navigation
2. Data Entry & Forms
3. Search & Filtering
4. Reports & Analytics
5. Integrations
6. AI/Automation Features
7. Mobile/Responsive Features
8. Settings & Configuration
```

For each feature:
- **Name**
- **Screenshot reference**
- **Timestamp in video**
- **Key capabilities**
- **Technical details** (if mentioned)

---

## Step 5: Generate Specification Document

### 5.1 Document Structure

Create comprehensive spec at `.agent/specs/{product-name}/{product-name}-spec.md`:

```markdown
# {Product Name} - Comprehensive Specification

**Document Version:** 1.0
**Date:** {Current Date}
**Source:** {Video Title/URL}
**Video Length:** {Duration}

---

## Table of Contents
1. Executive Summary
2. System Overview
3. [Feature Category 1]
4. [Feature Category 2]
...
N. Technical Architecture
N+1. Comparison with {Competitor}
N+2. Pricing & Licensing

---

## Executive Summary

[Brief overview of what the product is, target market, key differentiators]

### Key Features
- Feature 1
- Feature 2
...

### Target Market
- User persona 1
- User persona 2

---

## System Overview

[High-level architecture, deployment model, access methods]

### Product Philosophy
[Design principles, approach to problem-solving]

### Core Components
1. Component 1 - Description
2. Component 2 - Description

### Technology Stack
- Deployment: [Cloud/On-premise/Hybrid]
- Access: [Web/Mobile/Desktop]
- Integration: [API types, protocols]

![Overview Screenshot](screenshots/00-dashboard-overview-15min.png)
*Caption describing what the screenshot shows*

---

## [Feature Category Name]

### [Sub-Feature Name]

[Detailed description of the feature]

**How It Works:**
1. Step 1
2. Step 2
3. Step 3

**Key Capabilities:**
- Capability 1
- Capability 2

**Screenshots:**
![Feature Screenshot](screenshots/05-feature-name-32min.png)
*Caption*

**Technical Details:**
- API: [If mentioned]
- Integration: [If applicable]
- Limits: [Any constraints]

---

[Repeat for all feature categories]

---

## Technical Architecture

### Deployment Model
- Cloud/On-premise/Hybrid
- Multi-tenant vs. single-tenant

### Access & Security
- Browser requirements
- Mobile apps
- SSO/Authentication
- Data encryption
- Compliance (HIPAA, SOC 2, etc.)

### Integrations
**Available Now:**
- Integration 1
- Integration 2

**Planned:**
- Future integration 1

### API Access
- REST/GraphQL/SOAP
- Documentation availability
- Rate limits

---

## Comparison with {Competitor}

| Feature | {Product} | {Competitor} |
|---------|-----------|--------------|
| Feature 1 | ✅ Details | ❌ or ⚠️ Details |
| Feature 2 | ✅ Details | ✅ Details |

### When {Product} is Better
- Use case 1
- Use case 2

### When {Competitor} Might Be Preferred
- Use case 1
- Use case 2

---

## Pricing & Licensing

### Pricing Model
- Per-user/per-month
- Tiered pricing
- Enterprise pricing

### What's Included
- Feature set per tier
- Support level
- Training/onboarding

---

## Conclusion

[Summary of key findings, recommendations for decision-making]

**Prepared By:** Claude (Anthropic AI)
**For:** {User Name}
**Source Material:** {Video URL}, {Date}
**Screenshots:** {Count} captures

**Disclaimer:** This specification is based on a demonstration video...
```

### 5.2 Writing Guidelines

**Be Comprehensive:**
- Describe each feature in detail
- Include "How It Works" step-by-step breakdowns
- Note limitations and caveats

**Be Specific:**
- Use exact terminology from the video
- Include technical details (API names, protocols, etc.)
- Cite timestamps for key claims

**Be Organized:**
- Use consistent heading hierarchy
- Group related features together
- Include a detailed table of contents

**Use Screenshots Effectively:**
- Reference screenshots for all major features
- Use descriptive captions
- Use relative paths (e.g., `screenshots/05-feature.png`)

**Compare When Relevant:**
- If user mentioned a competitor, include comparison
- Use tables for side-by-side feature comparison
- Be objective and factual

---

## Step 6: Create Task Tracking (Optional)

For complex video analysis (>30 minutes, >20 screenshots):

```javascript
TaskCreate({
  subject: "Capture comprehensive {Product} screenshots",
  description: "Navigate through video and capture screenshots of all key features...",
  activeForm: "Capturing {Product} screenshots"
})

TaskUpdate({
  taskId: "1",
  status: "in_progress"
})

// ... perform work ...

TaskUpdate({
  taskId: "1",
  status: "completed"
})
```

---

## Step 7: Quality Check

Before delivering to user:

✅ **Screenshots:**
- All screenshots saved with descriptive names
- Video player is clearly visible (not too small)
- Key UI elements are readable
- Consistent naming convention

✅ **Specification Document:**
- All major features documented
- Screenshots referenced for each section
- Technical details included (when mentioned)
- Table of contents is accurate
- Comparison section (if requested)
- Proper markdown formatting

✅ **Deliverables:**
- Spec document location: `.agent/specs/{product-name}/{product-name}-spec.md`
- Screenshot directory: `.agent/specs/{product-name}/screenshots/`
- File count matches expectations

---

## Tips & Best Practices

### Maximizing Video Player

**Always maximize the video player** before capturing screenshots:
- Small video = poor screenshot quality
- Modify page HTML to remove sidebars and maximize video
- Use viewport size of at least 1920x1080

### Timestamp Navigation

**Wait after seeking** to ensure video frame has loaded:
```javascript
video.currentTime = TARGET_TIME;
await new Promise(resolve => setTimeout(resolve, 2500)); // Wait 2.5 seconds
```

### Handling Different Video Platforms

**Loom:**
- Has transcript with clickable timestamps
- Can hide sidebar and maximize player
- Controls are at bottom

**YouTube:**
- Use theatre mode button first
- Can use fullscreen for maximum size
- Transcript available (click "Show transcript")

**Vimeo:**
- Similar to YouTube
- May require account for some videos

**Generic HTML5 Video:**
- Find video element with `document.querySelector('video')`
- Directly control currentTime property
- May need to handle custom controls

### Organizing Screenshots

**Use sequential numbering** for easy ordering:
- `00-`, `01-`, `02-` ensures correct alphabetical sort
- Include feature name for easy identification
- Include timestamp for reference back to video

### Transcript Analysis

**For Loom:** Transcript is on the right panel
**For YouTube:** Click "Show transcript" button
**For others:** May need to use auto-generated captions or manual notes

**Extract key phrases:**
- "New feature" / "One thing that's new"
- "A major differentiator"
- "Unlike [competitor]"
- "This integrates with"
- Technical terms (API names, protocols, etc.)

### Writing Clear Descriptions

**Use active voice:**
- ✅ "Click the button to generate coding"
- ❌ "Coding can be generated by clicking"

**Be specific:**
- ✅ "Uses Stedi API for real-time verification"
- ❌ "Uses an API for verification"

**Include user benefit:**
- ✅ "OCR eliminates typos in patient demographics"
- ❌ "Has OCR feature"

---

## Troubleshooting

### Video Not Loading
- Check internet connection
- Try refreshing the page
- Verify video URL is correct and accessible

### Screenshots Too Small
- Ensure you've maximized the video player
- Increase viewport size to 1920x1080
- Remove sidebars and navigation elements

### Video Controls Not Working
- Use JavaScript to directly control video element
- Set `video.currentTime` property
- Check for custom video player frameworks

### Transcript Not Available
- Fall back to manual timestamp selection
- Scrub through video every 10-15 seconds
- Focus on capturing distinct UI screens

### Too Many/Too Few Screenshots
- **Too many (>30):** Consolidate similar screens
- **Too few (<10):** May not be comprehensive enough
- **Sweet spot:** 15-25 screenshots for most products

---

## Example Output

See `.agent/specs/urgentiq/` for a complete example:
- `urgentiq-spec.md` - 22,000 word comprehensive spec
- `screenshots/` - 21 high-quality screenshots
- Covers dashboard, intake, charting, AI features, billing integration
