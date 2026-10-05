import 'package:flutter/material.dart';
import 'package:lms/addCourse.dart';
import 'package:lms/adminCourses.dart';
import 'package:lms/adminProfile.dart';
import 'package:lms/enrolledStudents.dart';

import 'adminDashboard.dart';


class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  int selectedIndex = 0;

  final List<Widget> pages = const [
    AdminDashboard(),
    
    AdminCourses(),
    AdminStudents(),
     AdminProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,

        selectedItemColor:
            const Color(0xff4F46E5),

        unselectedItemColor: Colors.grey,

        selectedFontSize: 12,

        unselectedFontSize: 11,

        elevation: 10,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            activeIcon: Icon(
              Icons.dashboard_rounded,
            ),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_book_outlined,
            ),
            activeIcon: Icon(
              Icons.menu_book_rounded,
            ),
            label: "All Course",
          ),
         

          BottomNavigationBarItem(
            icon: Icon(
              Icons.people_outline,
            ),
            activeIcon: Icon(
              Icons.people_rounded,
            ),
            label: "Students",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            activeIcon: Icon(
              Icons.person_rounded,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}