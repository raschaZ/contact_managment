import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class EditContact extends StatefulWidget {
  const EditContact({super.key, required this.name, required this.phone, required this.photo, required this.id});
  final String id;
  final String name ;
  final String phone ;
  final String photo ;

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController ;
  late final TextEditingController phoneController ;
  late final TextEditingController photoController ;


  void editContact(String id) async {
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
  void initState() {
    // TODO: implement initState
    nameController = TextEditingController(
      text : widget.name,
    );
    phoneController = TextEditingController(
      text : widget.phone,
    );
    photoController = TextEditingController(
      text : widget.photo,
    );

    super.initState();
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
        title: const Text(" Edit Contact "),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Hero(
                      tag: widget.id,
                      child: CircleAvatar(
                        radius: 60,
                          backgroundImage: AssetImage(widget.photo),
                      ),
                    ),
                  ),
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
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        onPressed: (){} ,
                        icon: const Icon(IconlyBroken.edit_square),
                        label: const Text("Edit Contact")),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
