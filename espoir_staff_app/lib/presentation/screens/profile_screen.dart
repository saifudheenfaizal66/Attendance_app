import 'package:espoir_staff_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/theme/theme_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          Container(
            height: size.height * 0.35,
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(Icons.person,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.user.email ?? 'No Email',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Settings Section
                        _buildSectionTitle("Settings"),
                        const SizedBox(height: 10),
                        _buildMenuCard(
                          children: [
                            BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, themeState) {
                                return SwitchListTile(
                                  title: const Text('Dark Mode',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  secondary: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.brightness_6_outlined,
                                        color: Color(0xFF6C63FF)),
                                  ),
                                  value: themeState.themeMode == ThemeMode.dark,
                                  activeThumbColor: const Color(0xFF6C63FF),
                                  onChanged: (value) {
                                    context
                                        .read<ThemeBloc>()
                                        .add(ThemeChanged(isDarkMode: value));
                                  },
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // General Section
                        _buildSectionTitle("General"),
                        const SizedBox(height: 10),
                        _buildMenuCard(
                          children: [
                            _buildListTile(
                              icon: Icons.logout,
                              title: 'Logout',
                              color: Colors.red,
                              textColor: Colors.red,
                              onTap: () {
                                context
                                    .read<AuthBloc>()
                                    .add(AuthLogoutRequested());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
