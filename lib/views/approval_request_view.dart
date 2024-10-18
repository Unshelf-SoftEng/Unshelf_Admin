import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_admin/models/approval_request_model.dart';
import 'package:unshelf_admin/viewmodels/approval_request_viewmodel.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';

class ApprovalRequestsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Requests'),
      ),
      body: Row(
        children: [
          NavigationMenu(), // Include the navigation menu here
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter by Status:'),
                      Consumer<ApprovalRequestsViewModel>(
                        builder: (context, viewModel, _) {
                          return DropdownButton<String>(
                            value: viewModel.selectedStatus,
                            items: ['Pending', 'Approved', 'Rejected']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.updateSelectedStatus(value);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      context.read<ApprovalRequestsViewModel>().updateSearchQuery(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer<ApprovalRequestsViewModel>(
                      builder: (context, viewModel, _) {
                        return StreamBuilder<List<ApprovalRequest>>(
                          stream: viewModel.fetchRequests(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(child: Text('Error loading requests'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('No requests found'));
                            }

                            final requests = viewModel
                                .filterRequests(snapshot.data!)
                                .where((request) => request.name.toLowerCase().contains(viewModel.searchQuery.toLowerCase()))
                                .toList();

                            return ListView.builder(
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final request = requests[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    title: Text(request.name),
                                    subtitle: Text(request.email),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: () => viewModel.approveRequest(request.id, context),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () => viewModel.rejectRequest(request.id, context),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.info),
                                          onPressed: () => viewModel.viewDetails(request, context),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
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
