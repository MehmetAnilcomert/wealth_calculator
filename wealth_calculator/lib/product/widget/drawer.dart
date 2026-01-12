import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_calculator/feature/inventory/view/inventory_view.dart';
import 'package:wealth_calculator/feature/invoice/view/invoice_view.dart';
import 'package:wealth_calculator/feature/settings/view/settings_view.dart';
import 'package:wealth_calculator/feature/calculator/view/calculator_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.gradientStart,
              colorScheme.gradientEnd,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20, bottom: 20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.blackOverlay20,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(Icons.person,
                        size: 50, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    LocaleKeys.profile.tr(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_outlined,
                      title: LocaleKeys.invoice.tr(),
                      onTap: () => _navigateTo(context, const InvoiceView()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.inventory_2_outlined,
                      title: LocaleKeys.inventory.tr(),
                      onTap: () => _navigateTo(context, const InventoryView()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.calculate_outlined,
                      title: LocaleKeys.wealthCalculator.tr(),
                      onTap: () => _navigateTo(context, const CalculatorView()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: colorScheme.outline),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: LocaleKeys.settings.tr(),
                      onTap: () => _navigateTo(context, const SettingsView()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: colorScheme.blackOverlay30),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: LocaleKeys.logout.tr(),
                      isDestructive: true,
                      onTap: () => SystemNavigator.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = context.general.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.blackOverlay10,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? colorScheme.error.withAlpha(26)
                : colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? colorScheme.error : colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? colorScheme.error : colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color:
              isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
