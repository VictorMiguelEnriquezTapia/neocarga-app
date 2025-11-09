import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class TarjetaPresentacionPage extends StatelessWidget {
  final String placa;

  const TarjetaPresentacionPage({super.key, required this.placa});

Future<void> _generarTarjetaPDF(BuildContext context) async {
  final pdf = pw.Document();
  final logo = await imageFromAssetBundle('assets/hilux.png');

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
      margin: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      build: (pw.Context context) {
        return pw.Container(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Imagen principal
              pw.Image(logo, width: 40, height: 40),
              pw.SizedBox(height: 8),

              // Línea decorativa superior
              pw.Container(
                height: 1,
                color: PdfColors.black,
                margin: const pw.EdgeInsets.symmetric(horizontal: 10),
              ),
              pw.SizedBox(height: 6),

              // Título principal
              pw.Text(
                'SERVICIO DE CARGA DE MINERAL',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),

              // Frase de presentación
              pw.Text(
                '“Seguridad, puntualidad y garantía en cada viaje”',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 8),

              // Línea separadora
              pw.Container(
                height: 1,
                color: PdfColors.black,
                margin: const pw.EdgeInsets.symmetric(horizontal: 10),
              ),
              pw.SizedBox(height: 8),

              // Unidad
              pw.Text(
                'UNIDAD: $placa',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Celular
              pw.Text(
                'Cel: 964109670',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),

              // Línea final
              pw.Container(
                height: 1,
                color: PdfColors.black,
                margin: const pw.EdgeInsets.symmetric(horizontal: 10),
              ),
              pw.SizedBox(height: 6),

              // Pie de página
              pw.Text(
                'Gracias por su preferencia',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Desactivamos la predeterminada
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Tarjeta de Presentación',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Tooltip(
          message: 'Atrás',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/hilux.png', width: 150),
              const SizedBox(height: 20),
              Text(
                'Unidad: $placa',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Generar una tarjeta de presentación para impresión térmica (58mm)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _generarTarjetaPDF(context),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  'Generar Tarjeta PDF',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}