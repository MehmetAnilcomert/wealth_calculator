import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/inventory/view/inventory_view.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/profile_bloc.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/profile_event.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/profile_state.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/constants/enums/profile_status.dart';
import 'package:wealth_calculator/product/utility/snackbar_helper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfile()),
      child: const ProfileContent(),
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          SnackbarHelper.showError(
              context, state.errorMessage ?? 'Bir hata oluştu');
        } else if (state.status == ProfileStatus.updated) {
          SnackbarHelper.showSuccess(context, 'Profil güncellendi');
        } else if (state.status == ProfileStatus.unauthenticated) {
          // TODO: Navigate to login screen
          SnackbarHelper.showInfo(context, 'Lütfen giriş yapın');
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.loading && state.user.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, state),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoCard(context, state),
                      const SizedBox(height: 20),
                      _buildStatisticsCard(context, state),
                      const SizedBox(height: 20),
                      _buildActionButtons(context),
                      const SizedBox(height: 20),
                      _buildSettingsSection(context, state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, ProfileState state) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: state.user.profilePicture != null &&
                          state.user.profilePicture!.isNotEmpty
                      ? NetworkImage(state.user.profilePicture!)
                      : null,
                  child: state.user.profilePicture == null ||
                          state.user.profilePicture!.isEmpty
                      ? Text(
                          state.user.name.isNotEmpty
                              ? state.user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Color(0xFF3498DB),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20),
                      color: Colors.white,
                      onPressed: () {
                        // TODO: Implement image picker
                        SnackbarHelper.showInfo(
                            context, 'Profil resmi güncelleme yakında...');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, ProfileState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.user.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                  onPressed: () => _showEditProfileDialog(context, state),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.user.isPremium
                    ? const Color(0xFF3498DB)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                state.user.roleDisplayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: state.user.isPremium ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (state.user.lastLogin != null) ...[
              const SizedBox(height: 12),
              Text(
                'Son giriş: ${DateFormat('dd.MM.yyyy HH:mm').format(state.user.lastLogin!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, ProfileState state) {
    final stats = state.user.statistics ?? {};
    final totalAssets = stats['totalAssets'] as double? ?? 0.0;
    final monthlyIncome = stats['monthlyIncome'] as double? ?? 0.0;
    final monthlyExpense = stats['monthlyExpense'] as double? ?? 0.0;
    final savingsRate = stats['savingsRate'] as double? ?? 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  LocaleKeys.statistics,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ).tr(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF3498DB)),
                  onPressed: () {
                    context.read<ProfileBloc>().add(const RefreshStatistics());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatItem(
                "Toplam Varlık",
                NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
                    .format(totalAssets)),
            _buildStatItem(
                "Aylık Gelir",
                NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
                    .format(monthlyIncome)),
            _buildStatItem(
                "Aylık Gider",
                NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
                    .format(monthlyExpense)),
            _buildStatItem(
                "Tasarruf Oranı", "${(savingsRate * 100).toStringAsFixed(0)}%"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          LocaleKeys.inventory.tr(),
          Icons.inventory,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const InventoryView())),
        ),
        _buildActionButton(
          context,
          LocaleKeys.reports.tr(),
          Icons.bar_chart,
          () {
            SnackbarHelper.showInfo(context, 'Raporlar yakında...');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3498DB),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ProfileState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              LocaleKeys.settings,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ).tr(),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              LocaleKeys.editProfile.tr(),
              Icons.edit,
              () => _showEditProfileDialog(context, state),
            ),
            _buildSettingsItem(
              context,
              LocaleKeys.notifications.tr(),
              Icons.notifications,
              () => SnackbarHelper.showInfo(context, 'Bildirimler yakında...'),
            ),
            _buildSettingsItem(
              context,
              LocaleKeys.privacy.tr(),
              Icons.lock,
              () => SnackbarHelper.showInfo(context, 'Gizlilik yakında...'),
            ),
            _buildSettingsItem(
              context,
              LocaleKeys.helpAndSupport.tr(),
              Icons.help,
              () => SnackbarHelper.showInfo(context, 'Destek yakında...'),
            ),
            _buildSettingsItem(
              context,
              LocaleKeys.logout.tr(),
              Icons.exit_to_app,
              () => _showLogoutDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF3498DB),
      ),
      title: Text(
        label,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileState state) {
    final nameController = TextEditingController(text: state.user.name);
    final emailController = TextEditingController(text: state.user.email);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(LocaleKeys.editProfile).tr(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: LocaleKeys.nameSurname.tr(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: LocaleKeys.email.tr(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(LocaleKeys.cancel).tr(),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(UpdateProfile(
                    name: nameController.text,
                    email: emailController.text,
                  ));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
            ),
            child: const Text(LocaleKeys.save).tr(),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(const Logout());
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
