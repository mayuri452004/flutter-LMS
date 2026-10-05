import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class addCourse extends StatefulWidget {
  const addCourse({super.key});

  @override
  State<addCourse> createState() => _addCourseState();
}

class _addCourseState extends State<addCourse> {
  // ==============================
  // VARIABLES
  // ==============================

  XFile? selectedImage;
  Uint8List? selectedImageBytes;

  final ImagePicker imagePicker = ImagePicker();

  final TextEditingController courseName =
      TextEditingController();

  final TextEditingController description =
      TextEditingController();

  bool isLoading = false;

  // ==============================
  // IMAGE PICK
  // ==============================

  Future<void> imagepick() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        showError("Selected image is empty");
        return;
      }

      if (!mounted) return;

      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    } catch (e) {
      debugPrint("Image Pick Error: $e");

      if (!mounted) return;

      showError("Failed to select image");
    }
  }

  // ==============================
  // UPLOAD IMAGE
  // ==============================

  Future<String?> uploadImage() async {
    try {
      if (selectedImage == null ||
          selectedImageBytes == null) {
        showError("Please select course image");
        return null;
      }

      final Uint8List bytes = selectedImageBytes!;

      if (bytes.isEmpty) {
        showError("Selected image is invalid");
        return null;
      }

      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${selectedImage!.name}';

      await Supabase.instance.client.storage
          .from("lms")
          .uploadBinary(
            fileName,
            bytes,
          );

      final String url =
          Supabase.instance.client.storage
              .from("lms")
              .getPublicUrl(fileName);

      debugPrint("Image uploaded successfully");
      debugPrint("Image URL: $url");

      return url;
    } catch (e) {
      debugPrint("Image Upload Error: $e");

      if (mounted) {
        showError("Image upload failed");
      }

      return null;
    }
  }

  // ==============================
  // ADD COURSE
  // ==============================

  Future<void> addCourse() async {
    // Course Name
    if (courseName.text.trim().isEmpty) {
      showError("Please enter course name");
      return;
    }

    if (courseName.text.trim().length < 3) {
      showError(
        "Course name must contain at least 3 characters",
      );
      return;
    }

    // Description
    if (description.text.trim().isEmpty) {
      showError("Please enter course description");
      return;
    }

    if (description.text.trim().length < 10) {
      showError(
        "Description must contain at least 10 characters",
      );
      return;
    }

    // Image
    if (selectedImage == null ||
        selectedImageBytes == null) {
      showError("Please select course image");
      return;
    }

    if (selectedImageBytes!.isEmpty) {
      showError("Selected image is invalid");
      return;
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // ==============================
      // UPLOAD IMAGE
      // ==============================

      final String? imageUrl = await uploadImage();

      if (imageUrl == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      // ==============================
      // SAVE COURSE IN FIRESTORE
      // ==============================

     final String adminId =
    FirebaseAuth.instance.currentUser!.uid;

await FirebaseFirestore.instance
    .collection("course")
    .add({
  "courseName": courseName.text.trim(),
  "description": description.text.trim(),
  "courseImage": imageUrl,
  "adminId": adminId,
  "createdAt": FieldValue.serverTimestamp(),
});

      if (!mounted) return;

      // ==============================
      // CLEAR FORM
      // ==============================

      setState(() {
        isLoading = false;
        selectedImage = null;
        selectedImageBytes = null;
      });

      courseName.clear();
      description.clear();

      // ==============================
      // SUCCESS MESSAGE
      // ==============================

      showSuccess("Course created successfully!");
    } catch (e) {
      debugPrint("Add Course Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showError(
        "Unable to create course. Please try again.",
      );
    }
  }

  // ==============================
  // ERROR SNACKBAR
  // ==============================

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==============================
  // SUCCESS SNACKBAR
  // ==============================

  void showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==============================
  // REMOVE IMAGE
  // ==============================

  void removeImage() {
    setState(() {
      selectedImage = null;
      selectedImageBytes = null;
    });
  }

  // ==============================
  // DISPOSE
  // ==============================

  @override
  void dispose() {
    courseName.dispose();
    description.dispose();
    super.dispose();
  }

  // ==============================
  // INPUT DECORATION
  // ==============================

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xff4F46E5),
      ),
      filled: true,
      fillColor: const Color(0xffF8F9FB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xff4F46E5),
          width: 1.5,
        ),
      ),
    );
  }

  // ==============================
  // UI
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      // ==============================
      // APP BAR
      // ==============================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Create Course",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Add a new course to your LMS",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      // ==============================
      // BODY
      // ==============================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==============================
            // COURSE INFORMATION CARD
            // ==============================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // HEADER

                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color:
                              const Color(0xffEEF2FF),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),

                        child: const Icon(
                          Icons.menu_book_rounded,
                          color:
                              Color(0xff4F46E5),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Course Information",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Basic course details",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // COURSE NAME

                  const Text(
                    "Course Name",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: courseName,
                    textInputAction:
                        TextInputAction.next,

                    decoration: inputDecoration(
                      hint: "Enter course name",
                      icon: Icons.book_outlined,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: description,
                    maxLines: 2,

                    decoration: InputDecoration(
                      hintText:
                          "Describe what students will learn...",

                      alignLabelWithHint: true,

                     

                      filled: true,

                      fillColor:
                          const Color(0xffF8F9FB),

                      contentPadding:
                          const EdgeInsets.all(16),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide:
                            BorderSide.none,
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide:
                            BorderSide.none,
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(0xff4F46E5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==============================
            // IMAGE CARD
            // ==============================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Course Thumbnail",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Upload an attractive image for your course",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==============================
                  // IMAGE PREVIEW / UPLOAD
                  // ==============================

                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : imagepick,

                    child: Container(
                      width: double.infinity,
                      height: 130,

                      decoration: BoxDecoration(
                        color:
                            const Color(0xffF8F9FB),

                        borderRadius:
                            BorderRadius.circular(15),

                        border: Border.all(
                          color:
                              Colors.grey.shade300,
                        ),
                      ),

                      child: selectedImageBytes ==
                              null
                          ? Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .all(15),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xffEEF2FF,
                                    ),
                                    shape:
                                        BoxShape.circle,
                                  ),

                                  child: const Icon(
                                    Icons
                                        .cloud_upload_outlined,
                                    size: 40,
                                    color:
                                        Color(0xff4F46E5),
                                  ),
                                ),

                                const SizedBox(
                                    height: 12),

                                const Text(
                                  "Click to upload image",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                const Text(
                                  "PNG, JPG or JPEG",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                      15),

                              child: Image.memory(
                                selectedImageBytes!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,

                                errorBuilder:
                                    (context, error,
                                        stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Icon(
                                          Icons
                                              .broken_image_outlined,
                                          size: 45,
                                          color:
                                              Colors.grey,
                                        ),
                                        SizedBox(
                                            height: 8),
                                        Text(
                                          "Unable to preview image",
                                          style: TextStyle(
                                            color:
                                                Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),

                  // ==============================
                  // SELECTED IMAGE DETAILS
                  // ==============================

                  if (selectedImage != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 10,
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              selectedImage!.name,
                              overflow:
                                  TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: isLoading
                                ? null
                                : removeImage,

                            child: const Text(
                              "Remove",
                              style: TextStyle(
                                color:
                                    Color(0xff4F46E5),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==============================
            // CREATE BUTTON
            // ==============================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading ? null : addCourse,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff4F46E5),

                  foregroundColor: Colors.white,

                  disabledBackgroundColor:
                      Colors.grey.shade400,

                  elevation: 2,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                child: isLoading
                    ? const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          SizedBox(
                            height: 23,
                            width: 23,

                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),

                          SizedBox(width: 12),

                          Text(
                            "Creating Course...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons
                                .add_circle_outline,
                          ),

                          SizedBox(width: 8),

                          Text(
                            "Create Course",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}