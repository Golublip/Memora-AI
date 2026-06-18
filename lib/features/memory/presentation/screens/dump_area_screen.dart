import 'package:flutter/material.dart';
import '../../../../core/theme/space_colors.dart';

class DumpAreaScreen extends StatefulWidget {
  const DumpAreaScreen({super.key});

  @override
  State<DumpAreaScreen> createState() => _DumpAreaScreenState();
}

class _DumpAreaScreenState extends State<DumpAreaScreen> {
  final List<Map<String, dynamic>> _mockDumpItems = [
    {
      'id': '1',
      'title': 'Coursera_Analytics_Cert.png',
      'status': 'Processing OCR & Gemini Classifier...',
      'progress': 0.65,
      'is_processed': false,
      'mime_type': 'image/png',
      'size': '2.1 MB'
    },
    {
      'id': '2',
      'title': 'MedicalReport_Cardiology.pdf',
      'status': 'Encrypting locally (Zero-Knowledge)...',
      'progress': 0.20,
      'is_processed': false,
      'mime_type': 'application/pdf',
      'size': '4.8 MB'
    },
    {
      'id': '3',
      'title': 'RentReceipt_June.jpg',
      'status': 'Uploading to Supabase Storage...',
      'progress': 0.90,
      'is_processed': false,
      'mime_type': 'image/jpeg',
      'size': '850 KB'
    },
    {
      'id': '4',
      'title': 'GoogleDriveLink.html',
      'status': 'Completed. Moving to Saved Links...',
      'progress': 1.0,
      'is_processed': true,
      'mime_type': 'text/html',
      'size': '15 KB'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceColors.spaceBlack,
      appBar: AppBar(
        backgroundColor: SpaceColors.midnightBlue,
        title: const Text(
          "UNIVERSAL DUMP AREA",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: SpaceColors.neonCyan,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Queue Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpaceColors.midnightBlue.withOpacity(0.6),
                border: Border.all(color: SpaceColors.neonCyan.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(SpaceColors.neonCyan),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Background Processing Queue Active",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "AI is analyzing, encrypting, and sorting files in the background.",
                          style: TextStyle(fontSize: 11, color: SpaceColors.textSecondary.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "INBOX NODES",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SpaceColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _mockDumpItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _mockDumpItems[index];
                  final bool done = item['is_processed'] as bool;
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SpaceColors.midnightBlue.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SpaceColors.glassWhite, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  item['mime_type'] == 'application/pdf'
                                      ? Icons.picture_as_pdf
                                      : Icons.insert_drive_file,
                                  color: done ? SpaceColors.neonCyan : SpaceColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      item['size'] as String,
                                      style: const TextStyle(fontSize: 11, color: SpaceColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              done ? Icons.check_circle : Icons.sync,
                              color: done ? Colors.greenAccent : Colors.amber,
                              size: 20,
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['status'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: done ? Colors.greenAccent : SpaceColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: item['progress'] as double,
                          backgroundColor: SpaceColors.glassWhite,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            done ? Colors.greenAccent : SpaceColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
