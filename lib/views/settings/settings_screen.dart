import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/providers/auth_provider.dart' as my;

class SettingsScreen extends StatelessWidget {
  final _passwordController = TextEditingController();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my.AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Excluir Conta'),
            leading: const Icon(Icons.delete, color: Colors.red),
            onTap: () => _showDeleteAccountDialog(context, authProvider),
          ),
          ListTile(
            title: const Text('Sair'),
            leading: const Icon(Icons.logout),
            onTap: () {
              authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
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
            const Text('Digite sua senha para confirmar:'),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await auth.deleteAccount(_passwordController.text);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  context.go('/login');
                }
              } on FirebaseAuthException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_errorMessage(e))),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Senha incorreta';
      case 'requires-recent-login':
        return 'Sessão expirada. Faça login novamente';
      default:
        return 'Erro ao excluir conta: ${e.message}';
    }
  }
}
