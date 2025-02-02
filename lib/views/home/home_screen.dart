import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/models/contact_model.dart';
import 'package:smart_list/providers/auth_provider.dart';
import 'package:smart_list/providers/contact_provider.dart';
import 'package:smart_list/views/home/contact_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final contactProvider = context.read<ContactProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      drawer: _buildDrawer(context, theme),
      body: StreamBuilder<List<Contact>>(
        stream: contactProvider.getContactsStream(auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Nenhum contato encontrado',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Nenhum contato encontrado',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          contactProvider.updateContacts(snapshot.data!);
          return const ContactList();
        },
      ),
      floatingActionButton: _buildFAB(context, theme),
    );
  }
}

AppBar _buildAppBar(ThemeData theme) {
  return AppBar(
    title: const Text('Meus Contatos'),
    backgroundColor: theme.colorScheme.primary,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
  );
}

Drawer _buildDrawer(BuildContext context, ThemeData theme) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: theme.colorScheme.primary),
          child: const Text(
            'Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configurações'),
          onTap: () {
            Navigator.pop(context);
            context.go('/home/settings');
          },
        ),
      ],
    ),
  );
}

FloatingActionButton _buildFAB(BuildContext context, ThemeData theme) {
  return FloatingActionButton(
    onPressed: () => context.go('/home/new-contact'),
    backgroundColor: theme.colorScheme.secondary,
    child: const Icon(Icons.add, color: Colors.white),
  );
}
