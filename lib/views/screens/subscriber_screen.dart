import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/subscriber_controller.dart';
import 'package:flood_monitoring/models/subscriber.dart';
import 'package:flood_monitoring/views/widgets/card.dart';
import 'package:flood_monitoring/views/widgets/confirmation_dialog.dart';
import 'package:flood_monitoring/views/widgets/message_dialog.dart';

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubscribers();
  }

  Future<void> _loadSubscribers() async {
    setState(() => _isLoading = true);
    SubscriberController().startListenerAfterBuild();
    await Provider.of<SubscriberController>(context, listen: false)
        .loadSubscribers();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 1200;
        final isMediumScreen = constraints.maxWidth > 800;

        return Consumer<SubscriberController>(
          builder: (context, controller, child) {
            return Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Search and Refresh button
                  SizedBox(
                    width: double.infinity,
                    child: isMediumScreen
                        ? Row(
                            children: [
                              Expanded(child: _buildHeaderText()),
                              _buildRefreshButton(),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: isLargeScreen ? 400 : 300,
                                child: _buildSearchField(controller),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderText(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildSearchField(controller)),
                                  const SizedBox(width: 12),
                                  _buildRefreshButton(),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Content
                  Expanded(
                    child: CustomCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _isLoading
                            ? _buildLoadingState()
                            : controller.display.isEmpty
                                ? _buildEmptyState()
                                : _buildResponsiveTable(controller),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Widgets ---

  Widget _buildHeaderText() {
    return Text(
      'Subscribers',
      style: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w800,
        fontSize: 32,
      ),
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      icon: Icon(Icons.refresh, color: AppColors.primary),
      onPressed: _loadSubscribers,
      tooltip: 'Refresh subscribers',
    );
  }

  Widget _buildSearchField(SubscriberController controller) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by name...',
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.lightGreyBackground,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        constraints: const BoxConstraints(maxHeight: 48),
      ),
      onChanged: (value) async {
        setState(() => _isLoading = true);
        controller.updateSearchQuery(value);
        controller.display = await controller.filteredSubscribers();
        setState(() => _isLoading = false);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading subscribers...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No subscribers found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSubscribers,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveTable(SubscriberController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: IntrinsicWidth(
          child: DataTableTheme(
            data: const DataTableThemeData(
              dataRowMinHeight: 65.0,
              dataRowMaxHeight: 65.0,
              headingRowHeight: 65.0,
            ),
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => const Color(0xFFF5F5F5),
              ),
              columns: [
                _headerCell('Name'),
                _headerCell('Age'),
                _headerCell('Gender'),
                _headerCell('Address'),
                _headerCell('Phone'),
                _headerCell('Registered Date'),
                _headerCell('Actions'),
              ],
              rows: controller.display.map((subscriber) {
                return DataRow(
                  cells: [
                    _dataCell(subscriber.name),
                    _dataCell(subscriber.age),
                    _dataCell(subscriber.gender),
                    _dataCell(subscriber.address),
                    _dataCell(subscriber.phone),
                    _dataCell(subscriber.registeredDate),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: TextButton(
                          onPressed: () =>
                              _deleteSubscriber(controller, subscriber),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // --- Table Helpers ---
  DataColumn _headerCell(String text) {
    return DataColumn(
      label: Text(text, style: const TextStyle(fontSize: 20)),
    );
  }

  DataCell _dataCell(String value) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // --- Actions ---
  Future<void> _deleteSubscriber(
    SubscriberController controller,
    Subscriber subscriber,
  ) async {
    final result = await CustomConfirmationDialog.show(
      context: context,
      title: 'Delete Subscriber',
      message: 'Do you want to delete this subscriber?',
      confirmText: 'Ok',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (result == true) {
      setState(() => _isLoading = true);
      await controller.deleteSubscriber(subscriber.id);
      setState(() => _isLoading = false);

      await MessageDialog.show(
        context: context,
        title: 'Subscriber Deleted',
        message: 'Subscriber deleted successfully.',
      );

      _loadSubscribers();
    }
  }
}