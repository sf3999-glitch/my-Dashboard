import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ReportScreen({super.key, required this.projectId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Future<void> _downloadPDF(String type) async {
    setState(() { _isDownloading = true; _downloadProgress = 0; });
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) setState(() => _downloadProgress = i / 10);
    }
    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type PDF downloaded successfully!'),
          action: SnackBarAction(label: 'Open', onPressed: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final project = projectsState.projects.where((p) => p.id == widget.projectId).firstOrNull;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Export'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project summary card
            if (project != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.home_work_rounded, color: colorScheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text('${project.country ?? ''} · ${project.floors ?? 1} Floor(s) · ${project.constructionQuality ?? "Standard"}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text('Download Reports', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (_isDownloading) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 12),
                          const Text('Preparing PDF...'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: _downloadProgress, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            _ReportCard(
              title: 'Full Project Report',
              description: 'Complete report with floor plan, cost breakdown, materials list, and AI recommendations.',
              icon: Icons.article_outlined,
              color: colorScheme.primary,
              onDownload: () => _downloadPDF('Full Project'),
              isDownloading: _isDownloading,
            ),
            const SizedBox(height: 12),
            _ReportCard(
              title: 'Floor Plan Only',
              description: 'Detailed 2D floor plan with room dimensions and labels for all floors.',
              icon: Icons.architecture,
              color: Colors.blue,
              onDownload: () => _downloadPDF('Floor Plan'),
              isDownloading: _isDownloading,
            ),
            const SizedBox(height: 12),
            _ReportCard(
              title: 'Cost Estimate Report',
              description: 'Detailed cost breakdown by category with labor, material split and timeline.',
              icon: Icons.attach_money,
              color: Colors.green,
              onDownload: () => _downloadPDF('Cost Estimate'),
              isDownloading: _isDownloading,
            ),
            const SizedBox(height: 12),
            _ReportCard(
              title: 'Materials Report',
              description: 'Complete materials list with quantities, units and estimated costs.',
              icon: Icons.inventory_2_outlined,
              color: Colors.orange,
              onDownload: () => _downloadPDF('Materials'),
              isDownloading: _isDownloading,
            ),
            const SizedBox(height: 24),

            Text('Share Options', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'https://houseplanner.ai/p/${project?.id ?? "share-link"}',
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!')));
                          },
                          icon: const Icon(Icons.copy_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text('Share Link'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.email_outlined, size: 18),
                            label: const Text('Email Report'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
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
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onDownload;
  final bool isDownloading;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onDownload,
    required this.isDownloading,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      trailing: IconButton(
        onPressed: isDownloading ? null : onDownload,
        icon: Icon(Icons.download_outlined, color: color),
        style: IconButton.styleFrom(backgroundColor: color.withOpacity(0.1)),
      ),
    ),
  );
}
