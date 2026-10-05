import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class allCourse extends StatefulWidget {
  const allCourse({super.key});

  @override
  State<allCourse> createState() => _allCourseState();
}

class _allCourseState extends State<allCourse> {

  // ==============================
  // GET COURSES
  // ==============================

  Future<QuerySnapshot<Map<String, dynamic>>> getCourse() {
    return FirebaseFirestore.instance.collection("course").get();
  }

  // ==============================
  // ENROLL COURSE
  // ==============================

  Future<void> enrollCourse(String courseId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showError("Please login first");
        return;
      }

      final String studentId = user.uid;

      // Already enrolled check
      final QuerySnapshot<Map<String, dynamic>> existingEnrollment =
          await FirebaseFirestore.instance
              .collection("enrollments")
              .where(
                "studentId",
                isEqualTo: studentId,
              )
              .where(
                "courseId",
                isEqualTo: courseId,
              )
              .get();

      if (existingEnrollment.docs.isNotEmpty) {
        showError("You are already enrolled in this course");
        return;
      }

      // Create enrollment
      await FirebaseFirestore.instance
          .collection("enrollments")
          .add({
        "studentId": studentId,
        "courseId": courseId,
        "enrolledAt": FieldValue.serverTimestamp(),
        "status": "ENROLLED",
        "progress": 0,
      });

      if (!mounted) return;

