import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:workflowx/controllers/report_details_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/message_model.dart';
import 'package:workflowx/core/models/report_model.dart';

class ReportDetailsWithMessagesScreen extends StatelessWidget {
  final ReportModel report;
  final ReportDetailsController controller;

  ReportDetailsWithMessagesScreen({super.key, required this.report})
    : controller = Get.put(
        ReportDetailsController(report: report),
        tag: report.sId, // Ensure controller has report.sId for unique tagging
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
    // Added BuildContext
    final bool isMyMessage = chatMessage.senderId == controller.currentUserId;

    if (!isMyMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFd8eaff), // A light blue for support
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Support Team",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              chatMessage.messageContent,
              style: const TextStyle(fontSize: 14),
            ),
            Align(
              alignment:
                  Alignment
                      .bottomRight, // Changed to bottom right for consistency
              child: Text(
                DateFormat('hh:mm a').format(chatMessage.createdAt.toLocal()),
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      );
    } else {
      Alignment contentAlignment =
          isMyMessage ? Alignment.centerRight : Alignment.centerLeft;
      Color bubbleColor =
          isMyMessage
              ? Theme.of(context).primaryColor.withOpacity(
                0.15,
              ) // Use Theme context
              : Colors.grey[300]!;

      return Container(
        alignment: contentAlignment,
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ), // Adjusted margin
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          child: Column(
            crossAxisAlignment:
                isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMyMessage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    "Customer", // Or fetch sender's name if available
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              Text(
                chatMessage.messageContent,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                // Timestamp directly, no Align needed if CrossAxisAlignment is set
                DateFormat('hh:mm a').format(chatMessage.createdAt.toLocal()),
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String?> personalDetailsFromReport = {
      'Phone Number': report.phone,
      'User Type': report.userType,
      'Ticket No':
          report.sId?.isNotEmpty == true && report.sId!.length > 6
              ? report.sId!.substring(0, 6).toUpperCase()
              : report.sId,
    };

    final Map<String, String?> issueDetailsFromReport = {
      'Issue(s)': report.issue?.join(', '),
      'Description': report.description,
      'Status': report.status,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.white,
        elevation: 1, // Added slight elevation for separation
        shadowColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Details Section (Scrollable if content is too long) ---
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...personalDetailsFromReport.entries.map(
                    (entry) => _buildKeyValueRow(entry.key, entry.value),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Issue Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...issueDetailsFromReport.entries.map(
                    (entry) => _buildKeyValueRow(entry.key, entry.value),
                  ),
                  const SizedBox(height: 20),
                  if (report.images != null && report.images!.isNotEmpty) ...[
                    const Text(
                      'Uploaded Images',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                        loadingBuilder: (ctx, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorBuilder:
                                            (ctx, err, st) => const Center(
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
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
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
                                        progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12), // Reduced bottom space here
                  ],
                ],
              ),
            ),

            // *** FIX: Conditional chat section based on report status ***
            // The entire chat interface is only built if the report status is 'in progress'.
            if (report.status?.toLowerCase() == 'in progress') ...[
              // --- Messages Header with Refresh ---
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  12,
                  8,
                ), // Adjusted padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Messages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    // *** FIX: Improved refresh button logic to show a loader during any refresh action. ***
                    Obx(() {
                      // Always show a loader when loading messages, provides better UX.
                      if (controller.isLoadingMessages.value) {
                        return const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black54,
                          ),
                          tooltip: "Refresh messages",
                          // Call the controller's fetchMessages method.
                          onPressed: controller.fetchMessages,
                        );
                      }
                    }),
                  ],
                ),
              ),

              // --- Expanded Message List Section ---
              Expanded(
                // *** FIX: Added RefreshIndicator for pull-to-refresh functionality. ***
                child: RefreshIndicator(
                  // onRefresh requires a Future, which fetchMessages provides.
                  onRefresh: controller.fetchMessages,
                  child: Obx(() {
                    // Show "no messages" text only after the first load is complete.
                    if (!controller.isLoadingMessages.value &&
                        controller.messagesList.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          // Use a CustomScrollView to allow RefreshIndicator to work on an empty screen.
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                child: Center(
                                  child: Text(
                                    'No messages yet. Start the conversation!',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    //ListView.builder for messages
                    return ListView.builder(
                      controller: controller.messageScrollController,
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 10,
                      ), // Adjusted padding
                      itemCount: controller.messagesList.length,
                      itemBuilder: (context, index) {
                        final chatMsg = controller.messagesList[index];
                        return _buildMessage(chatMsg, context);
                      },
                    );
                  }),
                ),
              ),

              // --- Message Input Field (Stays at the bottom) ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  boxShadow: [
                    // Optional: add a subtle shadow
                    BoxShadow(
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 8,
                  top: 8,
                  bottom:
                      MediaQuery.of(context).padding.bottom +
                      8, // Handles notch
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageInputController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        minLines: 1,
                        maxLines: 5, // Increased max lines
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (controller.messageInputController.text
                              .trim()
                              .isNotEmpty) {
                            controller.sendMessage();
                          }
                        },
                        onTapOutside: (_) {
                          // Dismiss keyboard on tap outside
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    Obx(
                      () =>
                          controller.isSendingMessage.value
                              ? const Padding(
                                padding: EdgeInsets.all(
                                  12.0,
                                ), // Increased padding for loader
                                child: SizedBox(
                                  width: 20, // Matched icon button size better
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: Icon(
                                  Icons
                                      .send_rounded, // Using a rounded send icon
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed:
                                    controller.messageInputController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : controller.sendMessage,
                              ),
                    ),
                  ],
                ),
              ),
            ]
            // If status is not 'in progress', show a message instead of the chat interface.
            else ...[
              const Spacer(), // Pushes the message towards the center
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Chat is enabled once the report status is "In Progress".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(), // Pushes the message towards the center
            ],
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
