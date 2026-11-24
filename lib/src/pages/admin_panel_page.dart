import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/models/app_user.dart';
import 'package:flutter_application/src/services/auth_service.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Administración'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Pendientes'),
              Tab(icon: Icon(Icons.group), text: 'Todos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsersListTab(pendingOnly: true),
            _UsersListTab(pendingOnly: false),
          ],
        ),
      ),
    );
  }
}

class _UsersListTab extends StatelessWidget {
  final bool pendingOnly;
  const _UsersListTab({required this.pendingOnly});

  @override
  Widget build(BuildContext context) {
    final stream = pendingOnly
        ? AuthService.instance.streamPendingUsers()
        : AuthService.instance.streamAllUsers();

    return StreamBuilder<List<AppUser>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error al cargar usuarios: ${snap.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final users = snap.data ?? const [];
        if (users.isEmpty) {
          return Center(
            child: Text(
              pendingOnly
                  ? 'No hay usuarios pendientes de aprobación.'
                  : 'No hay usuarios registrados.',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _UserAdminCard(user: users[i]),
        );
      },
    );
  }
}

class _UserAdminCard extends StatelessWidget {
  final AppUser user;
  const _UserAdminCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isSelf = user.uid == currentUid;

    final statusColor = switch (user.status) {
      UserStatus.approved => Colors.green,
      UserStatus.rejected => colors.error,
      UserStatus.pending => Colors.orange,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName.isNotEmpty
                            ? user.displayName
                            : user.email,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (user.displayName.isNotEmpty)
                        Text(
                          user.email,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _Badge(
                            label: user.status.name.toUpperCase(),
                            color: statusColor,
                          ),
                          _Badge(
                            label: user.role.name.toUpperCase(),
                            color: user.isAdmin
                                ? colors.primary
                                : colors.secondary,
                          ),
                          if (user.providers.isNotEmpty)
                            _Badge(
                              label: user.providers.join(' + '),
                              color: colors.tertiary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isSelf) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (!user.isApproved)
                    FilledButton.icon(
                      onPressed: () => AuthService.instance.approveUser(
                        targetUid: user.uid,
                        adminUid: currentUid,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aprobar'),
                    ),
                  if (!user.isRejected)
                    OutlinedButton.icon(
                      onPressed: () => AuthService.instance.rejectUser(
                        targetUid: user.uid,
                        adminUid: currentUid,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                      ),
                      icon: const Icon(Icons.block, size: 18),
                      label: Text(
                        user.isApproved ? 'Revocar acceso' : 'Rechazar',
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => AuthService.instance.setUserRole(
                      targetUid: user.uid,
                      role: user.isAdmin ? UserRole.user : UserRole.admin,
                    ),
                    icon: const Icon(Icons.admin_panel_settings, size: 18),
                    label: Text(
                      user.isAdmin ? 'Quitar admin' : 'Hacer admin',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
