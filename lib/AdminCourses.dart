import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'addCourse.dart';
import 'addContent.dart';

class AdminCourses extends StatefulWidget {
  const AdminCourses({super.key});

  @override
  State<AdminCourses> createState() => _AdminCoursesState();
}

class _AdminCoursesState extends State<AdminCourses> {
  // =========================================================
  // DELETE COURSE
  // =========================================================

  Future<void> deleteCourse(String courseId) async {
    try {
      await FirebaseFirestore.instance
          .collection("course")
          .doc(courseId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course deleted successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  // =========================================================
  // CONFIRM DELETE
  // =========================================================

  void confirmDelete(String courseId, String courseName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Course"),
          content: Text('Are you sure you want to delete "$courseName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await deleteCourse(courseId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // EDIT COURSE
  // =========================================================

  void editCourse(
    String courseId,
    String courseName,
    String description,
    String imageUrl,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: courseName,
    );

    final TextEditingController descriptionController = TextEditingController(
      text: description,
    );

    XFile? selectedImage;
    Uint8List? selectedImageBytes;

    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Edit Course",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              // =================================================
              // CONTENT
              // =================================================
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =========================================
                      // COURSE IMAGE
                      // =========================================
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: selectedImageBytes != null
                              ? Image.memory(
                                  selectedImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(Icons.image, size: 50),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // =========================================
                      // CHANGE IMAGE BUTTON
                      // =========================================
                      OutlinedButton.icon(
                        onPressed: isUpdating
                            ? null
                            : () async {
                                try {
                                  final XFile? image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);

                                  if (image == null) {
                                    return;
                                  }

                                  final Uint8List bytes = await image
                                      .readAsBytes();

                                  if (bytes.isEmpty) {
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Selected image is empty",
                                        ),
                                      ),
                                    );

                                    return;
                                  }

                                  setDialogState(() {
                                    selectedImage = image;
                                    selectedImageBytes = bytes;
                                  });
                                } catch (e) {
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Image selection failed: $e",
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.image),
                        label: const Text("Change Image"),
                      ),

                      const SizedBox(height: 20),

                      // =========================================
                      // COURSE NAME
                      // =========================================
                      TextField(
                        controller: nameController,
                        enabled: !isUpdating,
                        decoration: InputDecoration(
                          labelText: "Course Name",
                          hintText: "Enter course name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.book),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // =========================================
                      // DESCRIPTION
                      // =========================================
                      TextField(
                        controller: descriptionController,
                        enabled: !isUpdating,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Enter course description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =================================================
              // ACTIONS
              // =================================================
              actions: [
                // CANCEL
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("Cancel"),
                ),

                // UPDATE
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          final String name = nameController.text.trim();

                          final String desc = descriptionController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter course name"),
                              ),
                            );

                            return;
                          }

                          if (desc.isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter description"),
                              ),
                            );

                            return;
                          }

                          setDialogState(() {
                            isUpdating = true;
                          });

                          try {
                            // ===================================
                            // KEEP OLD IMAGE BY DEFAULT
                            // ===================================

                            String finalImageUrl = imageUrl;

                            // ===================================
                            // UPLOAD NEW IMAGE IF SELECTED
                            // ===================================

                            if (selectedImage != null &&
                                selectedImageBytes != null) {
                              final String fileName =
                                  '${DateTime.now().millisecondsSinceEpoch}_${selectedImage!.name}';

                              await Supabase.instance.client.storage
                                  .from("lms")
                                  .uploadBinary(fileName, selectedImageBytes!);

                              finalImageUrl = Supabase.instance.client.storage
                                  .from("lms")
                                  .getPublicUrl(fileName);
                            }

                            // ===================================
                            // UPDATE FIRESTORE
                            // ===================================

                            await FirebaseFirestore.instance
                                .collection("course")
                                .doc(courseId)
                                .update({
                                  "courseName": name,
                                  "description": desc,
                                  "courseImage": finalImageUrl,
                                  "updatedAt": FieldValue.serverTimestamp(),
                                });

                            if (!mounted) return;

                            // Close dialog
                            Navigator.pop(dialogContext);

                            // Success message
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("Course updated successfully"),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isUpdating = false;
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text("Update failed: $e")),
                            );
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      descriptionController.dispose();
    });
  }

  // =========================================================
  // COURSE CARD
  // =========================================================

  Widget courseCard(String courseId, Map<String, dynamic> data) {
    final String courseName = data["courseName"] ?? "No Course Name";

    final String description = data["description"] ?? "No Description";

    final String imageUrl = data["courseImage"] ?? "";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        // ===============================================
        // OPEN COURSE CONTENT
        // ===============================================
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContent(courseId: courseId),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================================
              // IMAGE
              // =========================================
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),

              const SizedBox(width: 15),

              // =========================================
              // COURSE DETAILS
              // =========================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // EDIT
                        IconButton(
                          tooltip: "Edit Course",
                          onPressed: () {
                            editCourse(
                              courseId,
                              courseName,
                              description,
                              imageUrl,
                            );
                          },
                          icon: const Icon(Icons.edit),
                        ),

                        // DELETE
                        IconButton(
                          tooltip: "Delete Course",
                          onPressed: () {
                            confirmDelete(courseId, courseName);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),

                        const Spacer(),

                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Courses",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // =====================================================
      // COURSE LIST
      // =====================================================
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("course")
             .where(
      "adminId",
      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
    )
            .snapshots(),

        builder: (context, snapshot) {
          // ===============================================
          // LOADING
          // ===============================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ===============================================
          // ERROR
          // ===============================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error loading courses:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ===============================================
          // EMPTY
          // ===============================================

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No courses available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          // ===============================================
          // COURSE LIST
          // ===============================================

          final courses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: courses.length,

            itemBuilder: (context, index) {
              final doc = courses[index];

              return courseCard(doc.id, doc.data());
            },
          );
        },
      ),

      // =====================================================
      // ADD COURSE BUTTON
      // =====================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const addCourse()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Course"),
      ),
    );
  }
}
