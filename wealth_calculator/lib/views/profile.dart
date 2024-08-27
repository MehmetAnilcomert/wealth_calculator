import 'package:flutter/material.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';
import 'package:wealth_calculator/views/invoice_screen.dart';
import 'package:wealth_calculator/widgets/profile_widget.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profil',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profil Kartı
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/profile_picture.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Kullanıcı Adı",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "user@example.com",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Butonlar
                CustomNavigationButton(
                  text: "Varlık Envanteri",
                  icon: Icons.cases_outlined,
                  targetScreen: InventoryScreen(),
                  iconColor: Colors.blueGrey,
                ),
                CustomNavigationButton(
                  text: "Faturalar",
                  icon: Icons.account_balance_wallet_outlined,
                  targetScreen: InvoiceListScreen(),
                  iconColor: Colors.blueGrey,
                ),

                // Ek Buton
                CustomNavigationButton(
                  text: "Ayarlar",
                  icon: Icons.settings,
                  targetScreen: SettingsScreen(),
                  iconColor: Colors.blueGrey,
                ),
                CustomNavigationButton(
                  text: "Çıkış Yap",
                  icon: Icons.logout,
                  targetScreen: LogoutScreen(),
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ayarlar"),
      ),
      body: Center(
        child: Text("Ayarlar Ekranı"),
      ),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Çıkış Yap"),
      ),
      body: Center(
        child: Text("Çıkış Yapma Ekranı"),
      ),
    );
  }
}
