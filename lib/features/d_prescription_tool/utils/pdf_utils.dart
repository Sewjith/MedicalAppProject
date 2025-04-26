import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/medicine_models.dart';

class PdfUtils {
  static Future<void> printPrescription(
      List<SelectedMedicine> medicines) async {
    if (medicines.isEmpty) return; // Don't print if empty

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
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
