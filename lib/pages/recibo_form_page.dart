import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // 👈 este es el que faltaba
import 'package:printing/printing.dart';
import 'dart:math'; // 👈 Para el Random

class ReciboFormPage extends StatefulWidget {
  final String placa;

  const ReciboFormPage({super.key, required this.placa});

  @override
  State<ReciboFormPage> createState() => _ReciboFormPageState();
}

class _ReciboFormPageState extends State<ReciboFormPage> {

  late String codigoRecibo;

  @override
  void initState() {
    super.initState();
    codigoRecibo = generarCodigoRecibo();
  }

  String generarCodigoRecibo() {
    const caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => caracteres[random.nextInt(caracteres.length)]).join();
  }

  final _formKey = GlobalKey<FormState>();

  final clienteController = TextEditingController();
  final origenController = TextEditingController();
  final destinoController = TextEditingController();
  final sacosController = TextEditingController();
  final precioController = TextEditingController();

  double total = 0;

  void calcularTotal() {
    final sacos = double.tryParse(sacosController.text) ?? 0;
    final precio = double.tryParse(precioController.text) ?? 0;
    setState(() {
      total = sacos * precio;
    });
  }

  Future<void> generarPDF() async {
  final pdf = pw.Document();
  final formatCurrency = NumberFormat('#,##0.00', 'en_US');

  // Carga el logo desde tus assets (añádelo en pubspec.yaml → assets)
  //final logo = await imageFromAssetBundle('assets/logo.png');
  final hilux = await imageFromAssetBundle('assets/hilux.png');

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity), // 58mm térmica 0 80mm
      margin: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4), //2 y 4 58mm     6 y 7 80mm
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Image(hilux, width: 160, height: 160),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'UNIDAD: ${widget.placa}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'SERVICIO DE TRANSPORTE DE CARGA DE MINERAL',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'CEL: 964109670',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'RECIBO DE SERVICIO',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Divider(thickness: 1),
            pw.Text('Cliente: ${clienteController.text}', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('Origen: ${origenController.text}', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('Destino: ${destinoController.text}', style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(width: 0.3),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('Sacos', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('P. Unit', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('Total', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(sacosController.text, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(precioController.text, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('S/ ${formatCurrency.format(total)}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'TOTAL: S/ ${formatCurrency.format(total)}',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Divider(thickness: 1),
            pw.Text(
              'Fecha: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                '¡Gracias por su preferencia!',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                    'NT-$codigoRecibo',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // para usar un botón personalizado
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1565C0), // Azul oscuro
                Color(0xFF42A5F5), // Azul claro
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Unidad: ${widget.placa}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Tooltip(
          message: 'Atrás', // 🔹 texto que aparece al pasar el mouse
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                upperCaseField(clienteController, 'Cliente:'),
                upperCaseField(origenController, 'Origen:'),
                upperCaseField(destinoController, 'Destino:'),
                TextFormField(controller: sacosController, decoration: const InputDecoration(labelText: 'Número de sacos:'), keyboardType: TextInputType.number, onChanged: (_) => calcularTotal()),
                TextFormField(controller: precioController, decoration: const InputDecoration(labelText: 'Precio por saco:'), keyboardType: TextInputType.number, onChanged: (_) => calcularTotal()),
                const SizedBox(height: 20),
                Text('TOTAL: S/ ${NumberFormat('#,##0.00', 'en_US').format(total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 🟠 Botón "Nuevo"
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            clienteController.clear();
                            origenController.clear();
                            destinoController.clear();
                            sacosController.clear();
                            precioController.clear();
                            total = 0.0;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Formulario limpio'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_box, size: 28, color: Colors.white),
                        label: const Text(
                          'Nuevo',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16), // Espacio entre botones

                    // 🟢 Botón "Generar PDF"
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            codigoRecibo = generarCodigoRecibo(); // Nuevo código cada vez
                          });
                          generarPDF();
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 28, color: Colors.white),
                        label: const Text(
                          'Generar PDF',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget upperCaseField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    onChanged: (value) {
      controller.value = TextEditingValue(
        text: value.toUpperCase(),
        selection: controller.selection,
      );
    },
  );
}