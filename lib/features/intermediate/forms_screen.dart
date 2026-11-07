// ============================================================================
// lib/features/intermediate/forms_screen.dart — DEMO INTERMEDIA: FORMULARIOS
// ============================================================================
//
// QUÉ ENSEÑA
//   - Form + GlobalKey<FormState>: validar todos los campos a la vez.
//   - TextFormField con `validator`: mensajes de error por campo.
//   - TextEditingController: leer y modificar el texto de un campo.
//   - FocusNode / textInputAction: pasar al siguiente campo con el teclado.
//   - Tipos de teclado (email, número), contraseña oculta con botón de "ojo".
//   - DropdownButtonFormField, CheckboxListTile validado y showDatePicker.
//
// CÓMO FUNCIONA LA VALIDACIÓN
//   1. Cada TextFormField tiene un `validator: (valor) => String?`.
//      - Devuelve `null` → el campo es válido.
//      - Devuelve un texto → ese texto se muestra como error bajo el campo.
//   2. Al pulsar "Enviar", `_formKey.currentState!.validate()` ejecuta TODOS
//      los validators y devuelve true solo si todos devolvieron null.
//   3. `autovalidateMode: onUserInteraction` revalida mientras el usuario
//      escribe (después de su primera interacción).
//
// ⚠️ Los controladores y FocusNodes se crean en el State y se liberan en
//    dispose(). Si no, quedan en memoria (memory leak).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  // Llave para acceder al estado del Form (validate, save, reset).
  final _formKey = GlobalKey<FormState>();

  // Controladores: guardan el texto de cada campo.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // FocusNode: permite mover el foco (el cursor) por código.
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  String? _country;
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ VALIDADORES
  // Funciones puras: fáciles de reutilizar y de probar con tests unitarios.

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.trim().length < 2) return 'Mínimo 2 caracteres';
    return null; // null = válido
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El email es obligatorio';
    // Expresión regular sencilla: algo@algo.algo
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Email no válido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe incluir un número';
    return null;
  }

  // --------------------------------------------------------------- ACCIONES

  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    // showDatePicker devuelve la fecha elegida o null si se cancela.
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      field.didChange(picked); // informa al FormField para revalidar
    }
  }

  void _submit() {
    // Oculta el teclado.
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos marcados en rojo')),
      );
      return;
    }

    // Formulario válido: aquí normalmente llamarías a tu API.
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registro correcto ✅'),
        content: Text(
          'Nombre: ${_nameController.text.trim()}\n'
          'Email: ${_emailController.text}\n'
          'País: $_country\n'
          // MaterialLocalizations formatea la fecha en el idioma de la app.
          'Nacimiento: ${MaterialLocalizations.of(context).formatMediumDate(_birthDate!)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _reset() {
    _formKey.currentState!.reset(); // limpia errores y valores iniciales
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _country = null;
      _birthDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Formularios',
      explanation:
          'Form agrupa campos y valida todos con _formKey.currentState!'
          '.validate(). Cada campo tiene un validator que devuelve null si '
          'es válido o el mensaje de error. Pulsa "Enviar" vacío para ver '
          'los errores.',
      sourceFile: 'lib/features/intermediate/forms_screen.dart',
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              // "Siguiente" en el teclado → salta al campo de email.
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                hintText: 'tu@email.com',
              ),
              keyboardType: TextInputType.emailAddress, // teclado con @
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword, // oculta el texto (••••)
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                helperText: 'Mínimo 8 caracteres y un número',
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: const InputDecoration(
                labelText: 'País',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Venezuela', child: Text('Venezuela')),
                DropdownMenuItem(value: 'Colombia', child: Text('Colombia')),
                DropdownMenuItem(value: 'España', child: Text('España')),
                DropdownMenuItem(value: 'México', child: Text('México')),
              ],
              onChanged: (value) => setState(() => _country = value),
              validator: (value) => value == null ? 'Elige un país' : null,
            ),
            const SizedBox(height: 16),
            // FormField genérico: convierte CUALQUIER widget en un campo
            // validable (aquí, un selector de fecha).
            FormField<DateTime>(
              validator: (_) =>
                  _birthDate == null ? 'Elige tu fecha de nacimiento' : null,
              builder: (field) => InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  errorText: field.errorText,
                ),
                child: InkWell(
                  onTap: () => _pickDate(field),
                  child: Text(
                    _birthDate == null
                        ? 'Toca para elegir'
                        : MaterialLocalizations.of(context)
                              .formatFullDate(_birthDate!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FormField<bool>(
              initialValue: false,
              validator: (value) =>
                  value == true ? null : 'Debes aceptar los términos',
              builder: (field) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: field.value,
                onChanged: field.didChange,
                title: const Text('Acepto los términos y condiciones'),
                subtitle: field.hasError
                    ? Text(
                        field.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
