import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUploadImage extends StatefulWidget {
  const AdminUploadImage({super.key});

  @override
  State<AdminUploadImage> createState() => _AdminUploadImageState();
}

class _AdminUploadImageState extends State<AdminUploadImage> {

    final ImagePicker imagePicker=ImagePicker();
  XFile? selectedImage;
  void imagepick()async{
    XFile? image=await imagePicker.pickImage(source: ImageSource.gallery);
    print(image!.path);
    setState(() {
      selectedImage=image;
    });
  }

  Future<String?> uploadImage()async{
    final Uint8List bytes = await selectedImage!.readAsBytes();
    final fileName='${DateTime.now().millisecondsSinceEpoch}_${selectedImage!.name}';
    await Supabase.instance.client.storage.from("lms").uploadBinary(fileName, bytes);
    print("file upload successfully");
    String url=Supabase.instance.client.storage.from("lms").getPublicUrl(fileName);
    return url;
  }
  void addCourse()async{
    String? imageUrl= await uploadImage();
    await FirebaseFirestore.instance.collection("users").add({
      "name":"java",
      "courseImage":imageUrl
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: imagepick, child: Text("pick a image")),

          ElevatedButton(onPressed: addCourse, child: Text("add course"))
        ],
      ),
    );
  }
}
  