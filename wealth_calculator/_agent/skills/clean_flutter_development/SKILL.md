---
name: Flutter Sustainable Development
description: Guidelines for clean architecture, dynamic UI components, localization, and professional development workflows in Flutter.
---

# Flutter Sustainable Development Skill

This skill provides a comprehensive workflow and architectural guidelines for building maintainable and scalable Flutter applications.

## 1. Architectural Patterns

### Private Widget Structure (Part/Part-of)
When building complex screens, decompose large widgets into smaller, private widgets using the `part` and `part of` directives.
- **Directory**: Place private widgets in `lib/feature/{feature_name}/view/widget/`.
- **Naming**: Use an underscore prefix for private widget classes (e.g., `_PricesAppBar`).
- **Benefit**: Keeps the main view file clean while allowing private widgets to access the main view's imports and private members without explicit export.

## 2. Dynamic UI Components
- Design widgets to be **dynamic** and **reusable**.
- Accept parameters for specific labels, colors, and data models (e.g., `WealthPrice`) to allow the same widget to represent different data types across tabs.
- Use **animations** (pulsing glows, elastic bounces) to enhance the user experience for critical data points like price changes.

### Localization (Locale Support)
Always use `easy_localization` for multilingual support.
- **Update Process**:
  1. **Duplication Check**: Before adding a new key, check if it already exists in `assets/translations/en.json` and `assets/translations/tr.json` to prevent duplication.
  2. Add new unique keys and translations to the JSON files.
  3. Run the code generation command:
     ```bash
     dart run easy_localization:generate -O lib/product/init/language -f keys -o locale_keys.g.dart --source-dir assets/translations
     ```
  4. Reference strings using `LocaleKeys.yourKey.tr()`.

## 4. Theming and Styling
- **No Hardcoded Colors**: Always pull colors from the `Theme` or custom extensions.
- **No Hardcoded Numbers (Constants)**: Avoid using literal numerical values for padding, margins, or spacing in widgets.
  - Pull padding values from `lib/product/utility/padding/product_padding.dart` (e.g., `ProductPadding.allSmall()`).
- **Custom Colors**: Use `context.general.colorScheme` or equivalent extensions to access brand-specific colors like `gold`, `dollar`, `gradientStart`, etc.

## 5. Professional Workflow (Git & Issues)

### Development Flow
1. **Issue Creation**: Open an issue describing the task with a clear title and appropriate labels (e.g., `refactor`, `feature`).
2. **Branching**: Switch to a new branch named `feature/description` or `fix/description`.
3. **Incremental Commits**: Commit after every successful step (e.g., "feat: implement dynamic top card"). Ensure the code is error-free before committing (run `flutter analyze`).
4. **Pull Request**: Open a PR with a detailed description of changes, architectural decisions, and verification steps.

### Commit Messages
Use clear and descriptive commit messages following Conventional Commits (e.g., `feat:`, `fix:`, `refactor:`).
