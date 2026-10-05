import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddContent extends StatefulWidget {
  final String courseId;

  const AddContent({
    super.key,
    required this.courseId,
  });

  @override
  State<AddContent> createState() => _AddContentState();
}

class _AddContentState extends State<AddContent> {
  bool isUploading = false;

  Future<void> uploadFile() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: [typeGroup],
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        showMessage("PDF is empty");
        return;
      }

      setState(() {
        isUploading = true;
      });

      final String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.name}";

      // Course-wise folder
      final String filePath =
          "${widget.courseId}/$fileName";

      // Upload PDF to Supabase
      await Supabase.instance.client.storage
          .from("lms_pdf")
          .uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          contentType: "application/pdf",
        ),
      );

      // Get public URL
      final String pdfUrl = Supabase.instance.client.storage
          .from("lms_pdf")
          .getPublicUrl(filePath);

      // Save PDF information in Firestore
      await FirebaseFirestore.instance
          .collection("courseContent")
          .add({
        "courseId": widget.courseId,
        "title": file.name,
        "type": "PDF",
        "url": pdfUrl,
        "fileName": file.name,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      showMessage(
        "PDF uploaded successfully",
        success: true,
      );
    } catch (e) {
      debugPrint("PDF Upload Error: $e");

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      showMessage("Failed to upload PDF");
    }
  }

  void showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> deletePdf(
    String contentId,
    String fileName,
  ) async {
    try {
      final String filePath =
          "${widget.courseId}/$fileName";

      await Supabase.instance.client.storage
          .from("lms_pdf")
          .remove([filePath]);

      await FirebaseFirestore.instance
          .collection("courseContent")
          .doc(contentId)
          .delete();

      if (!mounted) return;

      showMessage(
        "PDF deleted successfully",
        success: true,
      );
    } catch (e) {
      debugPrint("Delete PDF Error: $e");

      if (!mounted) return;

      showMessage("Failed to delete PDF");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Content"),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("courseContent")
            .where(
              "courseId",
              isEqualTo: widget.courseId,
            )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No content added yet",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              final data = doc.data();

              final String title =
                  data["title"] ?? "PDF";

              final String fileName =
                  data["fileName"] ?? "";

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.picture_as_pdf,
                    ),
                  ),

                  title: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  subtitle: const Text(
                    "PDF",
                  ),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      deletePdf(
                        doc.id,
                        fileName,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      // Floating Add Content Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : uploadFile,
        icon: isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),

        label: Text(
          isUploading
              ? "Uploading..."
              : "Add Content",
        ),
      ),
    );
  }
}