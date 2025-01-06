import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projek/db/functions/public_function.dart';
import 'package:projek/db/models/contact.dart';

class ContactsList extends StatefulWidget {
  final int userId;
  final String userFullName;

  const ContactsList(
      {super.key, required this.userId, required this.userFullName});

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  List<Contact> _contactsList = [];
  List<dynamic> _groupList = [
    {'grp_id': 0, 'grp_name': 'All Groups'}
  ];
  int selectedGroupId = 0;
  TextEditingController _searchController = new TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    List<Contact> myList = await getContacts(search: false);
    _groupList = _groupList + await getGroups();
    setState(() {
      _contactsList = myList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts List"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddForm();
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: "Search Name"),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      _contactsList = await getContacts(search: true);
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.amberAccent,
                    ))
              ],
            ),
            const Text(
              "",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            FutureBuilder(
                future: getGroups(),
                builder: (context, snapShot) {
                  switch (snapShot.connectionState) {
                    case ConnectionState.waiting:
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text("Loading..."),
                        ],
                      );
                    case ConnectionState.done:
                      if (snapShot.hasError) {
                        return Text("Error while: ${snapShot.error}");
                      }
                      //display listView here
                      return groupsDropDownButton();
                    default:
                      return Text("Error while: ${snapShot.error}");
                  }
                }),
            //litView
            Expanded(
              child: FutureBuilder(
                  future: getContacts(),
                  builder: (context, snapShot) {
                    switch (snapShot.connectionState) {
                      case ConnectionState.waiting:
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text("Loading..."),
                          ],
                        );
                      case ConnectionState.done:
                        if (snapShot.hasError) {
                          return Text("Error while: ${snapShot.error}");
                        }
                        //display listView here
                        return contactsListView();
                      default:
                        return Text("Error while: ${snapShot.error}");
                    }
                  }),
            ),
            Text(
              " ",
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget groupsDropDownButton() {
    return DropdownButton<int>(
        value: selectedGroupId,
        isExpanded: true,
        items: _groupList.map((group) {
          return DropdownMenuItem<int>(
              value: group['grp_id'], child: Text(group['grp_name']));
        }).toList(),
        onChanged: (newValue) async {
          setState(() {
            selectedGroupId = newValue!;
          });
          _contactsList = await getContacts();
        });
  }

  Widget contactsListView() {
    return ListView.builder(
      itemCount: _contactsList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.phone,
              color: Colors.amberAccent,
            ),
            title: Text(_contactsList[index].name!),
            subtitle: Text(_contactsList[index].phone!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      showUpdateForm(index);
                    },
                    icon: const Icon(
                      Icons.edit_note,
                      color: Colors.lightBlue,
                    )),
                IconButton(
                    onPressed: () {
                      showDeleteForm(index);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    )),
              ],
            ),
            onTap: () {
              // Show detail form on item tap
              showDetailForm(context, _contactsList[index]);
            },
          ),
        );
      },
    );
  }

  Future<List<Contact>> getContacts({bool search = false}) async {
    // await Future.delayed(
    //   const Duration(seconds: 3),
    // );
    String url = "http://10.0.2.2/flutter/api/contacts.php";

    //final Map<String, dynamic> jsonData = {
    //  "userId": widget.userId.toString(),
    // "groupId": selectedGroupId,
    //};
    Map<String, dynamic> json;
    if (search) {
      json = {"searchKey": _searchController.text, "userId": widget.userId};
    } else {
      json = Contact.jsonData(userId: widget.userId, groupId: selectedGroupId)
          .toJson();
    }

    var operation = search ? "search" : "getContacts";

    final Map<String, dynamic> queryParams = {
      "operation": operation,
      "json": jsonEncode(json),
    };

    http.Response response = await http.get(
      Uri.parse(url).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      var contacts = jsonDecode(response.body);

      var contactList = List.generate(
          contacts.length, (index) => Contact.fromJson(contacts[index]));

      return contactList;
    } else {
      return [];
    }
  }

  Future<List> getGroups() async {
    String url = "http://10.0.2.2/flutter/api/contacts.php";

    final Map<String, dynamic> queryParams = {
      "operation": "getGroups",
      "json": "",
    };

    http.Response response =
        await http.get(Uri.parse(url).replace(queryParameters: queryParams));

    if (response.statusCode == 200) {
      try {
        var groups = jsonDecode(response.body);
        return groups.map((group) {
          return {
            'grp_id': int.tryParse(group['grp_id']),
            'grp_name': group['grp_name'] ?? 'Unknown Group',
          };
        }).toList();
      } catch (e) {
        print("Error parsing groups: $e");
        return [];
      }
    } else {
      print("Error fetching groups: ${response.body}");
      return [];
    }
  }

  void showDetailForm(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Contact Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                  icon: Icons.person,
                  label: "Name",
                  value: contact.name ?? '',
                ),
                _buildDetailItem(
                  icon: Icons.phone,
                  label: "Phone",
                  value: contact.phone ?? '',
                ),
                _buildDetailItem(
                  icon: Icons.email,
                  label: "Email",
                  value: contact.email ?? '',
                ),
                _buildDetailItem(
                  icon: Icons.location_on,
                  label: "Address",
                  value: contact.address ?? '',
                ),
                _buildDetailItem(
                  icon: Icons.group,
                  label: "Group",
                  value: getGroupName(contact.groupId),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.amberAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getGroupName(int? groupId) {
    if (groupId == null) {
      return 'Unknown Group'; // Nilai default jika groupId null
    }

    // Cari grup berdasarkan ID dalam _groupList
    var group = _groupList.firstWhere(
      (group) => group['grp_id'] == groupId,
      orElse: () =>
          {'grp_name': 'Unknown Group'}, // Default jika tidak ditemukan
    );

    return group['grp_name'] ?? 'Unknown Group';
  }

  void showUpdateForm(int index) {
    final formKey = GlobalKey<FormState>();
    String name = _contactsList[index].name ?? '';
    String phone = _contactsList[index].phone ?? '';
    String email = _contactsList[index].email ?? '';
    String address = _contactsList[index].address ?? '';
    int groupId = _contactsList[index].groupId ?? 0;
    int id = _contactsList[index].id ?? 0;
    int userId = _contactsList[index].userId ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Update Contact",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.amberAccent,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    label: "Contact Name",
                    icon: Icons.person,
                    initialValue: name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                  _buildTextField(
                    label: "Phone Number",
                    icon: Icons.phone,
                    initialValue: phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Number";
                      } else if (value.length <= 10) {
                        return "Phone Number must be 11 digits";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phone = value!;
                    },
                  ),
                  _buildTextField(
                    label: "Email Address",
                    icon: Icons.email,
                    initialValue: email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Email";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  _buildTextField(
                    label: "Home Address",
                    icon: Icons.location_on,
                    initialValue: address,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Address";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      address = value!;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  DropdownButtonFormField<int>(
                    value: groupId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Group",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.group,
                        color: Colors.amberAccent,
                      ),
                    ),
                    items: _groupList.map((group) {
                      return DropdownMenuItem<int>(
                        value: group['grp_id'],
                        child: Text(group['grp_name']),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      groupId = newValue ?? 0;
                    },
                    validator: (value) {
                      if (value == 0) {
                        return "You must assign this contact to a group";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Contact contact = Contact.withId(
                    name: name,
                    phone: phone,
                    email: email,
                    groupId: groupId,
                    userId: userId,
                    address: address,
                    id: id,
                  );
                  if (await Update(contact) == 1) {
                    Navigator.pop(context);
                    _contactsList = await getContacts();
                    setState(() {});
                    showMessageBox(
                      context,
                      "Success!",
                      "Contact Successfully Updated",
                      backgroundColor: Colors.cyanAccent,
                    );
                  } else {
                    showMessageBox(
                      context,
                      "Update Failed!",
                      "Contact Not Updated",
                      backgroundColor: Colors.redAccent,
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Colors.amber),
        ),
        initialValue: initialValue,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Future<int> Update(Contact contact) async {
    Uri uri = Uri.parse('http://10.0.2.2/flutter/api/contacts.php');

    Map<String, dynamic> jsonData = contact.toJson2();

    Map<String, dynamic> data = {
      "operation": "update",
      "json": jsonEncode(jsonData),
    };

    http.Response response = await http.post(uri, body: data);

    return int.parse(response.body);
  }

  void showDeleteForm(int index) {
    int id = _contactsList[index].id ?? 0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure to DELETE ${_contactsList[index].name}?")
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await delete(id) == 1) {
                  Navigator.pop(context);
                  _contactsList = await getContacts();
                  setState(() {});
                  showMessageBox(context, "Deleted", "Contact has been deleted",
                      backgroundColor: Colors.pinkAccent);
                } else {
                  showMessageBox(
                      context, "Deleted Failed", "Contact has not been deleted",
                      backgroundColor: Colors.pinkAccent);
                }
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<int> delete(int contactId) async {
    Uri uri = Uri.parse('http://10.0.2.2/flutter/api/contacts.php');

    Map<String, dynamic> jsonData = {"id": contactId};

    Map<String, dynamic> data = {
      "operation": "delete",
      "json": jsonEncode(jsonData),
    };

    http.Response response = await http.post(uri, body: data);

    return int.parse(response.body);
  }

  void showAddForm() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String phone = '';
    String email = '';
    String address = '';
    int groupId = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Add Contact",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.amberAccent,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextFieldAdd(
                    label: "Contact Name",
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                  _buildTextFieldAdd(
                    label: "Phone Number",
                    icon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Number";
                      } else if (value.length <= 10) {
                        return "Phone Number must be at least 11 digits";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phone = value!;
                    },
                  ),
                  _buildTextFieldAdd(
                    label: "Email Address",
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Email";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  _buildTextFieldAdd(
                    label: "Home Address",
                    icon: Icons.location_on,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Contact Address";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      address = value!;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  DropdownButtonFormField<int>(
                    value: groupId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Group",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.group,
                        color: Colors.amberAccent,
                      ),
                    ),
                    items: _groupList.map((group) {
                      return DropdownMenuItem<int>(
                        value: group['grp_id'],
                        child: Text(group['grp_name']),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      groupId = newValue ?? 0;
                    },
                    validator: (value) {
                      if (value == 0) {
                        return "You must assign this contact to a group";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  Contact contact = Contact(
                    name: name,
                    phone: phone,
                    email: email,
                    groupId: groupId,
                    userId: widget.userId,
                    address: address,
                  );

                  try {
                    int result = await add(contact);

                    if (result == 1) {
                      Navigator.pop(context);
                      _contactsList = await getContacts();
                      setState(() {});
                      showMessageBox(
                          context, "Success!", "Contact Successfully Added",
                          backgroundColor: Colors.cyanAccent);
                    } else {
                      Navigator.pop(context);
                      _contactsList = await getContacts();
                      setState(() {});
                      showMessageBox(
                          context, "Success!", "Contact Successfully Added",
                          backgroundColor: Colors.redAccent);
                    }
                  } catch (e) {
                    showMessageBox(
                        context, "Error!", "Failed to add contact: $e",
                        backgroundColor: Colors.redAccent);
                  }
                }
              },
              child: const Text("Add"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextFieldAdd({
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Colors.amber),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Future<int> add(Contact contact) async {
    Uri uri = Uri.parse('http://10.0.2.2/flutter/api/contacts.php');

    Map<String, dynamic> jsonData = contact.toJson3();

    Map<String, dynamic> data = {
      "operation": "add",
      "json": jsonEncode(jsonData),
    };

    try {
      http.Response response = await http.post(uri, body: data);

      // Debugging response status and body
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Cek apakah respons berhasil
      if (response.statusCode == 200) {
        // Coba parse JSON dari respons
        return int.tryParse(response.body) ??
            0; // Jika tidak bisa parse, kembalikan 0
      } else {
        // Tangani jika status bukan 200 (OK)
        throw Exception("Failed to add contact: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      return 0; // Kembalikan 0 jika terjadi error
    }
  }
}
