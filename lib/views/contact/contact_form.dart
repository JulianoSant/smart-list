import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isFetchingAddress = false;

  Future<void> _fetchAddress() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;

    setState(() => _isFetchingAddress = true);

    try {
      final addressData = await Provider.of<ApiService>(context, listen: false).fetchAddress(cep);
      setState(() {
        _address = '${addressData['logradouro']}, ${addressData['bairro']}, '
            '${addressData['localidade']}-${addressData['uf']}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CEP inválido ou não encontrado.')));
    } finally {
      setState(() => _isFetchingAddress = false);
    }
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_nameController.text} adicionado com sucesso!')),
        );
        GoRouter.of(context).go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar contato: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Contato')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nome Completo',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              _buildTextField(
                controller: _cpfController,
                label: 'CPF',
                icon: Icons.badge,
                inputFormatters: [CpfInputFormatter()],
                validator: (value) => validateCPF(value!) ? null : 'CPF inválido',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefone',
                icon: Icons.phone,
                inputFormatters: [PhoneInputFormatter()],
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _cepController,
                label: 'CEP',
                icon: Icons.location_on,
                inputFormatters: [CepInputFormatter()],
                keyboardType: TextInputType.number,
                suffixIcon: _isFetchingAddress
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _fetchAddress,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _address.isNotEmpty ? _address : 'Endereço será preenchido automaticamente',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: _address.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                    color: _address.isNotEmpty ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Contato'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
        ),
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
