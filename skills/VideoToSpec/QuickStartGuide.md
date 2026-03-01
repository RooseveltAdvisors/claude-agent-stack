# VideoToSpec - Quick Start Guide

Generate comprehensive product specifications from demo videos in minutes.

## What It Does

VideoToSpec automates the tedious process of creating detailed product documentation from demo videos. Instead of manually taking notes and screenshots, this skill:

1. **Navigates to video** (Loom, YouTube, Vimeo, or any HTML5 video)
2. **Maximizes the player** for high-quality screenshots
3. **Captures screenshots** at key timestamps showing different features
4. **Analyzes transcript** (if available) to identify features
5. **Generates comprehensive spec document** with screenshots and detailed descriptions

## When to Use

- **Competitive analysis:** Document competitor products from demo videos
- **Product research:** Create specs from vendor demonstrations
- **Feature documentation:** Turn product demos into detailed documentation
- **Reverse engineering:** Document third-party systems for integration
- **Sales engineering:** Create technical specs from sales demos

## Basic Usage

### Simple Example

```
User: "Create a spec from this Loom video: https://www.loom.com/share/..."
```

The skill will:
1. Open the video in a browser
2. Maximize the player for clear screenshots
3. Navigate through the video capturing key screens
4. Write a comprehensive spec document

### With Transcript

```
User: "Analyze this HealthApp demo and create a detailed spec: https://loom.com/share/..."

Include transcript:
[paste transcript here]
```

Providing the transcript helps identify:
- Key features mentioned by name
- Technical details (APIs, integrations, etc.)
- Timestamps where features are demonstrated

### Specify Output Location

```
User: "Create spec from this Salesforce demo video and save to .agent/specs/salesforce/"
```

By default, specs are saved to `.agent/specs/{product-name}/`

## What You Get

### 1. Screenshots Directory

```
.agent/specs/{product-name}/screenshots/
├── 00-dashboard-overview-15min.png
├── 01-patient-list-17min.png
├── 05-insurance-verification-32min.png
├── 14-ai-coding-42min.png
└── ... (15-25 screenshots total)
```

**Screenshot Naming:**
- Sequential numbering (00, 01, 02...)
- Descriptive feature name
- Timestamp in video (for reference)

### 2. Comprehensive Spec Document

```
.agent/specs/{product-name}/{product-name}-spec.md
```

**Includes:**
- **Executive summary** with key differentiators
- **System overview** with architecture
- **Feature-by-feature documentation** with screenshots
- **Technical architecture** (deployment, integrations, APIs)
- **Comparison with competitors** (if mentioned)
- **Pricing & licensing** information
- **Table of contents** with navigation

**Typical length:** 10,000-25,000 words for comprehensive coverage

## Advanced Usage

### Multiple Videos (Comparison)

```
User: "Create specs for HealthApp and EHRSystem, then compare them"

Video 1: https://loom.com/share/urgentiq-demo
Video 2: https://loom.com/share/nextgen-demo
```

The skill will:
1. Generate spec for each product
2. Create comparison matrix showing feature differences
3. Identify which product is better for specific use cases

### Custom Timestamps

```
User: "Create spec from this video, focusing on these sections:
- 0:15-0:25: Dashboard
- 1:30-2:00: Patient intake
- 5:00-6:30: Billing workflow
```

The skill will prioritize capturing screenshots from specified time ranges.

### Focus on Specific Features

```
User: "Analyze this Stripe video and create a spec focused on:
- Payment processing workflow
- API integration capabilities
- Webhook configuration
- Dashboard analytics"
```

The skill will emphasize requested features in the spec.

## Pro Tips

### Get Better Results

1. **Provide the transcript** if available
   - Helps identify feature names and technical details
   - Speeds up screenshot capture (knows where features are shown)

2. **Specify comparison targets**
   - "Compare with Competitor X" ensures comparison section
   - Helps highlight differentiators

3. **Mention specific use cases**
   - "For urgent care clinics" tailors analysis to your needs
   - "For enterprise vs. SMB" identifies scalability factors

4. **Request specific sections**
   - "Include detailed pricing analysis"
   - "Focus on integration capabilities"
   - "Document security/compliance features"

### Video Platform Tips

