import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../theme/admin_colors.dart';

class ManageUserScreen extends StatelessWidget {
  const ManageUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Users'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AdminColors.textDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Firestore Error:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.danger),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 14),
                  const Text(
                    'Tidak Ada Pengguna',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textDark,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>? ?? {};

              return _UserCardItem(userId: userDoc.id, userData: userData);
            },
          );
        },
      ),
    );
  }
}

class _UserCardItem extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const _UserCardItem({required this.userId, required this.userData});

  @override
  State<_UserCardItem> createState() => _UserCardItemState();
}

class _UserCardItemState extends State<_UserCardItem> {
  bool isExpanded = false;
  List<Map<String, dynamic>>? userTickets;
  bool isLoadingTickets = false;

  Future<void> _fetchTickets() async {
    if (userTickets != null) {
      setState(() => isExpanded = !isExpanded);
      return;
    }

    setState(() {
      isLoadingTickets = true;
      isExpanded = true;
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (mounted) {
        setState(() {
          userTickets = snap.docs.map((d) => d.data()).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching tickets for user ${widget.userId}: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingTickets = false);
      }
    }
  }

  Future<void> _toggleRole(String currentRole) async {
    final nextRole = (currentRole == 'super_admin' || currentRole == 'admin') ? 'user' : 'super_admin';

    final currentUser = FirebaseAuth.instance.currentUser;
    if (widget.userId == currentUser?.uid && nextRole == 'user') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.danger,
          content: Text('Anda tidak dapat menurunkan hak akses akun Anda sendiri demi keamanan.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Role Pengguna?'),
        content: Text('Apakah Anda yakin ingin mengubah role akun ini menjadi "$nextRole"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ubah Role', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'role': nextRole,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.success,
              content: Text('Role berhasil diubah menjadi $nextRole'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.danger,
              content: Text('Gagal mengubah role: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = widget.userData['role']?.toString() ?? 'user';
    final name = widget.userData['fullName']?.toString() ?? 'User';
    final email = widget.userData['email']?.toString() ?? '-';
    final country = widget.userData['country']?.toString() ?? '-';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// USER INFO
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : AdminColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Asal: $country',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleRole(role),
                child: _roleBadge(role),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: AppTheme.border(isDark)),

          /// TICKET ACCORDION
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _fetchTickets,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userTickets != null
                        ? 'Tiket Dipesan (${userTickets!.length})'
                        : 'Lihat Tiket Pengguna',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 4),
            if (isLoadingTickets)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  ),
                ),
              )
            else if (userTickets == null || userTickets!.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada tiket yang dipesan.',
                  style: TextStyle(color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey, fontSize: 12),
                ),
              )
            else
              ...userTickets!.map((data) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border(isDark)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title']?.toString() ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${data['date'] ?? ''} • ${data['time'] ?? ''}',
                              style: const TextStyle(fontSize: 11, color: AdminColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    final isAdmin = role == 'super_admin' || role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isAdmin ? AppTheme.accentBlue.withValues(alpha: 0.12) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.shield_rounded : Icons.person_rounded,
            size: 13,
            color: isAdmin ? AppTheme.accentBlue : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? 'SUPER ADMIN' : 'USER',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isAdmin ? AppTheme.accentBlue : Colors.grey.shade700,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
