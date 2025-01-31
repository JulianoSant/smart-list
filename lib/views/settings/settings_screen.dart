import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/providers/auth_provider.dart' as my;

class SettingsScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<my.AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsOption(
            icon: Icons.delete,
            title: 'Excluir Conta',
            iconColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(context, authProvider),
          ),
          _buildSettingsOption(
            icon: Icons.logout,
            title: 'Sair',
            onTap: () async {
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog(BuildContext context, my.AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite sua senha para confirmar a exclusão da conta:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async => auth.deleteAccount(_passwordController.text),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
