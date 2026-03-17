# Add CSV Export to Dashboard

## Why
Users have requested the ability to export dashboard data as CSV for offline analysis in Excel/Google Sheets. This is the #3 most requested feature in our feedback channel.

## What
Add an "Export CSV" button to the dashboard header that exports the currently visible data table as a CSV file.

## Constraints
- Only export the currently filtered/sorted view, not all data
- Maximum 10,000 rows per export (show warning if truncated)
- UTF-8 encoding with BOM for Excel compatibility
- Column headers must match the displayed column names

## Tasks

### 1. Add export button to dashboard header
- Place next to the existing "Refresh" button
- Icon: download icon from existing icon set
- Disabled state when table is empty
- **Success criteria**: Button renders, is clickable, disabled when no data

### 2. Implement CSV generation
- Use the `papaparse` library (already in dependencies)
- Handle special characters in cell values (commas, quotes, newlines)
- Include BOM for Excel UTF-8 detection
- **Success criteria**: Generated CSV opens correctly in Excel, Google Sheets, and Numbers

### 3. Implement file download
- Use browser's native download mechanism (create blob URL)
- Filename format: `dashboard-export-YYYY-MM-DD.csv`
- **Success criteria**: File downloads with correct name and content

### 4. Add row limit handling
- If filtered data exceeds 10,000 rows, show confirmation dialog
- Dialog text: "Your export will be limited to 10,000 rows. The current view has {N} rows. Continue?"
- **Success criteria**: Dialog appears at 10,001+ rows, export is truncated correctly

### 5. Add loading state
- Show spinner on button during CSV generation
- Disable button during generation to prevent double-click
- **Success criteria**: Button shows loading state, no duplicate downloads on rapid clicks

## Non-Goals
- Server-side CSV generation (client-side only for v1)
- Export as Excel (.xlsx) format
- Scheduled/automated exports
- Export of chart visualizations (tables only)

## Risks
- Large datasets may cause browser tab to freeze during generation (mitigated by 10k row limit)
- CSV format may not preserve number formatting (documented limitation)
