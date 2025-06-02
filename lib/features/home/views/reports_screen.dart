// ------------------------------
// Home Screen Main Widget
// ------------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/controllers/home_controller.dart';
import 'package:workflowx/core/constants/app_assets.dart';
import 'package:workflowx/core/models/report_model.dart';
import 'package:workflowx/core/routes/app_pages.dart';

import '../widget/report_ticket_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _currentNavIndex = 0;
  final homeController = Get.find<MainHomeController>();

  void _onReportTicketPressed() {
    // TODO: Implement report ticket button pressed action
  }

  void _onReportPressed(String droneName) {
    Get.toNamed(Routes.reportReply, arguments: droneName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset(AppAssets.logo, fit: BoxFit.contain, height: 36),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://thispersondoesnotexist.com/',
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ListView(
            children: [
              // Recent Report Ticket header
              const Text(
                'Reports',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 12),
              if (homeController.reportsList.isEmpty) ...[
                // No reports found message
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'No reports found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // List of report tickets
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: homeController.reportsList.length,
                  itemBuilder: (context, index) {
                    ReportModel report = homeController.reportsList[index];
                    return ReportTicketCard(
                      report: report,
                      onPressed: () {
                        Get.to(
                          () => ReportTicketCard(
                            report: report,
                            onPressed: () => onReportPassed(report),
                          ),
                          transition: Transition.rightToLeft,
                        );
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      backgroundColor: Colors.white,
    );
  }

  void onReportPassed(ReportModel report) {
    Get.toNamed(Routes.ticketDetails, arguments: report);
  }
}
