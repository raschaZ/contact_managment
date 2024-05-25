import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_managment/pages/add_contact.dart';
import 'package:contact_managment/pages/edit_contact.dart';
import 'package:contact_managment/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:iconly/iconly.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final contactCollection = FirebaseFirestore.instance.collection("contacts").snapshots();
  late TextEditingController _searchController;
  late List<QueryDocumentSnapshot> _contacts;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(); // Initialize _searchController here
    _contacts = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void deleteContact(String id) async {
    await FirebaseFirestore.instance.collection("contacts").doc(id).delete();
    if (mounted) {
      showToast(message: "Contact deleted successfully");
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
              showToast(message: "Successfully signed out");
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: contactCollection,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  _contacts = docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No Data"));
                  }

                  List<QueryDocumentSnapshot> filteredContacts = _searchController.text.isEmpty
                      ? docs
                      : docs.where((contact) {
                    final String name = contact["name"].toString().toLowerCase();
                    final String phone = contact["phone"].toString().toLowerCase();
                    final String query = _searchController.text.toLowerCase();
                    return name.contains(query) || phone.contains(query);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      final String contactName = contact["name"];
                      final String contactPhone = contact["phone"];
                      final String contactPhoto = contact["photo"];
                      final String contactID = contact.id;
                      final Color bgColor = _backgroundColors[index % _backgroundColors.length];

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
          ),
        ],
      ),
    );
  }
}
