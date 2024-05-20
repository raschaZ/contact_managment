import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconly/iconly.dart';
import 'dart:io';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final photoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String currentPhoto = '';
  File? _imageFile;

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

  void addContact() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("contacts").add({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "photo": photoController.text.trim(),
        });
        if (mounted) {
          Navigator.pop(context);
        }
      } on FirebaseException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong")),
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
        title: const Text("Add Contact"),
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
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: currentPhoto.isNotEmpty
                        ? NetworkImage(currentPhoto)
                        : null,
                    child: currentPhoto.isEmpty
                        ? const Icon(Icons.add_a_photo, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: addContact,
                    icon: const Icon(IconlyBroken.add_user),
                    label: const Text("Add Contact"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
