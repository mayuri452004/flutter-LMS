import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminStudents extends StatefulWidget {
  const AdminStudents({super.key});

  @override
  State<AdminStudents> createState() => _AdminStudentsState();
}

class _AdminStudentsState extends State<AdminStudents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getStudentCourses(
      String studentId) async {
    final enrollmentSnapshot = await _firestore
        .collection("enrollments")
        .where("studentId", isEqualTo: studentId)
        .get();

    List<Map<String, dynamic>> courses = [];

    for (var enrollment in enrollmentSnapshot.docs) {
      final data = enrollment.data();

      final String courseId = data["courseId"] ?? "";

      if (courseId.isEmpty) continue;

      final courseDoc =
          await _firestore.collection("course").doc(courseId).get();

      if (courseDoc.exists) {
        final courseData = courseDoc.data();

        if (courseData != null) {
          courses.add({
            "courseName": courseData["courseName"] ?? "Unknown Course",
            "status": data["status"] ?? "ENROLLED",
            "progress": data["progress"] ?? 0,
          });
        }
      }
    }

    return courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Students",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
    .collection("users")
    .where(
      "role",
      isEqualTo: "STUDENT",
    )
    .where(
      "adminId",
      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
    )
    .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          final students = snapshot.data?.docs ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                "No students found",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,

            itemBuilder: (context, index) {
              final student = students[index];

              final data = student.data();

              final String name = data["name"] ?? "Student";
              final String email = data["email"] ?? "-";
              final String phone = data["phone"] ?? "-";

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: getStudentCourses(student.id),

                builder: (context, courseSnapshot) {
                  if (courseSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(name),
                        subtitle: const Text(
                          "Loading enrolled courses...",
                        ),
                      ),
                    );
                  }

                  final courses = courseSnapshot.data ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),

                    elevation: 3,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // STUDENT INFO
                          Row(
                            children: [

                              const CircleAvatar(
                                radius: 28,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      email,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          const Divider(),

                          const SizedBox(height: 8),

                          // COURSE COUNT
                          Row(
                            children: [

                              const Icon(
                                Icons.menu_book,
                                color: Colors.red,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                "Enrolled Courses: ${courses.length}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // COURSES
                          if (courses.isEmpty)

                            const Text(
                              "Not enrolled in any course",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )

                          else

                            Column(
                              children: courses.map((course) {

                                final String courseName =
                                    course["courseName"] ??
                                        "Unknown Course";

                                final String status =
                                    course["status"] ??
                                        "ENROLLED";

                                final int progress =
                                    course["progress"] ?? 0;

                                return Container(
                                  width: double.infinity,

                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 10,
                                  ),

                                  padding:
                                      const EdgeInsets.all(12),

                                  decoration: BoxDecoration(
                                    color: Colors.grey
                                        .withOpacity(0.08),

                                    borderRadius:
                                        BorderRadius.circular(
                                            10),

                                    border: Border.all(
                                      color: Colors.grey
                                          .withOpacity(0.2),
                                    ),
                                  ),

                                  child: Row(
                                    children: [

                                      const Icon(
                                        Icons.book,
                                        color: Colors.red,
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [

                                            Text(
                                              courseName,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),

                                            const SizedBox(
                                                height: 5),

                                            Text(
                                              "Status: $status",
                                              style:
                                                  const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),

                                            const SizedBox(
                                                height: 5),

                                            Text(
                                              "Progress: $progress%",
                                              style:
                                                  const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}