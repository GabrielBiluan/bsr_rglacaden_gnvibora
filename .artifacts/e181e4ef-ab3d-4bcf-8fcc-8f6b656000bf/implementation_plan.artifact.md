# UI Polish & Barangay Palette Implementation Plan

Improve the app's visual appeal and shift the color palette to a civic, community-oriented **Teal / Emerald Green** theme suitable for a Barangay Service Request application.

## Proposed Changes

### Theme & Palette
- **[MODIFY] [main.dart](file:///C:/Users/USER/StudioProjects/bsr_rglacaden_gnvibora/lib/main.dart)**: Update Material 3 seed color to `Colors.teal` (representing civic public service and community harmony).

### Screens & Components
#### [MODIFY] [auth_screen.dart](file:///C:/Users/USER/StudioProjects/bsr_rglacaden_gnvibora/lib/auth_screen.dart)
- Update branding icon to `Icons.account_balance` (government/barangay hall representation).
- Apply teal/emerald buttons and styling.

#### [MODIFY] [home_screen.dart](file:///C:/Users/USER/StudioProjects/bsr_rglacaden_gnvibora/lib/home_screen.dart)
- Polish request cards in ListView and GridView with status badge indicators (e.g., Pending status in amber).
- Improve typography, card padding, and empty states.

#### [MODIFY] [request_dialog.dart](file:///C:/Users/USER/StudioProjects/bsr_rglacaden_gnvibora/lib/request_dialog.dart)
- Refine form padding, dropdown styling, and action buttons.

## Verification Plan

### Automated Tests
- Run code analysis on all modified files to ensure zero syntax or type errors.
