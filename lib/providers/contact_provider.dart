import 'package:flutter/material.dart';
import 'package:smart_list/core/firebase/firestore_service.dart';
import 'package:smart_list/core/services/api_service.dart';
import 'package:smart_list/models/contact_model.dart';

class ContactProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final ApiService _apiService;

  List<Contact> _contacts = [];
  String _filterQuery = '';
  SortOption _currentSort = SortOption.nameAsc;
  bool _isFetchingAddress = false;
  String _fetchedAddress = '';

  ContactProvider(this._firestoreService, this._apiService);

  List<Contact> get contacts => _contacts;
  bool get isFetchingAddress => _isFetchingAddress;
  String get fetchedAddress => _fetchedAddress;
  SortOption get currentSort => _currentSort;

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

  Future<void> fetchAddress(String cep) async {
    final formattedCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedCep.length != 8) return;

    _isFetchingAddress = true;
    notifyListeners();

    try {
      final addressData = await _apiService.fetchAddress(formattedCep);
      _fetchedAddress = '${addressData['logradouro']}, ${addressData['bairro']}, '
          '${addressData['localidade']}-${addressData['uf']}';
    } catch (e) {
      _fetchedAddress = 'CEP inválido ou não encontrado.';
    } finally {
      _isFetchingAddress = false;
      notifyListeners();
    }
  }

  Future<void> addContact(String userId, Contact contact) async {
    final coordinates = await _apiService.getCoordinates(contact.address);

    final newContact = Contact(
      name: contact.name,
      cpf: contact.cpf,
      phone: contact.phone,
      address: contact.address,
      lat: coordinates.latitude,
      lng: coordinates.longitude,
    );

    await _firestoreService.addContact(userId, newContact);
    getContacts(userId).then(updateContacts);
    notifyListeners();
  }

  void updateContacts(List<Contact> newContacts) {
    _contacts = newContacts;
    notifyListeners();
  }

  Future<List<Contact>> getContacts(String userId) {
    return _firestoreService.getContacts(userId);
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
