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
          decoration: const InputDecoration(
            hintText: 'Search by model...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
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
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchEditingController.clear();
                    searchQuery.value = '';
                  },
                )
                : const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingProducts.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayedProducts =
            controller.productsList.where((product) {
              final titleLower = product.model?.toLowerCase() ?? '';
              final searchLower = searchQuery.value.toLowerCase();
              return titleLower.contains(searchLower);
            }).toList();

        if (displayedProducts.isEmpty && searchQuery.value.isNotEmpty) {
          return const Center(
            child: Text(
              'No drones found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // Using GridView for better responsiveness on wider screens (like tablets)
        // is also a great option. For this example, we'll perfect the ListView.
        return ListView.builder(
          // Add padding to the list itself for horizontal and top/bottom space
          padding: const EdgeInsets.all(16.0),
          itemCount: displayedProducts.length,
          itemBuilder: (context, index) {
            final product = displayedProducts[index];
            // ------------------- FIX IS HERE -------------------
            // REMOVED the SizedBox with a fixed height.
            // The responsive DroneCard now determines its own height.
            // The Padding is kept to ensure vertical spacing between cards.
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DroneCard(
                imageUrl: '${ApiEndpoints.baseImageUrl}/${product.image}',
                title: product.model ?? 'N/A',
                description: product.description ?? 'No description available.',
                onReport:
                    () => Get.to(() => FileReportScreen(product: product)),
              ),
            );
            // ------------------- END OF FIX -------------------
          },
        );
      }),
    );
  }
}
