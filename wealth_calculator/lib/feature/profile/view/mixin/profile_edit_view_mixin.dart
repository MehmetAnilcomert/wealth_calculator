part of '../profile_edit_view.dart';

/// Mixin for profile edit view logic and UI components.
mixin _ProfileEditViewMixin on State<ProfileEditView> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  final _formKey = GlobalKey<FormState>();
  String? _selectedImagePath;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _populateFields();
      _isInitialized = true;
    }
  }

  void _populateFields() {
    final profile = context.read<UserProfileCubit>().state.profile;
    _nameController.text = profile.name;
    _surnameController.text = profile.surname;
    _selectedImagePath = profile.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  /// Handles cubit state changes for success/error feedback.
  void _onProfileStateChanged(BuildContext context, UserProfileState state) {
    if (state.status == UserProfileStatus.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.profileSaved.tr()),
          backgroundColor: context.general.colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    } else if (state.status == UserProfileStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? LocaleKeys.error.tr()),
          backgroundColor: context.general.colorScheme.error,
        ),
      );
    }
  }

  /// Shows bottom sheet to pick image from gallery or camera.
  Future<void> _pickImage(BuildContext context) async {
    final colorScheme = context.general.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const ProductPadding.allMedium(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.photoSource.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.photo_library_outlined,
                        color: colorScheme.primary),
                  ),
                  title: Text(LocaleKeys.gallery.tr()),
                  onTap: () {
                    Navigator.pop(ctx);
                    _getImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.camera_alt_outlined,
                        color: colorScheme.primary),
                  ),
                  title: Text(LocaleKeys.camera.tr()),
                  onTap: () {
                    Navigator.pop(ctx);
                    _getImage(ImageSource.camera);
                  },
                ),
                if (_selectedImagePath != null &&
                    _selectedImagePath!.isNotEmpty)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: colorScheme.error),
                    ),
                    title: Text(
                      LocaleKeys.deletePhoto.tr(),
                      style: TextStyle(color: colorScheme.error),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedImagePath = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (_) {
      // Silently handle — user canceled or permission denied
    }
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final currentImage =
          context.read<UserProfileCubit>().state.profile.imagePath;
      final isNewImage =
          _selectedImagePath != null && _selectedImagePath != currentImage;

      context.read<UserProfileCubit>().saveProfile(
            name: _nameController.text.trim(),
            surname: _surnameController.text.trim(),
            newImagePath: isNewImage ? _selectedImagePath : null,
          );
    }
  }

  void _onDelete(BuildContext context) {
    final colorScheme = context.general.colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(LocaleKeys.removeProfile.tr()),
        content: Text(LocaleKeys.removeProfileConfirm.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserProfileCubit>().deleteProfile();
            },
            child: Text(
              LocaleKeys.delete.tr(),
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── UI Builders ────────────────────────

  Widget _buildAvatarSection(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(context),
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.blackOverlay20,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _selectedImagePath != null &&
                      _selectedImagePath!.isNotEmpty
                  ? ClipOval(
                      child: Image.file(
                        File(_selectedImagePath!),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 60,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.primary,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.blackOverlay20,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const ProductPadding.allMedium(),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: LocaleKeys.name.tr(),
                hintText: LocaleKeys.enterName.tr(),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.enterName.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _surnameController,
              decoration: InputDecoration(
                labelText: LocaleKeys.surname.tr(),
                hintText: LocaleKeys.enterSurname.tr(),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.enterSurname.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : () => _onSave(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            LocaleKeys.save.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _onDelete(context),
        icon: Icon(Icons.delete_outline, color: colorScheme.error),
        label: Text(
          LocaleKeys.removeProfile.tr(),
          style: TextStyle(
            color: colorScheme.error,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.error.withAlpha(128)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
