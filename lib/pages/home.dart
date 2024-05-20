import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_managment/pages/add_contact.dart';
import 'package:contact_managment/pages/edit_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:iconly/iconly.dart';
import '../Contact.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final contactCollection =
      FirebaseFirestore.instance.collection("contacts").snapshots();

  void deleteContact(String id) async {
    await FirebaseFirestore.instance.collection("contacts").doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("contact deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Contacts"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddContact(),
            ),
          );
        },
        icon: const Icon(IconlyBroken.document),
        label: const Text("Add contact"),
      ),
      body: StreamBuilder(
        stream: contactCollection,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(child: Text("No Data"));
            }
            return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final contact = docs[index].data() as Map<String, dynamic>;
                  final contactID = docs[index].id;
                  final String contactName = contact["name"];
                  final String contactPhone = contact["phone"];
                  final String contactPhoto = contact["photo"];
                  return ListTile(
                    title: Text(contactName),
                    subtitle: Text("$contactPhone"),
                    leading: Hero(
                      tag:  contactID,
                      child: CircleAvatar(
                        backgroundImage: AssetImage(contactPhoto),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditContact(
                                          name: contactName,
                                          phone: contactPhone,
                                          photo: contactPhoto,
                                          id: contactID,
                                      )));
                            },
                            icon: Icon(IconlyBroken.edit)),
                        IconButton(
                            onPressed: () => deleteContact(contactID),
                            icon: Icon(IconlyBroken.delete))
                      ],
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            return Center(
              child: Text("error"),
            );
          }
          return const Center(
            child: Text("500"),
          );
        },
      ),
    );
  }
}

showAlertDialog(BuildContext context, String message) {
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget continueButton = TextButton(
    child: const Text("Continue"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: const Text("AlertDialog"),
    content: Text(message),
    actions: [cancelButton, continueButton],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
