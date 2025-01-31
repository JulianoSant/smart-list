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
                suffixIcon: contactProvider.isFetchingAddress
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => contactProvider.fetchAddress(_cepController.text),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  contactProvider.fetchedAddress.isNotEmpty
                      ? contactProvider.fetchedAddress
                      : 'Endereço será preenchido automaticamente',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: contactProvider.fetchedAddress.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                    color: contactProvider.fetchedAddress.isNotEmpty
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newContact = Contact(
                      name: _nameController.text,
                      cpf: _cpfController.text,
                      phone: _phoneController.text,
                      address: contactProvider.fetchedAddress,
                      lat: 0,
                      lng: 0,
                    );

                    await contactProvider.addContact(authProvider.currentUser!.uid, newContact);
                    if (context.mounted) context.go('/home');
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar Contato'),
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
