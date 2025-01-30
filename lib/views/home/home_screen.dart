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
    final contactProvider = context.watch<ContactProvider>();

    return StreamBuilder<List<Contact>>(
      stream: contactProvider.getContactsStream(auth.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            contactProvider.updateContacts(snapshot.data!);
          });

          return Scaffold(
            appBar: AppBar(title: const Text('Meus Contatos')),
            body: const ContactList(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.go('/home/new-contact'),
              child: const Icon(Icons.add),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
