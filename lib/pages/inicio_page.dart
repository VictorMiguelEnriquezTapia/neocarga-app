import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final TextEditingController _placaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  bool _validarPlaca(String placa) {
    final RegExp regex = RegExp(r'^[A-Z0-9]{3}-[0-9]{3}$');
    return regex.hasMatch(placa);
  }

  Future<void> _ingresar() async {
    final placa = _placaController.text.trim().toUpperCase();

    if (!_validarPlaca(placa)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato de placa inválido. Ejemplo: ABC-123'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔎 Verificar si la placa existe en Firestore
      final doc = await FirebaseFirestore.instance
          .collection('vehiculos')
          .doc(placa)
          .get();

      // 🚫 Si el widget fue desmontado antes de llegar aquí, salimos
      if (!mounted) return;

      if (doc.exists) {
        // ✅ Si existe, navega al menú
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuPage(placa: placa)),
        );
      } else {
        // ❌ Si no existe, muestra error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La placa $placa no está registrada.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // ⚠️ Evita usar context si el widget fue desmontado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al conectar con Firebase: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/fondoInicio.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.5)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/hilux.png', width: 120, height: 120),
                  const SizedBox(height: 16),
                  const Text(
                    'SISTEMA DE CONTROL DE CARGA DE MINERAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 200),

                  // 🚗 Campo de placa
                  TextField(
                    controller: _placaController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 7,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Ingrese la placa del vehículo',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      counterText: '',
                    ),
                    onChanged: (value) {
                      String input = value.toUpperCase().replaceAll(
                        RegExp(r'[^A-Z0-9]'),
                        '',
                      );
                      if (input.length > 3) {
                        input =
                            '${input.substring(0, 3)}-${input.substring(3)}';
                      }
                      if (input != _placaController.text) {
                        _placaController.value = TextEditingValue(
                          text: input,
                          selection: TextSelection.collapsed(
                            offset: input.length,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 30),

                  // 🔵 Botón ingresar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _ingresar,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.login, color: Colors.white),
                      label: Text(
                        _isLoading ? 'Verificando...' : 'Ingresar',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueAccent,
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔗 Enlaces
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Función de registro próximamente'),
                            ),
                          );
                        },
                        child: const Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Créditos del desarrollador'),
                              content: const Text(
                                'SICCMIN V 1.0\n\nDesarrollado por Victor Miguel\n© 2025 - Todos los derechos reservados.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Créditos del desarrollador',
                          style: TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
