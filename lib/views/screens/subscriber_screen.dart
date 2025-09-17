import 'package:flood_monitoring/models/subscriber.dart';
import 'package:flood_monitoring/views/widgets/confirmation_dialog.dart';
import 'package:flood_monitoring/views/widgets/message_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/subscriber_controller.dart';
import 'package:flood_monitoring/views/widgets/card.dart';

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> {
  
  @override
  void initState() {
    _loadSubscribers();
    SubscriberController().startListenerAfterBuild();
    super.initState();
  }

  void _loadSubscribers() {
    setState(() {
      Provider.of<SubscriberController>(
        context,
        listen: false,
      ).loadSubscribers();
    });
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
                  SizedBox(
                    width: double.infinity,
                    child: isMediumScreen
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Subscribers',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: isLargeScreen ? 400 : 300,
                                child: _buildSearchField(context, controller),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscribers',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildSearchField(context, controller),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: CustomCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: controller.display.isEmpty
                            ? _buildEmptyState(controller)
                            : _buildResponsiveTable(context, controller),
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

  Widget _buildSearchField(
    BuildContext context,
    SubscriberController controller,
  ) {
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        constraints: const BoxConstraints(maxHeight: 48),
      ),
      onChanged: (value) async {
        controller.updateSearchQuery(value);
        controller.display = await controller.filteredSubscribers();
      },
    );
  }

  Widget _buildEmptyState(SubscriberController controller) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No subscribers found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveTable(
    BuildContext context,
    SubscriberController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: IntrinsicWidth(
          child: DataTableTheme(
            data: DataTableThemeData(
              dataRowMinHeight: 65.0,
              dataRowMaxHeight: 65.0,
              headingRowHeight: 65.0,
            ),
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => Colors.grey.shade100,
              ),
              columns: const [
                DataColumn(label: Text('Name', style: TextStyle(fontSize: 20))),
                DataColumn(label: Text('Age', style: TextStyle(fontSize: 20))),
                DataColumn(
                  label: Text('Gender', style: TextStyle(fontSize: 20)),
                ),
                DataColumn(
                  label: Text('Address', style: TextStyle(fontSize: 20)),
                ),
                DataColumn(
                  label: Text('Phone', style: TextStyle(fontSize: 20)),
                ),
                DataColumn(
                  label: Text(
                    'Registered Date',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                DataColumn(
                  label: Text('Actions', style: TextStyle(fontSize: 20)),
                ),
              ],
              rows: controller.display.map((subscriber) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          subscriber.name,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          subscriber.age,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          subscriber.gender,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          subscriber.address,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          subscriber.phone,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          subscriber.registeredDate,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
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

  Future<void> _deleteSubscriber(
  SubscriberController subscriberController,
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
    await subscriberController.deleteSubscriber(subscriber.id);
    await MessageDialog.show(
      context: context,
      title: 'Subscriber Deleted',
      message: 'Subscriber deleted successfully.',
    );

    _loadSubscribers();
  }
}
}
