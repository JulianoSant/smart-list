import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text('Bem-vindo!', style: theme.textTheme.headlineLarge),
              Text('Faça login para continuar', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 30),
              _buildLoginForm(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) => value != null && value.contains('@') ? null : 'E-mail inválido',
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) => value != null && value.length >= 6 ? null : 'Mínimo 6 caracteres',
          ),
          const SizedBox(height: 20),
          _buildLoginButton(context, theme),
          TextButton(
            onPressed: () => context.go('/signup'),
            child: const Text('Criar nova conta'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, ThemeData theme) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: auth.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await auth.login(_emailController.text, _passwordController.text);
                        if (context.mounted) context.go('/home');
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    }
                  },
            child: auth.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Entrar', style: TextStyle(fontSize: 16)),
          ),
        );
      },
    );
  }
}
