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
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final contactProvider = context.watch<ContactProvider>();

    // Busca o contato na lista, com fallback de erro
    final contact = contactProvider.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contato não encontrado'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, auth, contactProvider, contactId),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(theme, contact),
            const SizedBox(height: 16),
            Expanded(child: MapWidget(initialPosition: LatLng(contact.lat, contact.lng))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, contact) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📌 Informações do Contato', style: theme.textTheme.titleMedium),
            const Divider(),
            _buildInfoRow(Icons.badge, 'CPF:', contact.cpf, theme),
            _buildInfoRow(Icons.phone, 'Telefone:', contact.phone, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label ', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AuthProvider auth, ContactProvider contactProvider, String contactId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este contato permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await contactProvider.deleteContact(auth.currentUser!.uid, contactId);
              if (context.mounted) {
                context.go('/home');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contato excluído com sucesso!')),
                );
              }
            },
            child: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
