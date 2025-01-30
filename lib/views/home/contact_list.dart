import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/providers/contact_provider.dart';
import 'package:smart_list/widgets/contact_card.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) {
    final contactProvider = context.watch<ContactProvider>();

    return Column(
      children: [
        _buildSearchBar(context),
        _buildSortButton(context),
        Expanded(
          child: ListView.separated(
            itemCount: contactProvider.filteredContacts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => ContactCard(
              contact: contactProvider.filteredContacts[index],
              onTap: () => context.go('/home/contact/${contactProvider.filteredContacts[index].id}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Pesquisar por nome ou CPF...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (query) => Provider.of<ContactProvider>(context, listen: false).setFilterQuery(query),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);

    return DropdownButton<SortOption>(
      value: contactProvider.currentSort,
      items: SortOption.values.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: (option) => contactProvider.setSorting(option!),
    );
  }
}
