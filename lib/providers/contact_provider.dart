import 'package:flutter/material.dart';
import 'package:smart_list/core/firebase/firestore_service.dart';
import 'package:smart_list/models/contact_model.dart';

class ContactProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Contact> _contacts = [];
  String _filterQuery = '';
  SortOption _currentSort = SortOption.nameAsc;
  SortOption get currentSort => _currentSort;

  ContactProvider(this._firestoreService);

  List<Contact> get contacts => _contacts;

  List<Contact> get filteredContacts {
    return _contacts.where((contact) {
      final query = _filterQuery.toLowerCase();
      return contact.name.toLowerCase().contains(query) || contact.cpf.contains(query);
    }).toList()
      ..sort((a, b) {
        switch (_currentSort) {
          case SortOption.nameAsc:
            return a.name.compareTo(b.name);
          case SortOption.nameDesc:
            return b.name.compareTo(a.name);
          case SortOption.cpfAsc:
            return a.cpf.compareTo(b.cpf);
        }
      });
  }

  void setFilterQuery(String query) {
    _filterQuery = query;
    notifyListeners();
  }

  void setSorting(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  void updateContacts(List<Contact> newContacts) {
    _contacts = newContacts;
    notifyListeners();
  }

  Future<List<Contact>> getContacts(String userId) {
    return _firestoreService.getContacts(userId);
  }

  Future<void> addContact(String userId, Contact contact) async {
    await _firestoreService.addContact(userId, contact);
    notifyListeners();
  }

  Future<void> deleteContact(String userId, String contactId) async {
    await _firestoreService.deleteContact(userId, contactId);
    _contacts.removeWhere((c) => c.id == contactId);
    notifyListeners();
  }
}

enum SortOption { nameAsc, nameDesc, cpfAsc }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.nameAsc:
        return 'Nome (A-Z)';
      case SortOption.nameDesc:
        return 'Nome (Z-A)';
      case SortOption.cpfAsc:
        return 'CPF';
    }
  }
}
