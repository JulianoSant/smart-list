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
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildSearchAndSortBar(context, theme),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildContactList(contactProvider, context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactList(ContactProvider contactProvider, BuildContext context) {
    if (contactProvider.filteredContacts.isEmpty) {
      return Center(
        child: Text(
          'Nenhum contato encontrado',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: contactProvider.filteredContacts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = contactProvider.filteredContacts[index];
        return ContactCard(
          contact: contact,
          onTap: () => context.go('/home/contact/${contact.id}'),
        );
      },
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildSearchBar(context, theme)),
          const SizedBox(width: 12),
          _buildSortButton(context, theme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return TextField(
      cursorColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        hintText: 'Pesquisar contatos...',
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      onChanged: (query) => Provider.of<ContactProvider>(context, listen: false).setFilterQuery(query),
    );
  }

  Widget _buildSortButton(BuildContext context, ThemeData theme) {
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: contactProvider.currentSort,
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSecondary),
          elevation: 4,
          dropdownColor: theme.colorScheme.background,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground),
          selectedItemBuilder: (context) {
            return SortOption.values.map((option) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  option.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },
          items: SortOption.values.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color:
                      option == contactProvider.currentSort ? theme.colorScheme.secondary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: option == contactProvider.currentSort ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (option) => contactProvider.setSorting(option!),
        ),
      ),
    );
  }
}
