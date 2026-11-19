import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/src/pages/edit_profile_page.dart';
import 'package:flutter_application/src/pages/profile_selection_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyDrawer extends StatefulWidget {
  final ColorScheme? colors;
  final bool? isDark;
  final String uid;
  final String photoUrl;
  final String displayName;
  final String email;

  const MyDrawer({
    super.key,
    this.colors,
    this.isDark,
    required this.uid,
    required this.photoUrl,
    required this.displayName,
    required this.email,
  });

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? Theme.of(context).colorScheme;
    final isDark =
        widget.isDark ?? (Theme.of(context).brightness == Brightness.dark);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: colors.onPrimary,
                  radius: 28,
                  backgroundImage: (widget.photoUrl.isNotEmpty)
                      ? NetworkImage(widget.photoUrl)
                      : null,
                  child: (widget.photoUrl.isEmpty)
                      ? Icon(Icons.person, size: 36, color: colors.primary)
                      : null,
                ),
                const SizedBox(height: 12),
                if (widget.displayName.isNotEmpty)
                  Text(
                    widget.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (widget.email.isNotEmpty)
                  Text(
                    widget.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onPrimary.withAlpha(200),
                      fontSize: 13,
                    ),
                  ),
                if (widget.displayName.isEmpty && widget.email.isEmpty)
                  Text(
                    'Menú',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.switch_account),
            title: const Text('Elección de perfil'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSelectionPage(uid: widget.uid),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar perfil'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(uid: widget.uid),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDark ? 'Modo claro' : 'Modo oscuro'),
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            onTap: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const Divider(),
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.logout, color: colors.error),
              onPressed: () async {
                Navigator.pop(context);
                await GoogleSignIn.instance.disconnect();
                await FirebaseAuth.instance.signOut();
              },
            ),
            title: Text('Cerrar sesión', style: TextStyle(color: colors.error)),
            onTap: () async {
              Navigator.pop(context);
              await GoogleSignIn.instance.disconnect();
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
