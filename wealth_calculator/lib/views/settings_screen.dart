import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/LocalizationCubit/localization_cubit.dart';
import 'package:wealth_calculator/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            trailing: BlocBuilder<LocalizationCubit, Locale>(
              builder: (context, locale) {
                return DropdownButton<String>(
                  value: locale.languageCode,
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'tr',
                      child: Text('Türkçe'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<LocalizationCubit>().setLanguage(newValue);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
