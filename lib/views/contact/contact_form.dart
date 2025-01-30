import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/core/utils/formatters.dart';
import 'package:smart_list/core/utils/validators.dart';
import 'package:smart_list/models/contact_model.dart';
import 'package:smart_list/providers/auth_provider.dart';
import 'package:smart_list/providers/contact_provider.dart';
import 'package:smart_list/core/services/api_service.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  String _address = '';
  LatLng? _coordinates;

  Future<void> _fetchAddress() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;

    final addressData = await Provider.of<ApiService>(context, listen: false).fetchAddress(cep);

    setState(() {
      _address = '${addressData['logradouro']}, ${addressData['bairro']}, '
          '${addressData['localidade']}-${addressData['uf']}';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final coordinates = await apiService.getCoordinates(_address);

      final newContact = Contact(
        name: _nameController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
        address: _address,
        lat: coordinates.latitude,
        lng: coordinates.longitude,
      );

      await contactProvider.addContact(authProvider.currentUser!.uid, newContact);

      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Contato')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                inputFormatters: [CpfInputFormatter()],
                validator: (value) => validateCPF(value!) ? null : 'CPF inválido',
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                inputFormatters: [PhoneInputFormatter()],
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _fetchAddress,
                  ),
                ),
                inputFormatters: [CepInputFormatter()],
                onFieldSubmitted: (_) => _fetchAddress(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_address, style: Theme.of(context).textTheme.bodyMedium),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Salvar Contato'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
