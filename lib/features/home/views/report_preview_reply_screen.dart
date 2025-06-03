import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:workflowx/controllers/report_details_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/message_model.dart';
// Assuming ChatMessage is defined in report_details_controller.dart or imported
// import 'package:workflowx/core/models/message_model.dart'; // If ChatMessage is here
import 'package:workflowx/core/models/report_model.dart';

class ReportDetailsWithMessagesScreen extends StatelessWidget {
  final ReportModel report;
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

  Widget _buildMessage(_ChatMessageContainer msgContainer) {
    final bool isMyMessage =
        msgContainer.chatMessage.senderId ==
        controller.currentUserId; // Use public getter

    if (!isMyMessage && msgContainer.chatMessage.isSupportMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFd8eaff),
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
              msgContainer.chatMessage.messageContent,
              style: const TextStyle(fontSize: 14),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                DateFormat(
                  'hh:mm a',
                ).format(msgContainer.chatMessage.createdAt.toLocal()),
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
              ? Get.theme.primaryColor.withOpacity(0.15)
              : Colors.grey[300]!;

      return Container(
        alignment: contentAlignment,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMyMessage && !msgContainer.chatMessage.isSupportMessage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    "Customer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              Text(
                msgContainer.chatMessage.messageContent,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat(
                    'hh:mm a',
                  ).format(msgContainer.chatMessage.createdAt.toLocal()),
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
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
              ? report.sId!.substring(0, 6)
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
        elevation: 0,
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
          // Main Column
          children: [
            Expanded(
              // This will contain all scrollable content *above* the input field
              child: ListView(
                // Your main outer ListView for details + message area
                controller:
                    controller
                        .scrollController, // This controller scrolls the whole details page
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    InteractiveViewer(
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.black,
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
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Recent Messages',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  // --- Message List Section ---
                  Obx(() {
                    if (controller.isLoadingMessages.value &&
                        controller.messagesList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!controller.isLoadingMessages.value &&
                        controller.messagesList.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text('No messages yet.'),
                        ),
                      );
                    }
                    // This Column will not scroll independently IF it's short enough to fit.
                    // If it becomes very long, the OUTER ListView will scroll.
                    // For a truly independently scrolling message list *within* the outer list,
                    // you'd need to give this message section a fixed or constrained height
                    // and use a ListView.builder inside that.
                    return Column(
                      children:
                          controller.messagesList.map((chatMsg) {
                            final bool isMyMsg =
                                chatMsg.senderId == controller.currentUserId;
                            return _buildMessage(
                              _ChatMessageContainer(
                                chatMessage: chatMsg,
                                isMyMessage: isMyMsg,
                              ),
                            );
                          }).toList(),
                    );
                  }),
                  const SizedBox(
                    height: 20,
                  ), // Space for padding at the bottom of the scroll view
                ],
              ),
            ),
            // --- Message Input Field (Stays at the bottom) ---
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
                      decoration: const InputDecoration(
                        hintText: 'message...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  Obx(
                    () =>
                        controller.isSendingMessage.value
                            ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                            : IconButton(
                              icon: Icon(
                                Icons.send,
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

class _ChatMessageContainer {
  final ChatMessage chatMessage;
  final bool isMyMessage;

  _ChatMessageContainer({required this.chatMessage, required this.isMyMessage});
}
