import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_admin/models/report_model.dart';
import 'package:unshelf_admin/viewmodels/report_viewmodel.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';

class ReportsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reportsViewModel = Provider.of<ReportsViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Reports'),
      ),
      body: Row(
        children: [
          NavigationMenu(), // Sidebar for navigation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<List<Report>>(
                stream: reportsViewModel.fetchPendingReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading reports'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No pending reports found'));
                  }

                  final reports = snapshot.data!;

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(report.userName),
                          subtitle: Text('Status: ${report.status}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: () => _showReportMessage(context, report.message),
                                tooltip: 'View Report Message',
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () => reportsViewModel.resolveReport(report.id, context),
                                tooltip: 'Resolve Report',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => reportsViewModel.deleteReport(report.id, context),
                                tooltip: 'Delete Report',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Message'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
