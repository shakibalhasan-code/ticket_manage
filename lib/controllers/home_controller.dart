// file: lib/features/home/controller/home_controller.dart
// (Adjust path as per your project structure)
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/brand_model.dart';
import 'package:workflowx/core/models/product_model.dart';
import 'package:workflowx/core/models/report_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class MainHomeController extends GetxController {
  /// Controllers for home screen
  final TextEditingController searchController = TextEditingController();
  final TextEditingController filterController = TextEditingController();

  var isLoadingProducts = false.obs;
  var isLoadingBrands = false.obs;
  var isLoadingTickets = false.obs;

  var selectedFilter = ''.obs;

  RxList<Product> productsList = <Product>[].obs;
  RxList<Brand> brandsList = <Brand>[].obs;
  RxList<ReportModel> reportsList = <ReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  void fetchInitialData() {
    getAllProducts();
    getAllBrand();
    getMyTickets();
  }

  @override
  void onClose() {
    searchController.dispose();
    filterController.dispose();
    super.onClose();
  }

  Future<void> getAllProducts() async {
    try {
      isLoadingProducts.value = true;
      productsList.clear(); // Clear previous data
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getProducts,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] != null && body['data'] is List) {
          final productsData = body['data'] as List;
          productsList.value =
              productsData.map((item) => Product.fromJson(item)).toList();
          printInfo(
            info: 'Products fetched successfully: ${productsList.length} items',
          );
        } else {
          print('No product data found or data is not a list.');
          productsList.value = []; // Set to empty list
        }
      } else {
        print(
          'Failed to load products. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in getAllProducts: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> getMyTickets() async {
    try {
      isLoadingProducts.value = true;
      reportsList.clear(); // Clear previous data
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getProducts,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] != null && body['data'] is List) {
          final tickets = body['data'] as List;
          reportsList.value =
              tickets.map((item) => ReportModel.fromJson(item)).toList();
          printInfo(
            info: 'Reports fetched successfully: ${reportsList.length} items',
          );
        } else {
          print('No Reports data found or data is not a list.');
          reportsList.value = []; // Set to empty list
        }
      } else {
        print(
          'Failed to load products. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in getAllProducts: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> getAllBrand() async {
    try {
      isLoadingBrands.value = true;
      brandsList.clear(); // Clear previous data
      final response = await ApiServices.fetchData(url: ApiEndpoints.getBrands);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] != null && body['data'] is List) {
          final brandsData = body['data'] as List;
          brandsList.value =
              brandsData.map((item) => Brand.fromJson(item)).toList();
        } else {
          print('No brand data found or data is not a list.');
          brandsList.value = []; // Set to empty list
        }
      } else {
        print(
          'Failed to load brands. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in getAllBrand: $e');
    } finally {
      isLoadingBrands.value = false;
    }
  }

  // Placeholder for search/filter logic
  void searchAndFilterProducts({String? searchTerm, String? brandId}) {
    // This is where you'd implement actual filtering.
    // For now, it might re-fetch or filter locally if data is small.
    // Example: if you fetch all products and then filter client-side:
    /*
    if (searchTerm != null || brandId != null) {
      var filtered = allFetchedProducts.where((product) {
        bool matchesSearch = searchTerm == null ||
            product.model!.toLowerCase().contains(searchTerm.toLowerCase());
        bool matchesBrand = brandId == null || product.brand == brandId;
        return matchesSearch && matchesBrand;
      }).toList();
      productsList.value = filtered;
    } else {
      productsList.value = allFetchedProducts; // Reset to all
    }
    */
    Get.snackbar(
      "Search/Filter",
      "Search: ${searchTerm}, Brand: ${brandId} - Implement logic",
      snackPosition: SnackPosition.BOTTOM,
    );
    // For server-side search, you'd call getAllProducts with parameters.
  }
}
