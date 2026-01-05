import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_calculator/feature/inventory/view/inventory_view.dart';
import 'package:wealth_calculator/feature/invoice/view/invoice_view.dart';
import 'package:wealth_calculator/feature/settings/view/settings_view.dart';
import 'package:wealth_calculator/feature/calculator/view/calculator_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF3498DB),
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
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person,
                        size: 50, color: Color(0xFF3498DB)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    LocaleKeys.profile.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
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
                      onTap: () => _navigateTo(context, InvoiceView()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.inventory_2_outlined,
                      title: LocaleKeys.inventory.tr(),
                      onTap: () => _navigateTo(context, InventoryView()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.calculate_outlined,
                      title: LocaleKeys.wealthCalculator.tr(),
                      onTap: () => _navigateTo(context, const CalculatorView()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.grey.withOpacity(0.3)),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: LocaleKeys.settings.tr(),
                      onTap: () => _navigateTo(context, SettingsView()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.grey.withOpacity(0.3)),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF3498DB),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
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