      showSuccess("Course enrolled successfully!");

    } catch (e) {
      debugPrint("Enrollment Error: $e");

      if (!mounted) return;

      showError("Failed to enroll in course");
    }
  }

  // ==============================
  // CHECK ENROLLMENT + SHOW CONTENT
  // ==============================

  Future<void> showCourseContent(String courseId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      // Login check
      if (user == null) {
        showError("Please login first");
        return;
      }

      final String studentId = user.uid;

      // ==========================================
      // CHECK WHETHER STUDENT IS ENROLLED
      // ==========================================

      final QuerySnapshot<Map<String, dynamic>>
          enrollmentSnapshot =
          await FirebaseFirestore.instance
              .collection("enrollments")
              .where(
                "studentId",
                isEqualTo: studentId,
              )
              .where(
                "courseId",
                isEqualTo: courseId,
              )
              .get();

      // ==========================================
      // NOT ENROLLED
      // ==========================================

      if (enrollmentSnapshot.docs.isEmpty) {
        if (!mounted) return;

        showError(
          "Please enroll in this course to access the content",
        );

        return;
      }

      // ==========================================
      // GET COURSE CONTENT
      // ==========================================

      final QuerySnapshot<Map<String, dynamic>> contentSnapshot =
          await FirebaseFirestore.instance
              .collection("courseContent")
              .where(
                "courseId",
                isEqualTo: courseId,
              )
              .get();

      if (!mounted) return;

      // No PDF
      if (contentSnapshot.docs.isEmpty) {
        showError("No content available for this course");
        return;
      }

      // ==========================================
      // SHOW CONTENT
      // ==========================================

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {

          return Container(
            height:
                MediaQuery.of(context).size.height * 0.65,

            padding: const EdgeInsets.all(20),

            decoration: const BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ==================================
                // HEADER
                // ==================================

                Row(
                  children: [

                    Container(
                      padding:
                          const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xffEEF2FF),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.menu_book_rounded,
                        color:
                            Color(0xff4F46E5),
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Course Content",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Color(0xff1F2937),
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "Available learning materials",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 20),

                // ==================================
                // CONTENT LIST
                // ==================================

                Expanded(
                  child: ListView.builder(
                    itemCount:
                        contentSnapshot.docs.length,

                    itemBuilder:
                        (context, index) {

                     final data = contentSnapshot.docs[index].data();

                      final String title =
                          data["title"] ??
                              "PDF";

                      final String type =
                          data["type"] ??
                              "PDF";

                      final String url =
                          data["url"] ??
                              "";

                      return Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),

                          border: Border.all(
                            color:
                                Colors.grey.shade200,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black
                                      .withOpacity(
                                0.04,
                              ),
                              blurRadius: 8,
                              offset:
                                  const Offset(
                                0,
                                3,
                              ),
                            ),
                          ],
                        ),

                        child: ListTile(

                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),

                          leading: Container(
                            padding:
                                const EdgeInsets
                                    .all(10),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.red.shade50,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                            ),

                            child: Icon(
                              Icons
                                  .picture_as_pdf,
                              color:
                                  Colors.red
                                      .shade600,
                              size: 28,
                            ),
                          ),

                          title: Text(
                            title,

                            maxLines: 2,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  Color(
                                0xff1F2937,
                              ),
                            ),
                          ),

                          subtitle: Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              top: 5,
                            ),

                            child: Text(
                              type,

                              style:
                                  const TextStyle(
                                fontSize: 11,
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ),

                          trailing:
                              const Icon(
                            Icons
                                .open_in_new,
                            color:
                                Color(
                              0xff4F46E5,
                            ),
                          ),

                          // =================================
                          // OPEN PDF
                          // =================================

                          onTap: () async {

                            if (url.isEmpty) {
                              showError(
                                "PDF URL not available",
                              );
                              return;
                            }

                            try {

                              final Uri uri =
                                  Uri.parse(url);

                              if (await canLaunchUrl(
                                uri,
                              )) {

                                await launchUrl(
                                  uri,

                                  mode:
                                      LaunchMode
                                          .externalApplication,
                                );

                              } else {

                                if (!mounted)
                                  return;

                                showError(
                                  "Unable to open PDF",
                                );
                              }

                            } catch (e) {

                              debugPrint(
                                "PDF Open Error: $e",
                              );

                              if (!mounted)
                                return;

                              showError(
                                "Unable to open PDF",
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

    } catch (e) {

      debugPrint(
        "Course Content Error: $e",
      );

      if (!mounted) return;

      showError(
        "Unable to load course content",
      );
    }
  }

  // ==============================
  // ERROR MESSAGE
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

        backgroundColor:
            Colors.red.shade700,

        behavior:
            SnackBarBehavior.floating,

        margin:
            const EdgeInsets.all(15),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        duration:
            const Duration(seconds: 3),
      ),
    );
  }

  // ==============================
  // SUCCESS MESSAGE
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

        backgroundColor:
            Colors.green.shade600,

        behavior:
            SnackBarBehavior.floating,

        margin:
            const EdgeInsets.all(15),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        duration:
            const Duration(seconds: 3),
      ),
    );
  }

  // ==============================
  // BUILD
  // ==============================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xffF7F8FA),

      // ==============================
      // APP BAR
      // ==============================

      appBar: AppBar(

        backgroundColor:
            Colors.white,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "All Courses",

              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 2),

            Text(
              "Explore courses and start learning",

              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight:
                    FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      // ==============================
      // BODY
      // ==============================

      body: FutureBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        future: getCourse(),

        builder:
            (context, snapshot) {

          // ==============================
          // LOADING
          // ==============================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(

              child:
                  CircularProgressIndicator(
                color:
                    Color(0xff4F46E5),
              ),
            );
          }

          // ==============================
          // ERROR
          // ==============================

          if (snapshot.hasError) {

            return Center(

              child: Padding(
                padding:
                    const EdgeInsets.all(30),

                child: Column(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Container(

                      padding:
                          const EdgeInsets.all(
                        18,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.red.shade50,
                        shape:
                            BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.error_outline,
                        size: 45,
                        color:
                            Colors.red.shade600,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      "Something went wrong",

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    const Text(
                      "Unable to load courses. Please try again.",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton(

                      onPressed: () {
                        setState(() {});
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xff4F46E5,
                        ),

                        foregroundColor:
                            Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),

                      child:
                          const Text(
                        "Try Again",
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==============================
          // NO DATA
          // ==============================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return Center(

              child: Padding(
                padding:
                    const EdgeInsets.all(30),

                child: Column(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Container(

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffEEF2FF,
                        ),

                        shape:
                            BoxShape.circle,
                      ),

                      child:
                          const Icon(
                        Icons
                            .menu_book_outlined,
                        size: 50,
                        color:
                            Color(
                          0xff4F46E5,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      "No Courses Available",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      "There are no courses available right now.",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==============================
          // COURSE DATA
          // ==============================

          final List<
                  QueryDocumentSnapshot<
                      Map<String, dynamic>>>
              data =
              snapshot.data!.docs;

          // ==============================
          // COURSE LIST
          // ==============================

          return RefreshIndicator(

            color:
                const Color(0xff4F46E5),

            onRefresh: () async {
              setState(() {});
            },

            child: ListView.builder(

              padding:
                  const EdgeInsets.all(18),

              itemCount:
                  data.length,

              itemBuilder:
                  (context, index) {

                // Course ID
                final String courseId =
                    data[index].id;

                final Map<String, dynamic>
                    course =
                    data[index].data();

                final String courseName =
                    course["courseName"] ??
                        "Untitled Course";

                final String description =
                    course["description"] ??
                        "No description available";

                final String imageUrl =
                    course["courseImage"] ??
                        "";

                return Container(

                  margin:
                      const EdgeInsets.only(
                    bottom: 18,
                  ),

                  decoration:
                      BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),

                    boxShadow: [

                      BoxShadow(
                        color:
                            Colors.black
                                .withOpacity(
                          0.06,
                        ),

                        blurRadius: 15,

                        offset:
                            const Offset(
                          0,
                          5,
                        ),
                      ),
                    ],
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      // ==========================
                      // COURSE IMAGE
                      // ==========================

                      ClipRRect(

                        borderRadius:
                            const BorderRadius
                                .only(
                          topLeft:
                              Radius.circular(
                            18,
                          ),

                          topRight:
                              Radius.circular(
                            18,
                          ),
                        ),

                        child:
                            imageUrl.isNotEmpty

                                ? Image.network(

                                    imageUrl,

                                    width:
                                        double.infinity,

                                    height: 190,

                                    fit:
                                        BoxFit.cover,

                                    loadingBuilder:
                                        (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {

                                      if (loadingProgress ==
                                          null) {
                                        return child;
                                      }

                                      return Container(

                                        height: 190,

                                        color:
                                            const Color(
                                          0xffF1F2F6,
                                        ),

                                        child:
                                            const Center(
                                          child:
                                              CircularProgressIndicator(
                                            color:
                                                Color(
                                              0xff4F46E5,
                                            ),
                                          ),
                                        ),
                                      );
                                    },

                                    errorBuilder:
                                        (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {

                                      return Container(

                                        height: 190,

                                        color:
                                            const Color(
                                          0xffEEF2FF,
                                        ),

                                        child:
                                            const Center(
                                          child:
                                              Icon(
                                            Icons
                                                .broken_image_outlined,
                                            size: 55,
                                            color:
                                                Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  )

                                : Container(

                                    height: 190,

                                    color:
                                        const Color(
                                      0xffEEF2FF,
                                    ),

                                    child:
                                        const Center(
                                      child:
                                          Icon(
                                        Icons
                                            .menu_book_rounded,
                                        size: 55,
                                        color:
                                            Color(
                                          0xff4F46E5,
                                        ),
                                      ),
                                    ),
                                  ),
                      ),

                      // ==========================
                      // COURSE DETAILS
                      // ==========================

                      Padding(

                        padding:
                            const EdgeInsets.all(
                          18,
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            // COURSE TITLE

                            Text(

                              courseName,

                              maxLines: 2,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(
                                  0xff1F2937,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            // DESCRIPTION

                            Text(

                              description,

                              maxLines: 3,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color:
                                    Color(
                                  0xff6B7280,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // DIVIDER

                            Divider(
                              color:
                                  Colors.grey
                                      .shade200,
                              height: 1,
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==========================
                            // BOTTOM ROW
                            // ==========================

                            Row(

                              children: [

                                // COURSE ICON

                                Container(

                                  padding:
                                      const EdgeInsets
                                          .all(
                                    9,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xffEEF2FF,
                                    ),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                  ),

                                  child:
                                      const Icon(
                                    Icons
                                        .school_outlined,
                                    size: 20,
                                    color:
                                        Color(
                                      0xff4F46E5,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                // COURSE INFO

                                const Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        "Online Course",

                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          fontSize: 13,
                                        ),
                                      ),

                                      SizedBox(
                                        height: 2,
                                      ),

                                      Text(
                                        "Learn at your own pace",

                                        style:
                                            TextStyle(
                                          color:
                                              Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ==========================
                                // CONTENT BUTTON
                                // ==========================

                                OutlinedButton.icon(

                                  onPressed: () {

                                    showCourseContent(
                                      courseId,
                                    );
                                  },

                                  icon:
                                      const Icon(
                                    Icons
                                        .menu_book,
                                    size: 17,
                                  ),

                                  label:
                                      const Text(
                                    "Content",
                                    style:
                                        TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),

                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    foregroundColor:
                                        const Color(
                                      0xff4F46E5,
                                    ),

                                    side:
                                        const BorderSide(
                                      color:
                                          Color(
                                        0xff4F46E5,
                                      ),
                                    ),

                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),

                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        10,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                // ==========================
                                // ENROLL BUTTON
                                // ==========================

                                ElevatedButton(

                                  onPressed: () {

                                    enrollCourse(
                                      courseId,
                                    );
                                  },

                                  style:
                                      ElevatedButton
                                          .styleFrom(

                                    backgroundColor:
                                        const Color(
                                      0xff4F46E5,
                                    ),

                                    foregroundColor:
                                        Colors.white,

                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),

                                    elevation: 0,

                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        10,
                                      ),
                                    ),
                                  ),

                                  child:
                                      const Text(
                                    "Enroll Now",

                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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