import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/providers/auth_provider.dart';
import 'package:smart_list/providers/contact_provider.dart';
import 'package:smart_list/widgets/map_widget.dart';

class ContactDetailsScreen extends StatelessWidget {
  final String contactId;

  const ContactDetailsScreen({
    super.key,
    required this.contactId,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final contact = context.watch<ContactProvider>().contacts.firstWhere((c) => c.id == contactId);

    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await context.read<ContactProvider>().deleteContact(
                    auth.currentUser!.uid,
                    contactId,
                  );
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('CPF: ${contact.cpf}'),
            subtitle: Text('Telefone: ${contact.phone}'),
          ),
          Expanded(
            child: MapWidget(
              initialPosition: LatLng(contact.lat, contact.lng),
            ),
          ),
        ],
      ),
    );
  }
}
