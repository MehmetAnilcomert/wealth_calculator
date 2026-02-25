import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/user_profile_cubit.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/user_profile_state.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/utility/padding/product_padding.dart';

part 'mixin/profile_edit_view_mixin.dart';

/// Screen for creating or editing user profile.
class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView>
    with _ProfileEditViewMixin {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onPrimaryContainer,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LocaleKeys.editProfile.tr(),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: _onProfileStateChanged,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const ProductPadding.allMedium(),
            child: Column(
              children: [
                _buildAvatarSection(context, colorScheme),
                const SizedBox(height: 24),
                _buildFormSection(context, colorScheme),
                if (state.hasProfile) ...[
                  const SizedBox(height: 16),
                  _buildDeleteButton(context, colorScheme),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
