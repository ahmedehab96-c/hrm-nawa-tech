import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:hrm_saas/features/employee/payslip/data/payroll_repository.dart';

/// بيانات القسيمة الكاملة لتوليد الـ PDF
class PayslipPdfData {
  const PayslipPdfData({
    required this.employeeName,
    required this.department,
    required this.position,
    required this.month,
    required this.companyName,
    required this.baseSalary,
    required this.allowances,
    required this.deductions,
    required this.netSalary,
    this.status,
  });

  final String employeeName;
  final String department;
  final String position;
  final String month;
  final String companyName;
  final String baseSalary;
  final String allowances;
  final String deductions;
  final String netSalary;
  final String? status;

  factory PayslipPdfData.fromSlip(
    PayslipItem slip, {
    String department = '',
    String position = '',
    String companyName = 'Nawa Tech HRM',
    String month = '',
  }) =>
      PayslipPdfData(
        employeeName: slip.employeeName,
        department: department,
        position: position,
        month: month,
        companyName: companyName,
        baseSalary: slip.baseSalary,
        allowances: slip.allowances,
        deductions: slip.deductions,
        netSalary: slip.netSalary,
        status: slip.status,
      );
}

class PayslipPdfService {
  PayslipPdfService._();

  /// يفتح واجهة المشاركة/الطباعة الأصلية للمنصة
  static Future<void> sharePayslip(PayslipPdfData data) async {
    final bytes = await _buildPdf(data);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'payslip_${data.month.replaceAll('-', '_')}.pdf',
    );
  }

  /// يعرض معاينة داخل الشاشة قبل الطباعة أو الحفظ
  static Future<void> previewPayslip(PayslipPdfData data) async {
    await Printing.layoutPdf(
      onLayout: (_) => _buildPdf(data),
      name: 'payslip_${data.month.replaceAll('-', '_')}.pdf',
    );
  }

  // ─── PDF builder ──────────────────────────────────────────────────────────

  static Future<Uint8List> _buildPdf(PayslipPdfData d) async {
    final doc = pw.Document();

    const primaryColor  = PdfColor.fromInt(0xFF1565C0);
    const successColor  = PdfColor.fromInt(0xFF2E7D32);
    const errorColor    = PdfColor.fromInt(0xFFB71C1C);
    const bgLight       = PdfColor.fromInt(0xFFF5F5F5);
    const dividerColor  = PdfColor.fromInt(0xFFE0E0E0);
    const captionColor  = PdfColor.fromInt(0xFF757575);

    final regular = await PdfGoogleFonts.cairoRegular();
    final bold    = await PdfGoogleFonts.cairoBold();

    final base    = pw.TextStyle(font: regular, fontSize: 11);
    final bld     = pw.TextStyle(font: bold, fontSize: 11);
    final caption = pw.TextStyle(font: regular, fontSize: 9, color: captionColor);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [

            // ── Header ───────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(d.companyName,
                          style: pw.TextStyle(
                              font: bold, fontSize: 18, color: PdfColors.white)),
                      pw.SizedBox(height: 4),
                      pw.Text('قسيمة الراتب',
                          style: pw.TextStyle(
                              font: regular, fontSize: 12, color: const PdfColor(1, 1, 1, 0.7))),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(d.month,
                          style: pw.TextStyle(
                              font: bold, fontSize: 16, color: PdfColors.white)),
                      if (d.status != null)
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 4),
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: pw.BoxDecoration(
                            color: const PdfColor(1, 1, 1, 0.24),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(d.status!,
                              style: pw.TextStyle(
                                  font: regular, fontSize: 9, color: PdfColors.white)),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ── Employee Info ─────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: bgLight,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('معلومات الموظف',
                      style: pw.TextStyle(
                          font: bold, fontSize: 13, color: primaryColor)),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    children: [
                      _chip('الاسم', d.employeeName, bold, regular, captionColor),
                      if (d.department.isNotEmpty) ...[
                        pw.SizedBox(width: 20),
                        _chip('القسم', d.department, bold, regular, captionColor),
                      ],
                      if (d.position.isNotEmpty) ...[
                        pw.SizedBox(width: 20),
                        _chip('المنصب', d.position, bold, regular, captionColor),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ── Earnings ─────────────────────────────────────────────
            _sectionTitle('المستحقات', bold, primaryColor),
            pw.SizedBox(height: 8),
            _row('الراتب الأساسي', _fmt(d.baseSalary), base, bld, dividerColor),
            _row('البدلات',        _fmt(d.allowances),  base, bld, dividerColor),

            pw.SizedBox(height: 12),

            // ── Deductions ────────────────────────────────────────────
            _sectionTitle('الخصومات', bold, errorColor),
            pw.SizedBox(height: 8),
            _row('إجمالي الخصومات', _fmt(d.deductions), base, bld, dividerColor,
                valueColor: errorColor),

            pw.SizedBox(height: 20),

            // ── Net Pay ───────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFE8F5E9),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: successColor),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('صافي الراتب',
                      style: pw.TextStyle(
                          font: bold, fontSize: 14, color: successColor)),
                  pw.Text(_fmt(d.netSalary),
                      style: pw.TextStyle(
                          font: bold, fontSize: 18, color: successColor)),
                ],
              ),
            ),

            pw.Spacer(),

            // ── Footer ────────────────────────────────────────────────
            pw.Divider(color: dividerColor),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('وثيقة رسمية — ${d.companyName}', style: caption),
                pw.Text('Nawa Tech HRM', style: caption),
              ],
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  // ─── Widget helpers ───────────────────────────────────────────────────────

  static pw.Widget _chip(String label, String value, pw.Font boldFont,
      pw.Font regularFont, PdfColor labelColor) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(font: regularFont, fontSize: 9, color: labelColor)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 11)),
        ],
      );

  static pw.Widget _sectionTitle(String text, pw.Font font, PdfColor color) =>
      pw.Text(text, style: pw.TextStyle(font: font, fontSize: 13, color: color));

  static pw.Widget _row(
    String label,
    String value,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
    PdfColor dividerColor, {
    PdfColor? valueColor,
  }) =>
      pw.Column(children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: labelStyle),
            pw.Text(value,
                style: valueColor != null
                    ? valueStyle.copyWith(color: valueColor)
                    : valueStyle),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: dividerColor, thickness: 0.5),
        pw.SizedBox(height: 6),
      ]);

  /// تنسيق القيمة العددية مع عملة SAR
  static String _fmt(String raw) {
    final n = double.tryParse(raw);
    if (n == null) return raw;
    final s = n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(2);
    return '$s SAR';
  }
}
