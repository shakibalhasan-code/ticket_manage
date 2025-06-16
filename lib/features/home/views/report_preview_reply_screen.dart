// lib/screens/report_details_with_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:workflowx/controllers/report_details_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/message_model.dart';
import 'package:workflowx/core/models/report_model.dart';

class ReportDetailsWithMessagesScreen extends StatelessWidget {
  final ReportModel report;

  // Correct controller initialization
  // The tag ensures a unique controller instance for each report detail screen
  final ReportDetailsController controller;

  ReportDetailsWithMessagesScreen({super.key, required this.report})
    : controller = Get.put(
        ReportDetailsController(report: report),
        tag: report.sId,
      );

  Widget _buildKeyValueRow(String key, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage chatMessage, BuildContext context) {
    // Using the controller's currentUserId for comparison
    final bool isMyMessage = chatMessage.senderId == controller.currentUserId;

    // Simplified message bubble logic
    final alignment =
        isMyMessage ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        isMyMessage
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : const Color(0xFFd8eaff); // Light blue for support
    final crossAxisAlignment =
        isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final senderName = isMyMessage ? "You" : "Support Team";

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              chatMessage.messageContent,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('hh:mm a').format(chatMessage.createdAt.toLocal()),
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  String get formattedTicketNo {
    if (report.sId != null && report.sId!.length > 5) {
      return '#${report.sId!.substring(report.sId!.length - 5).toUpperCase()}';
    }
    return report.sId ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    // Make status check case-insensitive for robustness
    final bool isChatEnabled = report.status?.toLowerCase() == 'inprogress';

    final personalDetails = {
      'Phone Number': report.phone,
      'User Type': report.userType,
      'Ticket No': formattedTicketNo,
      'Product': report.productId!.model ?? 'N/A',
    };

    final issueDetails = {
      'Issue(s)': report.issue?.join(', '),
      'Description': report.description,
      'Status': report.status,
      if (report.rejectedReason != null)
        'Rejected Reason': report.rejectedReason,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // --- Details Section ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...personalDetails.entries.map(
                            (e) => _buildKeyValueRow(e.key, e.value),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Issue Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...issueDetails.entries.map(
                            (e) => _buildKeyValueRow(e.key, e.value),
                          ),
                          const SizedBox(height: 20),
                          if (report.images != null &&
                              report.images!.isNotEmpty) ...[
                            const Text(
                              'Uploaded Images',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // The rest of your image grid view code... (it was correct)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: report.images!.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                              itemBuilder: (context, index) {
                                final imageUrl =
                                    report.images![index].startsWith('http')
                                        ? report.images![index]
                                        : '${ApiEndpoints.baseImageUrl}${report.images![index]}';
                                return GestureDetector(
                                  onTap: () {
                                    Get.dialog(
                                      Dialog(
                                        insetPadding: const EdgeInsets.all(
                                          20,
                                        ), // Give some padding
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            InteractiveViewer(
                                              panEnabled: true,
                                              minScale: 0.5,
                                              maxScale: 4.0,
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.contain,
                                                loadingBuilder: (
                                                  ctx,
                                                  child,
                                                  progress,
                                                ) {
                                                  if (progress == null)
                                                    return child;
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                                errorBuilder:
                                                    (ctx, err, st) =>
                                                        const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            size: 50,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Container(
                                                // Added background for better visibility
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onPressed: () => Get.back(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (ctx, err, st) => Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.error_outline,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            value:
                                                progress.expectedTotalBytes !=
                                                        null
                                                    ? progress
                                                            .cumulativeBytesLoaded /
                                                        progress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // --- Conditional Chat Section ---
                  if (isChatEnabled) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Messages',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Obx(() {
                              if (controller.isLoadingMessages.value) {
                                return const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                );
                              }
                              return IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.black54,
                                ),
                                tooltip: "Refresh messages",
                                onPressed: controller.fetchMessages,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      child: Obx(() {
                        if (controller.isLoadingMessages.value &&
                            controller.messagesList.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (controller.messagesList.isEmpty) {
                          return const Center(
                            child: Text(
                              'No messages yet. Start the conversation!',
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: controller.messageScrollController,
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 10,
                          ),
                          itemCount: controller.messagesList.length,
                          itemBuilder:
                              (context, index) => _buildMessage(
                                controller.messagesList[index],
                                context,
                              ),
                        );
                      }),
                    ),
                  ] else ...[
                    const SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            'Chat is only available when the report status is "In Progress".',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // --- Message Input Field ---
            if (isChatEnabled)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 8,
                  top: 8,
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageInputController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Type your message...',
                        ),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                    Obx(
                      () =>
                          controller.isSendingMessage.value
                              ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: controller.sendMessage,
                              ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
