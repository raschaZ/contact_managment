import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconly/iconly.dart';
import 'dart:io';

class EditContact extends StatefulWidget {
  const EditContact({Key? key, required this.name, required this.phone, required this.photo, required this.id}) : super(key: key);
  final String id;
  final String name;
  final String phone;
  final String photo;

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController photoController;
  String currentPhoto = ''; // Track the current selected photo
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    photoController = TextEditingController(text: widget.photo);
    currentPhoto = widget.photo; // Initialize currentPhoto with the initial photo
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    photoController.dispose();
    super.dispose();
  }

  Future<void> _selectNewImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        currentPhoto = _imageFile!.path;
      });

      // Delete old image file from Firebase Storage
      if (widget.photo.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(widget.photo).delete();
        } catch (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete old image: $err")),
          );
        }
      }

      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference refRoot = FirebaseStorage.instance.ref();
      Reference refDirImg = refRoot.child("images");
      Reference refImgToUpload = refDirImg.child(uniqueFileName);

      try {
        await refImgToUpload.putFile(_imageFile!);
        String downloadUrl = await refImgToUpload.getDownloadURL();
        setState(() {
          photoController.text = downloadUrl;
          currentPhoto = downloadUrl;
        });
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $err")),
        );
      }
    }
  }

  void editContact(String id) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("contacts").doc(widget.id).update({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "photo": photoController.text.trim(),
        });
        Navigator.pop(context);
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update contact: ${e.message}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Contact"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selectNewImage,
                  child: Hero(
                    tag: widget.id,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(currentPhoto),
                    ),
                  ),
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a name";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Name",
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: phoneController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a phone number";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Phone",
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => editContact(widget.id),
                    icon: const Icon(IconlyBroken.edit_square),
                    label: const Text("Edit Contact"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
