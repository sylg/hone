# Add Dark Mode Toggle

## Original Request
Users want a dark mode toggle in the settings page.

## Tasks

### 1. Add toggle to settings
Add a "Dark Mode" toggle switch to the appearance section of the settings page.

### 2. Implement theme system
Create a comprehensive theming system with CSS variables for all colors, spacing, and typography. Support light, dark, and system-preference modes.

### 3. Design token migration
Migrate all existing hard-coded colors across the entire application to use the new design token system. Audit every component for color usage.

### 4. Create theme editor
Build a theme editor page where users can customize individual colors for their personal theme. Include a color picker, preview panel, and reset button.

### 5. Add theme sharing
Allow users to export their custom theme as a JSON file and import themes from other users. Add a "Theme Gallery" page where users can browse community themes.

### 6. Persist preference
Save the user's theme preference in their profile settings. Apply the theme on page load before render to prevent flash of wrong theme.

### 7. Update component library
Add dark mode variants to all 47 components in our component library. Update Storybook to show both light and dark variants side by side.

## Success Criteria
- Users can toggle between light and dark mode
- Custom themes can be created and shared
- All components support theming
