
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class myCourses extends StatefulWidget {
  const myCourses({super.key});

  @override
  State<myCourses> createState() => _myCoursesState();
}

class _myCoursesState extends State<myCourses> {
  Future<void> removeCourse(String courseId) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final enrollmentSnapshot = await FirebaseFirestore.instance
        .collection("enrollments")
        .where("studentId", isEqualTo: user.uid)
        .where("courseId", isEqualTo: courseId)
        .get();

    for (final doc in enrollmentSnapshot.docs) {
      await doc.reference.delete();
    }

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Course removed successfully"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to remove course"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
 Stream<List<Map<String, dynamic>>> getMyCourses() async* {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  final String uid = user.uid;

  await for (final enrollmentSnapshot in FirebaseFirestore.instance
      .collection("enrollments")
      .where("studentId", isEqualTo: uid)
      .snapshots()) {

    List<Map<String, dynamic>> myCourses = [];

    for (final enrollment in enrollmentSnapshot.docs) {
      final data = enrollment.data();

      final String courseId = data["courseId"];

      final courseSnapshot = await FirebaseFirestore.instance
          .collection("course")
          .doc(courseId)
          .get();

      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.data()!;

        myCourses.add({
          "id": courseSnapshot.id,
          "courseName": courseData["courseName"],
          "description": courseData["description"],
          "courseImage": courseData["courseImage"],
          "progress": data["progress"] ?? 0,
          "status": data["status"] ?? "ENROLLED",
        });
      }
    }

    yield myCourses;
  }
}

  Future<void> refreshCourses() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Courses",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              "Continue your learning journey",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getMyCourses(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff4F46E5),
              ),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Something went wrong",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final courses = snapshot.data ?? [];

          // No courses
          if (courses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xffEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 55,
                        color: Color(0xff4F46E5),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "No Courses Yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You haven't enrolled in any course yet.\nExplore courses and start learning!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Courses
          return RefreshIndicator(
            color: const Color(0xff4F46E5),
            onRefresh: refreshCourses,
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];

                final String courseName =
                    course["courseName"] ?? "Untitled Course";

                final String description =
                    course["description"] ?? "No description available";

                final String imageUrl =
                    course["courseImage"] ?? "";

                final int progress =
                    (course["progress"] ?? 0) is int
                        ? course["progress"]
                        : int.tryParse(
                              "${course["progress"]}",
                            ) ??
                            0;

                final String status =
                    course["status"] ?? "ENROLLED";

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Course Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 175,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    height: 175,
                                    color: const Color(0xffEEF2FF),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 50,
                                        color: Color(0xff4F46E5),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 175,
                                color: const Color(0xffEEF2FF),
                                child: const Center(
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    size: 55,
                                    color: Color(0xff4F46E5),
                                  ),
                                ),
                              ),
                      ),

                      // Course Details
                      Padding(
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            // Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffEEF2FF),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Color(0xff4F46E5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Course Name
                            Text(
                              courseName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 7),

                            // Description
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 18),



Row(
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          // Continue Learning
          
        },
        child: const Text("Continue Learning"),
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: OutlinedButton(
        onPressed: () {
          removeCourse(course["id"]);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text("Remove Course"),
      ),
    ),
  ],
)
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
