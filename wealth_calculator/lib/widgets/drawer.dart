import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';
import 'package:wealth_calculator/views/invoice_screen.dart';
import 'package:wealth_calculator/views/profile.dart';
import 'package:wealth_calculator/views/temp_calculator.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
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
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child:
                        Icon(Icons.person, size: 50, color: Color(0xFF3498DB)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Kullanıcı",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "kullanıcı@gmail.com",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.all(15),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_outlined,
                      title: 'Faturalar',
                      onTap: () => _navigateTo(context, InvoiceListScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.inventory_2_outlined,
                      title: 'Envanter',
                      onTap: () => _navigateTo(context, InventoryScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.calculate_outlined,
                      title: 'Varlık Hesaplayıcı',
                      onTap: () => _navigateTo(context, CalculatorScreen()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.grey.withOpacity(0.3)),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Ayarlar',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen())),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Yardım',
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/help'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.grey.withOpacity(0.3)),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: 'Çıkış Yap',
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
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Color(0xFF3498DB),
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
