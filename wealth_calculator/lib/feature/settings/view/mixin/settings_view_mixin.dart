part of '../settings_view.dart';

/// Mixin for settings view UI components
mixin SettingsViewMixin {
  /// Build section title with icon
  Widget buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  /// Build theme settings card
  Widget buildThemeCard(
    BuildContext context,
    ProductState state,
    ColorScheme colorScheme,
  ) {
    final isDarkMode = state.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          buildThemeOption(
            context,
            LocaleKeys.theme.tr(),
            isDarkMode ? 'Koyu Tema' : 'Açık Tema',
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            colorScheme,
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<ProductViewmodel>().changeThemeMode(
                      themeMode: value ? ThemeMode.dark : ThemeMode.light,
                    );
              },
              activeColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build language selection card
  Widget buildLanguageCard(BuildContext context, ColorScheme colorScheme) {
    final currentLanguage = context.locale.languageCode;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          buildLanguageOption(
            context,
            'Türkçe',
            '🇹🇷',
            'tr',
            currentLanguage,
            colorScheme,
          ),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
          buildLanguageOption(
            context,
            'English',
            '🇬🇧',
            'en',
            currentLanguage,
            colorScheme,
          ),
        ],
      ),
    );
  }

  /// Build theme option tile
  Widget buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ColorScheme colorScheme, {
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
    );
  }

  /// Build language option tile
  Widget buildLanguageOption(
    BuildContext context,
    String language,
    String flag,
    String languageCode,
    String currentLanguage,
    ColorScheme colorScheme,
  ) {
    final isSelected = currentLanguage == languageCode;

    return InkWell(
      onTap: () {
        if (!isSelected) {
          context.read<ProductViewmodel>().changeLanguage(
                locale: Locale(languageCode),
                context: context,
              );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: colorScheme.outline,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Build app information card
  Widget buildAppInfoCard(ColorScheme colorScheme, String appVersion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.appName.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${LocaleKeys.version.tr()} $appVersion',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              LocaleKeys.appDescription.tr(),
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.brightness == Brightness.light
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
