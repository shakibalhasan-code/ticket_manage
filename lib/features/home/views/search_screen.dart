// --- ui/screens/search_screen.dart ---
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/controllers/home_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/features/home/views/file_report_screen.dart';
import 'package:workflowx/features/home/widget/drone_card.dart';

// Use GetView for cleaner controller access
class SearchScreen extends GetView<MainHomeController> {
  SearchScreen({super.key});

  // This will hold the search query reactively
  final RxString searchQuery = ''.obs;
  final TextEditingController searchEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title is now a TextField for searching
        title: TextField(
          controller: searchEditingController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by model...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
          // Update the reactive search query on each change
          onChanged: (value) {
            searchQuery.value = value;
          },
        ),
        actions: [
          // Add a clear button to the search bar
          Obx(() {
            return searchQuery.value.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchEditingController.clear();
                    searchQuery.value = '';
                  },
                )
                : SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        // Show a loading indicator while fetching data
        if (controller.isLoadingProducts.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter the list based on the search query
        final displayedProducts =
            controller.productsList.where((product) {
              final titleLower = product.model?.toLowerCase() ?? '';
              final searchLower = searchQuery.value.toLowerCase();
              // You can also search in the description
              // final descriptionLower = product.description?.toLowerCase() ?? '';
              // return titleLower.contains(searchLower) || descriptionLower.contains(searchLower);
              return titleLower.contains(searchLower);
            }).toList();

        // Show a message if no products are found
        if (displayedProducts.isEmpty) {
          return const Center(
            child: Text(
              'No drones found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // Build the list of products
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: displayedProducts.length,
            itemBuilder: (context, index) {
              final product = displayedProducts[index];
              return DroneCard(
                imageUrl: '${ApiEndpoints.baseImageUrl}/${product.image}',
                title: product.model ?? 'N/A',
                description: product.description ?? 'No description available.',
                onReport:
                    () => Get.to(() => FileReportScreen(product: product)),
              );
            },
          ),
        );
      }),
    );
  }
}
