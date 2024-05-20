import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

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

  void addContact() async {
    if (_formKey.currentState!.validate()) {
      try{
        await FirebaseFirestore.instance.collection("contacts").add({
          "name":nameController.text.trim(),
          "phone":phoneController.text.trim(),
          "photo": photoController.text.trim(),
        });
        if(mounted){
          Navigator.pop(context);
        }
      }on FirebaseException{
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all the fields")));
    }
  }
@override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    photoController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Add Contact "),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "please enter a name ";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "Name",
                      //contentPadding:  inputPadding,
                      //contentPadding:  inputPadding,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "please enter a phone number ";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "phone",
                      //contentPadding:  inputPadding,
                      //contentPadding:  inputPadding,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: photoController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "please enter a name ";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "photo",
                      //contentPadding:  inputPadding,
                      //contentPadding:  inputPadding,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        onPressed: addContact ,
                        icon: const Icon(IconlyBroken.add_user),
                        label: const Text("Add Contact")),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
