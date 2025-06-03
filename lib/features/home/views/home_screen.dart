import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/controllers/home_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/constants/app_assets.dart';
import 'package:workflowx/core/models/brand_model.dart';
import 'package:workflowx/core/models/product_model.dart';
import 'package:workflowx/core/routes/app_pages.dart';
import 'package:workflowx/features/home/views/file_report_screen.dart';
import 'package:workflowx/features/home/views/report_preview_reply_screen.dart';

import '../widget/drone_card.dart';
import '../widget/report_ticket_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Initialize HomeController
  final MainHomeController homeController = Get.put(MainHomeController());

  void _onReportTicketPressed() {
    Get.toNamed(Routes.report);
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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12),
        //     child: CircleAvatar(
        //       radius: 20,
        //       backgroundImage: NetworkImage(
        //         'https://thispersondoesnotexist.com/', // Replace with actual user image logic
        //       ),
        //     ),
        //   ),
        // ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ListView(
            children: [
              // Search Bar & filter icon
              Container(
                height: 44,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: homeController.searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search Drone',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          homeController.searchAndFilterProducts(
                            searchTerm: value,
                          );
                        },
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     // TODO: Implement filter UI (e.g., show a bottom sheet or dialog)
                    //     // For now, let's simulate a filter action
                    //     Get.bottomSheet(
                    //       Container(
                    //         height: 200,
                    //         color: Colors.white,
                    //         child: Column(
                    //           children: [
                    //             ListTile(
                    //               title: Text(
                    //                 "Filter Options",
                    //                 style: Get.textTheme.titleLarge,
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: Obx(
                    //                 () => ListView.builder(
                    //                   itemCount:
                    //                       homeController.brandsList.length,
                    //                   itemBuilder: (context, index) {
                    //                     final brand =
                    //                         homeController.brandsList[index];
                    //                     return ListTile(
                    //                       title: Text(
                    //                         brand.name ?? "Unknown Brand",
                    //                       ),
                    //                       onTap: () {
                    //                         homeController
                    //                             .selectedFilter
                    //                             .value = brand.sId ?? "";
                    //                         homeController
                    //                             .searchAndFilterProducts(
                    //                               brandId: brand.sId,
                    //                             );
                    //                         Get.back(); // Close bottom sheet
                    //                       },
                    //                     );
                    //                   },
                    //                 ),
                    //               ),
                    //             ),
                    //             TextButton(
                    //               onPressed: () {
                    //                 homeController.selectedFilter.value = "";
                    //                 homeController
                    //                     .searchAndFilterProducts(); // Clear filter
                    //                 Get.back();
                    //               },
                    //               child: Text("Clear Filter"),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     );
                    //     print('Filter button pressed');
                    //   },
                    //   icon: const Icon(Icons.filter_list, color: Colors.grey),
                    // ),
                  ],
                ),
              ),

              // Drone categories list (horizontal) - Brands
              Obx(() {
                if (homeController.isLoadingBrands.value) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (homeController.brandsList.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text('No categories found.')),
                  );
                }
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: homeController.brandsList.length,
                    itemBuilder: (context, index) {
                      final Brand brand = homeController.brandsList[index];
                      return Container(
                        width: 80, // Increased width for better text display
                        margin: EdgeInsets.only(
                          right:
                              index == homeController.brandsList.length - 1
                                  ? 0
                                  : 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  (brand.image != null &&
                                          brand.image!.isNotEmpty)
                                      ? NetworkImage(
                                        ('${ApiEndpoints.baseImageUrl}/${brand.image}'),
                                      )
                                      // Use a placeholder if no image or AppAssets.logo is not suitable
                                      : const AssetImage(AppAssets.logo)
                                          as ImageProvider,
                              backgroundColor: Colors.grey.shade200,
                              onBackgroundImageError: (_, __) {
                                // This is to handle if NetworkImage fails
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              brand.name ?? 'N/A',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 16), // Increased spacing
              // Drone cards horizontal scroll - Products
              Obx(() {
                if (homeController.isLoadingProducts.value) {
                  return const SizedBox(
                    height: 290, // Adjusted to match DroneCard height + margin
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (homeController.productsList.isEmpty) {
                  return SizedBox(
                    height: 290,
                    child: Center(
                      child: Text(
                        homeController.selectedFilter.isNotEmpty ||
                                homeController.searchController.text.isNotEmpty
                            ? 'No drones match your criteria.'
                            : 'No drones available.',
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 290,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: homeController.productsList.length,
                    itemBuilder: (context, index) {
                      final Product product =
                          homeController.productsList[index];
                      return DroneCard(
                        // Ensure your API provides a full URL or prepend a base URL
                        imageUrl:
                            '${ApiEndpoints.baseImageUrl}/${product.image}' ??
                            'https://via.placeholder.com/160x120.png?text=No+Image',
                        title: product.model ?? 'N/A',
                        description:
                            product.description ?? 'No description available.',
                        onReport:
                            () => Get.to(FileReportScreen(product: product)),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 16), // Increased spacing
              // Recent Report Ticket header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Report Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     // TODO: Navigate to a "View All Tickets" screen
                  //     Get.snackbar(
                  //       "Action",
                  //       "View All Tickets pressed",
                  //       snackPosition: SnackPosition.BOTTOM,
                  //     );
                  //   },
                  //   child: const Text('View All'),
                  // ),
                ],
              ),

              const SizedBox(height: 12),

              // Report Ticket cards list vertical
              // This part still uses dummy data. You'd fetch this similarly if it comes from an API.
              Obx(() {
                if (homeController.isLoadingTickets.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (homeController.reportsList.isEmpty) {
                  return const Center(child: Text('No recent tickets found.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: homeController.reportsList.length,
                  itemBuilder: (context, index) {
                    final ticket = homeController.reportsList[index];
                    return ReportTicketCard(
                      report: ticket,
                      onPressed: () {
                        Get.to(ReportDetailsWithMessagesScreen(report: ticket));
                      },
                    );
                  },
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
