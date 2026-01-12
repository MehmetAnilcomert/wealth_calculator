import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings.tr()),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(LocaleKeys.language.tr()),
            trailing: DropdownButton<String>(
              value: context.locale.languageCode,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: const Text(LocaleKeys.english).tr(),
                ),
                DropdownMenuItem(
                  value: 'tr',
                  child: const Text(LocaleKeys.turkish).tr(),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<ProductViewmodel>().changeLanguage(
                        locale: Locale(newValue),
                        context: context,
                      );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
