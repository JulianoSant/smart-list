import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/core/utils/formatters.dart';
import 'package:smart_list/core/utils/validators.dart';
import 'package:smart_list/models/contact_model.dart';
import 'package:smart_list/providers/auth_provider.dart';
import 'package:smart_list/providers/contact_provider.dart';

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
  final _addressController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cepController.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    _cepController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onCepChanged() {
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    String cep = _cepController.text.replaceAll(RegExp(r'\D'), '');

    if (cep.length == 8 && !contactProvider.isFetchingAddress) {
      contactProvider.fetchAddress(cep).then((_) {
        if (mounted) {
          _addressController.text = contactProvider.fetchedAddress;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
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
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Endereço',
                icon: Icons.home,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                enabled: !contactProvider.isFetchingAddress,
              ),
              if (contactProvider.isFetchingAddress)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                ),
              if (contactProvider.fetchedAddress.isEmpty && !contactProvider.isFetchingAddress)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Endereço será preenchido automaticamente',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSaving = true);
                          final newContact = Contact(
                            name: _nameController.text,
                            cpf: _cpfController.text,
                            phone: _phoneController.text,
                            address: _addressController.text,
                            lat: 0,
                            lng: 0,
                          );
                          await contactProvider.addContact(authProvider.currentUser!.uid, newContact);
                          // await contactProvider.getContacts(authProvider.currentUser!.uid);
                          if (mounted) {
                            // Future.delayed(const Duration(seconds: 5), () {
                            setState(() => _isSaving = false);
                            context.go('/home');
                            // });
                          }
                        }
                      },
                icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.save),
                label: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Salvar Contato'),
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
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: !enabled,
        ),
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
      ),
    );
  }
}