**Loom:**
- Best platform for this skill (has built-in transcript with timestamps)
- Maximize by hiding sidebar
- High-quality screenshots possible

**YouTube:**
- Enable transcript ("Show transcript" button)
- Use theatre mode or fullscreen
- May have ads (skill can skip)

**Vimeo:**
- Similar to YouTube
- Some videos require account (provide credentials if needed)

**Other platforms:**
- Works with any HTML5 video player
- May require manual timestamp selection if no transcript

## Troubleshooting

### "Video player is too small"

The skill automatically maximizes the player, but if screenshots are still small:
```
User: "The video player needs to be bigger - can you make it fullscreen?"
```

### "Missed important features"

Provide more guidance:
```
User: "You missed the reporting section around 15:30. Please add screenshots from 15:00-16:00"
```

### "Spec is too high-level"

Request more detail:
```
User: "Make the spec more technical - include API endpoints, data models, and integration details"
```

### "Too many screenshots"

Request consolidation:
```
User: "Consolidate to top 10 most important screens"
```

## Example Output

See the HealthApp spec created in this session:

**Location:** `.agent/specs/urgentiq/`

**Contents:**
- `urgentiq-spec.md` - 22,000 word specification
- `screenshots/` - 21 high-quality screenshots

**Coverage:**
- Executive summary with key differentiators
- Dashboard and patient flow management
- Patient registration with OCR
- Insurance verification (real-time via Stedi)
- Clinical charting workflows
- AI features (coding, discharge instructions, patient summaries)
- Work comp & occupational medicine
- Payment collection
- Advanced MD billing integration
- Telehealth capabilities
- Technical architecture
- Detailed comparison with EHRSystem
- Pricing and licensing

## Customization

### For Your Use Case

The skill is designed to be flexible. You can customize output by:

**Specifying format:**
```
User: "Create spec in our standard template format with sections:
1. Overview
2. Architecture
3. Features
4. Security & Compliance
5. Deployment Options"
```

**Changing depth:**
```
User: "Create a high-level overview (5-10 pages) instead of comprehensive spec"
```

**Focusing on integration:**
```
User: "Focus the spec on API capabilities and integration architecture"
```

## Best Practices

### Before You Start

1. ✅ **Have video URL ready**
2. ✅ **Copy transcript** if available (Loom/YouTube)
3. ✅ **Identify competitor** for comparison (if applicable)
4. ✅ **Know your use case** (helps tailor analysis)

### During Analysis

1. ✅ **Let the skill work systematically** (don't rush)
2. ✅ **Review interim screenshots** to ensure quality
3. ✅ **Provide feedback** if direction needs adjustment

### After Completion

1. ✅ **Review the spec** for accuracy
2. ✅ **Request additions** for missed features
3. ✅ **Refine comparison** section if needed
4. ✅ **Save to your documentation** repository

## FAQ

**Q: How long does it take?**
A: 5-10 minutes for a 30-minute video (15-20 screenshots + spec generation)

**Q: What video platforms are supported?**
A: Loom (best), YouTube, Vimeo, and any HTML5 video. Custom platforms may work with adjustments.

**Q: Can I use this for non-product videos?**
A: Yes! Works for any tutorial, demo, or walkthrough video where you need documentation.

**Q: Will it work for very long videos (2+ hours)?**
A: Yes, but consider breaking into sections:
```
User: "Create spec for first hour (dashboard features) and second hour (advanced features) separately"
```

**Q: Can I edit the spec after generation?**
A: Absolutely! The spec is a markdown file you can edit normally. Request revisions or edit manually.

**Q: Does it work for mobile app demos?**
A: Yes, if the demo shows a screen recording. Screenshots will capture the mobile UI.

**Q: Can I use my own screenshot timestamps?**
A: Yes! Provide a list of timestamps and the skill will capture at those specific times.

## Support

For issues or questions about VideoToSpec:

1. **Check this guide** for common solutions
2. **Try rephrasing** your request with more specifics
3. **Provide feedback** on what's not working
4. **Ask for adjustments** to the output

The skill learns from your feedback and improves with each use!

---

**Created:** February 2026
**Version:** 1.0
**Author:** Claude (Anthropic AI)
