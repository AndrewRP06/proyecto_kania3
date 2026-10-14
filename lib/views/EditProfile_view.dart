import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_kania/Dataholder.dart';
import 'package:proyecto_kania/theme/AppTheme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../ObjectsFirebase/Perfil.dart';

/// Pantalla para editar el perfil.
class Editprofileview extends StatefulWidget {
  const Editprofileview({super.key});

  @override
  State<Editprofileview> createState() => _EditprofileviewState();
}

class _EditprofileviewState extends State<Editprofileview> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();

  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool bGuardando = false;
  XFile? ficheroCargado;

  @override
  void initState() {
    super.initState();
    Perfil perfil = Dataholder.instance.perfilUsuario;
    nombreController.text = perfil.name ?? "";
    edadController.text = perfil.edad?.toString() ?? "";
    alturaController.text = perfil.altura?.toString() ?? "";
    pesoController.text = perfil.peso?.toString() ?? "";
  }

  @override
  void dispose() {
    nombreController.dispose();
    edadController.dispose();
    alturaController.dispose();
    pesoController.dispose();
    super.dispose();
  }

  String? validarNombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) return "Escribe tu nombre";
    return null;
  }

  String? validarEdad(String? valor) {
    int? edad = int.tryParse(valor?.trim() ?? "");
    if (edad == null) return "La edad debe ser un número entero";
    if (edad < 0 || edad > 150) return "Edad no válida";
    return null;
  }

  String? validarAltura(String? valor) {
    double? altura = double.tryParse((valor ?? "").trim().replaceAll(",", "."));
    if (altura == null) return "La altura debe ser un número";
    if (altura <= 0) return "Altura no válida";
    return null;
  }

  String? validarPeso(String? valor) {
    double? peso = double.tryParse((valor ?? "").trim().replaceAll(",", "."));
    if (peso == null) return "El peso debe ser un número";
    if (peso <= 0) return "Peso no válido";
    return null;
  }

  Future<void> clickGuardar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      bGuardando = true;
    });

    try {
      Perfil perfil = Dataholder.instance.perfilUsuario;

      // Try uploading image if selected
      if (ficheroCargado != null) {
        String? uploadedUrl =
            await Dataholder.instance.storageadmin.subirAvatar(ficheroCargado!);
        if (uploadedUrl != null) {
          perfil.urlAvatar = uploadedUrl;
        }
      }

      perfil.name = nombreController.text.trim();
      perfil.edad = int.parse(edadController.text.trim());
      perfil.altura =
          double.parse(alturaController.text.trim().replaceAll(",", "."));
      perfil.peso =
          double.parse(pesoController.text.trim().replaceAll(",", "."));

      User? currentUser = FirebaseAuth.instance.currentUser;
      String uid = perfil.uid ?? currentUser?.uid ?? 'temp_user';

      await db
          .collection("Perfiles")
          .doc(uid)
          .set(perfil.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 8));

      // Synchronize Dataholder singleton from Firestore
      await Dataholder.instance.loadUserData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado")),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("No se pudo guardar: $error"),
            backgroundColor: AppColores.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          bGuardando = false;
        });
      }
    }
  }

  Widget crearCabecera() {
    String email = FirebaseAuth.instance.currentUser?.email ?? "";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppEspacios.lg, AppEspacios.lg, AppEspacios.lg, AppEspacios.xl + AppEspacios.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColores.principal, AppColores.oscuro],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(AppRadios.cabecera)),
      ),
      child: Column(
        children: [
          crearAvatar(),
          const SizedBox(height: AppEspacios.sm),
          const Text("Editar perfil", style: AppTextos.tituloCabecera),
          if (email.isNotEmpty) ...[
            const SizedBox(height: AppEspacios.xs),
            Text(email,
                style: const TextStyle(color: AppColores.sobrePrincipalSuave)),
          ],
        ],
      ),
    );
  }

  Widget crearAvatar() {
    Image? avatar = Dataholder.instance.perfilUsuario.avatar;
    String? urlAvatar = Dataholder.instance.urlAvatar;
    double tamano = AppEspacios.iconoGrande + AppEspacios.xl;

    if (avatar != null) {
      return ClipOval(
        child: SizedBox(width: tamano, height: tamano, child: avatar),
      );
    } else if (urlAvatar?.isNotEmpty == true) {
      return ClipOval(
        child: SizedBox(
          width: tamano,
          height: tamano,
          child: Image.network(urlAvatar!, fit: BoxFit.cover),
        ),
      );
    } else {
      return Icon(Icons.account_circle_rounded,
          size: tamano, color: AppColores.sobrePrincipal);
    }
  }

  void elegirAvatarCamara() async {
    ImagePicker imagePicker = ImagePicker();

    ficheroCargado = await imagePicker.pickImage(source: ImageSource.camera);
    if (ficheroCargado == null) return;

    final bytes = await ficheroCargado?.readAsBytes();
    if (!mounted) return;
    setState(() {
      Dataholder.instance.perfilUsuario.avatar =
          Image.memory(bytes!, fit: BoxFit.cover);
    });
  }

  void elegirAvatarGaleria() async {
    ImagePicker imagePicker = ImagePicker();

    ficheroCargado = await imagePicker.pickImage(source: ImageSource.gallery);
    if (ficheroCargado == null) return;

    final bytes = await ficheroCargado?.readAsBytes();
    if (!mounted) return;
    setState(() {
      Dataholder.instance.perfilUsuario.avatar =
          Image.memory(bytes!, fit: BoxFit.cover);
    });
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF888888)),
      prefixIcon: Icon(icon, color: AppColores.principal),
      filled: true,
      fillColor: AppColores.cardOscuro,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColores.principal, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.oscuro,
      appBar: AppBar(
        backgroundColor: AppColores.oscuro,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "PERFIL",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppEspacios.xl),
          child: Column(
            children: [
              crearCabecera(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: AppEspacios.anchoFormulario + AppEspacios.xl),
                  child: Transform.translate(
                    offset: const Offset(0, -AppEspacios.xl),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppEspacios.md),
                      child: Card(
                        color: AppColores.cardOscuro,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFF262626)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppEspacios.lg),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: nombreController,
                                  validator: validarNombre,
                                  style: const TextStyle(color: Colors.white),
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  decoration: _buildInputDecoration(
                                      "Nombre", Icons.person_outline_rounded),
                                ),
                                const SizedBox(height: AppEspacios.md),
                                TextFormField(
                                  controller: edadController,
                                  validator: validarEdad,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: _buildInputDecoration(
                                      "Edad", Icons.cake_outlined),
                                ),
                                const SizedBox(height: AppEspacios.md),
                                TextFormField(
                                  controller: alturaController,
                                  validator: validarAltura,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  textInputAction: TextInputAction.next,
                                  decoration: _buildInputDecoration(
                                      "Altura (m)", Icons.height_rounded),
                                ),
                                const SizedBox(height: AppEspacios.md),
                                TextFormField(
                                  controller: pesoController,
                                  validator: validarPeso,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => clickGuardar(),
                                  decoration: _buildInputDecoration(
                                      "Peso (kg)", Icons.monitor_weight_outlined),
                                ),
                                const SizedBox(height: AppEspacios.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColores.principal,
                                          side: const BorderSide(color: AppColores.principal),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: elegirAvatarCamara,
                                        child: const Text("Cámara"),
                                      ),
                                    ),
                                    const SizedBox(width: AppEspacios.md),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColores.principal,
                                          side: const BorderSide(color: AppColores.principal),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: elegirAvatarGaleria,
                                        child: const Text("Galería"),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppEspacios.lg),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white70,
                                          side: const BorderSide(color: Color(0xFF444444)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: bGuardando
                                            ? null
                                            : () => Navigator.pop(context),
                                        child: const Text("Cancelar"),
                                      ),
                                    ),
                                    const SizedBox(width: AppEspacios.md),
                                    Expanded(
                                      child: FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColores.principal,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed:
                                            bGuardando ? null : clickGuardar,
                                        child: bGuardando
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: AppColores
                                                        .sobrePrincipal))
                                            : const Text("Guardar"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
