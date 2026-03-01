---
model: opus
description: Parallel user story validation — discovers YAML stories, fans out bowser-qa-agents, aggregates results
argument-hint: [headed] [filename-filter] [vision]
---

# Purpose

Discover user stories from YAML files, fan out parallel `bowser-qa-agent` instances to validate each story, then aggregate and report pass/fail results with screenshots.

## Variables

HEADED: $1 (default: "false" — set to "true" or "headed" for visible browser windows)
VISION: detected from $ARGUMENTS — if the keyword "vision" appears, enable vision mode. Default: false.
FILENAME_FILTER: remaining non-keyword arguments after removing "vision"
STORIES_DIR: "ai_review/user_stories"
STORIES_GLOB: "ai_review/user_stories/*.yaml"
AGENT_TIMEOUT: 300000
SCREENSHOTS_BASE: "screenshots/bowser-qa"
RUN_DIR: "{SCREENSHOTS_BASE}/{YYYYMMDD_HHMMSS}_{short-uuid}" (generated once at start of run)

## Codebase Structure

```
ai_review/
└── user_stories/
    ├── hackernews.yaml    # Sample HN stories
    └── *.yaml             # Additional story files
screenshots/
└── bowser-qa/
    └── 20260228_143022_a1b2c3/     # Run directory (datetime + short uuid)
        ├── hackernews/
        │   ├── front-page-loads-with-posts/
        │   └── view-top-post-comments/
        └── my-app/
            └── login-flow/
```

## Instructions

- Use TeamCreate to create a team, then spawn one `bowser-qa-agent` teammate per story via the Task tool
- Launch ALL teammates in a single message so they run in parallel
- If FILENAME_FILTER is provided, only run stories from files whose name contains that substring
- If a YAML file fails to parse, log a warning and skip it
- The `subagent_type` for each Task call must be `bowser-qa-agent`

## Workflow

### Phase 1: Discover

1. Use the Glob tool to find all files matching `STORIES_GLOB`
2. Apply FILENAME_FILTER if provided
3. Read each YAML file and parse the `stories` array
4. Generate `RUN_DIR`:
   ```bash
   RUN_DIR="screenshots/bowser-qa/$(date +%Y%m%d_%H%M%S)_$(uuidgen | tr '[:upper:]' '[:lower:]' | head -c 6)"
   ```
5. For each story, build `SCREENSHOT_PATH = "{RUN_DIR}/{file-stem}/{slugified-name}/"`

### Phase 2: Spawn

6. Use TeamCreate to create a team named `ui-review`
7. Use TaskCreate to create one task per story
8. Spawn a `bowser-qa-agent` per story with this prompt:

```
Execute this user story and report results:

**Story:** {story.name}
**URL:** {story.url}
**Headed:** {HEADED}
**Vision:** {VISION}

**Workflow:**
{story.workflow}

Instructions:
- Follow each step sequentially
- Take a screenshot after each significant step
- Save ALL screenshots to: {SCREENSHOT_PATH}
- Report each step as PASS or FAIL
- Final summary line: RESULT: {PASS|FAIL} | Steps: {passed}/{total}
```

### Phase 3: Collect

9. Wait for all teammate reports
10. Parse each report for RESULT line and Steps count
11. Mark tasks completed via TaskUpdate

### Phase 4: Cleanup and Report

12. Send shutdown requests to all teammates
13. Call TeamDelete to clean up
14. Present the aggregated results:

```
# UI Review Summary

**Run:** {current date and time}
**Stories:** {total} total | {passed} passed | {failed} failed
**Status:** ✅ ALL PASSED | ❌ PARTIAL FAILURE | ❌ ALL FAILED

## Results

| #   | Story        | Source File | Status | Steps            |
| --- | ------------ | ----------- | ------ | ---------------- |
| 1   | {story name} | {filename}  | ✅ PASS | {passed}/{total} |
| 2   | {story name} | {filename}  | ❌ FAIL | {passed}/{total} |

## Failures

### Story: {failed story name}
**Source:** {filename}
**Agent Report:**
{full agent report}

## Screenshots
All screenshots saved to: `{RUN_DIR}/`
```
