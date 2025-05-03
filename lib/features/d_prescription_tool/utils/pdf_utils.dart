import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/medicine_models.dart';
import 'dart:typed_data';

class PdfUtils {
  static Future<Uint8List> generatePrescriptionPdfBytes(
      List<SelectedMedicine> medicines) async {
    if (medicines.isEmpty) {
      throw Exception("Cannot generate PDF for empty prescription.");
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Prescription',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...medicines.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8.0),
                    child: pw.Text(
                        '${item.medicineName} - ${item.dosage}, ${item.frequency}, for ${item.duration} days.\nNotes: ${item.instructions}',
                        style: const pw.TextStyle(fontSize: 14)))),
              ]);
        },
      ),
    );
    return pdf.save();
  }

  static Future<void> printPdfBytes(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}
