import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_managment/pages/add_contact.dart';
import 'package:contact_managment/pages/edit_contact.dart';
import 'package:contact_managment/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:iconly/iconly.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final contactCollection = FirebaseFirestore.instance.collection("contacts").snapshots();

  void deleteContact(String id) async {
    await FirebaseFirestore.instance.collection("contacts").doc(id).delete();
    if (mounted) {
      showToast(message:"Contact deleted successfully");
    }
  }

  void callContact(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to make call")));
      }
    }
  }

  final List<Color> _backgroundColors = [
    Colors.blue[50]!,
    Colors.green[50]!,
    Colors.orange[50]!,
    Colors.pink[50]!,
    Colors.purple[50]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Contacts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              showToast(message:"Successfully signed out");
            },
          ),
        ],
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
              return const Center(child: Text("No Data"));
            }
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final contact = docs[index].data() as Map<String, dynamic>;
                final contactID = docs[index].id;
                final String contactName = contact["name"];
                final String contactPhone = contact["phone"];
                final String contactPhoto = contact["photo"];
                final Color bgColor = _backgroundColors[index % _backgroundColors.length]; // Choose background color based on index

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      contactName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Text(contactPhone),
                    leading: Hero(
                      tag: contactID,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(contactPhoto),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => callContact(contactPhone),
                          icon: const Icon(
                            IconlyBroken.call,
                            color: Colors.lightGreen,
                          ),
                        ),
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
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            IconlyBroken.edit,
                            color: Colors.orange,
                          ),
                        ),
                        IconButton(
                          onPressed: () => deleteContact(contactID),
                          icon: const Icon(
                            IconlyBroken.delete,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
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
