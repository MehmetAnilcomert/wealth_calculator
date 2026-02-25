import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_viewmodel.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_state.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/feature/profile/view/profile_edit_view.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/user_profile_cubit.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/user_profile_state.dart';
import 'dart:io';

part 'mixin/settings_view_mixin.dart';

class SettingsView extends StatelessWidget with SettingsViewMixin {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.transparent,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: colorScheme.onPrimaryContainer),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LocaleKeys.settings.tr(),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<ProductViewmodel, ProductState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                buildSectionTitle(
                  context,
                  LocaleKeys.profileInfo.tr(),
                  Icons.person_outlined,
                  colorScheme,
                ),
                const SizedBox(height: 12),
                buildProfileCard(context, colorScheme),
                const SizedBox(height: 24),

                // Appearance Section
                buildSectionTitle(
                  context,
                  LocaleKeys.theme.tr(),
                  Icons.palette_outlined,
                  colorScheme,
                ),
                const SizedBox(height: 12),
                buildThemeCard(context, state, colorScheme),
                const SizedBox(height: 24),

                // Language Section
                buildSectionTitle(
                  context,
                  LocaleKeys.language.tr(),
                  Icons.language_outlined,
                  colorScheme,
                ),
                const SizedBox(height: 12),
                buildLanguageCard(context, colorScheme),
                const SizedBox(height: 24),

                // App Info Section
                buildSectionTitle(
                  context,
                  LocaleKeys.appInfo.tr(),
                  Icons.info_outline,
                  colorScheme,
                ),
                const SizedBox(height: 12),
                buildAppInfoCard(colorScheme, "1.0.0"),
              ],
            ),
          );
        },
      ),
    );
  }
}
