import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:workflowx/core/models/report_model.dart'; // Adjust import path

class ReportTicketCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onPressed;
  const ReportTicketCard({
    Key? key,
    required this.report,
    required this.onPressed,
  }) : super(key: key);

  Color get statusColor {
    switch (report.status?.toLowerCase()) {
      case 'in progress':
      case 'pending': // Assuming 'pending' also maps to orange
        return Colors.orange;
      case 'solved':
      case 'completed': // Assuming 'completed' also maps to green
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get formattedTicketNo {
    if (report.sId != null && report.sId!.length > 5) {
      return 'Ticket #${report.sId!.substring(report.sId!.length - 5).toUpperCase()}';
    }
    return report.sId ?? 'N/A';
  }

  String get formattedDate {
    if (report.createdAt != null) {
      try {
        final dateTime = DateTime.parse(report.createdAt!);
        return DateFormat('dd/MM/yyyy').format(dateTime);
      } catch (e) {
        return report.createdAt!; // Fallback to raw string if parsing fails
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket no and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor, // Use theme color
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    formattedTicketNo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  report.status ?? 'N/A',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title (Issue)
            Text(
              report.issue ?? 'No Title Provided',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 10),

            // User info row
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  // Assuming report.user is an ID. Ideally, you'd have a userName field.
                  "User: ${report.user ?? 'N/A'}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Phone info row (if you want to display it)
            if (report.phone != null && report.phone!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    report.phone!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            // Date info row
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ],
            ),
            // The 'code' field is not in ReportModel, so it's omitted.
            // If 'code' was crucial, you'd add it to ReportModel or use another field.
          ],
        ),
      ),
    );
  }
}
