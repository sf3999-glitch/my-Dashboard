import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../providers/currency_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ReportScreen({super.key, required this.projectId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _isGenerating = false;
  bool _isGenerated = false;
  double _progress = 0.0;
  Uint8List? _pdfBytes;

  Future<void> _generatePdf() async {
    setState(() {
      _isGenerating = true;
      _progress = 0.0;
    });

    try {
      final detailState = ref.read(projectDetailProvider);
      final project = detailState.project;
      final costEstimate = detailState.costEstimate;
      final floorPlan = detailState.floorPlan;
      final currencyState = ref.read(currencyProvider);

      setState(() => _progress = 0.2);

      final pdf = pw.Document();

      setState(() => _progress = 0.4);

      // Title Page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Container(
              width: double.infinity,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(24),
                    color: PdfColor.fromHex('#1A3A6B'),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AI House Planner',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white70,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          project?.name ?? 'House Project Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  if (project != null) ...[
                    pw.Text(
                      'Project Summary',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                    _pdfRow('Location', '${project.city}, ${project.country}'),
                    _pdfRow('Plot Size', project.sizeDisplay),
                    _pdfRow('Number of Floors', '${project.floors}'),
                    _pdfRow('Bedrooms', '${project.bedrooms}'),
                    _pdfRow('Bathrooms', '${project.bathrooms}'),
                    _pdfRow('House Style', project.houseStyle),
                    _pdfRow('Construction Quality', project.constructionQuality),
                  ],
                  if (costEstimate != null) ...[
                    pw.SizedBox(height: 24),
                    pw.Text(
                      'Cost Estimate',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                    _pdfRow('Total Cost', currencyState.formatAmount(costEstimate.totalCost)),
                    _pdfRow('Material Cost', currencyState.formatAmount(costEstimate.materialCost)),
                    _pdfRow('Labor Cost', currencyState.formatAmount(costEstimate.laborCost)),
                    _pdfRow('Contingency', currencyState.formatAmount(costEstimate.contingency)),
                    _pdfRow('Timeline', costEstimate.timeline),
                    _pdfRow('Area', '${costEstimate.areaInSqFt.toStringAsFixed(0)} sq ft'),
                    _pdfRow('Cost per sq ft', currencyState.formatAmount(costEstimate.costPerSqFt)),
                  ],
                ],
              ),
            );
          },
        ),
      );

      setState(() => _progress = 0.7);

      // Cost Breakdown Page
      if (costEstimate != null) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Cost Breakdown',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 16),
                  ...costEstimate.breakdown.toMap().entries.map((entry) {
                    final percent = entry.value / costEstimate.breakdown.total * 100;
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text(entry.key, style: pw.TextStyle(fontSize: 12))),
                          pw.Text(
                            currencyState.formatAmount(entry.value),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Text(
                            '${percent.toStringAsFixed(1)}%',
                            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  pw.SizedBox(height: 24),

                  if (costEstimate.materials.isNotEmpty) ...[
                    pw.Text(
                      'Materials List (Top 10)',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A3A6B)),
                          children: [
                            _pdfTableHeader('Material'),
                            _pdfTableHeader('Qty'),
                            _pdfTableHeader('Unit'),
                            _pdfTableHeader('Total'),
                          ],
                        ),
                        ...costEstimate.materials.take(10).map((m) {
                          return pw.TableRow(
                            children: [
                              _pdfTableCell(m.name),
                              _pdfTableCell(m.quantity.toStringAsFixed(0)),
                              _pdfTableCell(m.unit),
                              _pdfTableCell(currencyState.formatAmount(m.totalPrice)),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }

      setState(() => _progress = 0.9);

      _pdfBytes = await pdf.save();

      setState(() {
        _progress = 1.0;
        _isGenerating = false;
        _isGenerated = true;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _progress = 0.0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(label, style: pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
          ),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _pdfTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  pw.Widget _pdfTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  Future<void> _printPdf() async {
    if (_pdfBytes == null) return;
    await Printing.layoutPdf(onLayout: (_) async => _pdfBytes!);
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/house_plan_report.pdf');
      await file.writeAsBytes(_pdfBytes!);
      await Share.shareXFiles([XFile(file.path)], text: 'My House Plan Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final detailState = ref.watch(projectDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.report),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Preview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Complete Project Report',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detailState.project?.name ?? 'House Project',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // What's included
            Text('Report includes:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...[
              (Icons.architecture_rounded, l10n.reportFloorPlan),
              (Icons.calculate_rounded, l10n.reportCostBreakdown),
              (Icons.inventory_2_rounded, l10n.reportMaterials),
              (Icons.schedule_rounded, l10n.reportTimeline),
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.$1, size: 16, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(item.$2, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )),

            const SizedBox(height: 32),

            // Generation progress
            if (_isGenerating) ...[
              Column(
                children: [
                  Text(
                    l10n.generatingReport,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ] else if (_isGenerated && _pdfBytes != null) ...[
              // PDF actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text(
                      l10n.pdfGenerated,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _printPdf,
                      icon: const Icon(Icons.print_rounded),
                      label: Text(l10n.openPdf),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sharePdf,
                      icon: const Icon(Icons.share_rounded),
                      label: Text(l10n.share),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Regenerate Report'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ] else ...[
              // Generate button
              ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(l10n.downloadReport),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
