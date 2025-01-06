import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projek/db/functions/public_function.dart';
import 'package:projek/main.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LockBook"),
        backgroundColor: Colors.grey.shade800, // Warna app bar yang nyaman
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tambahkan ikon di bagian atas
              const Icon(
                Icons.account_circle, // Ikon default Flutter
                size: 80.0, // Ukuran ikon
                color: Colors.orangeAccent, // Warna ikon
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                "Registration",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.person,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: passwordController,
                obscureText: true, // Menyembunyikan password
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.lock,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: fullnameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.abc,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: () {
                  save();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orangeAccent, // Warna tombol yang nyaman
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void save() async {
    // Validasi untuk memastikan semua field diisi
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        fullnameController.text.isEmpty) {
      showMessageBox(
        context,
        "Failed",
        "Please fill in all fields",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    Uri uri = Uri.parse('http://10.0.2.2/flutter/api/users.php');

    Map<String, dynamic> jsonData = {
      "username": usernameController.text,
      "password": passwordController.text,
      "fullname": fullnameController.text,
    };

    Map<String, dynamic> data = {
      "operation": "register",
      "json": jsonEncode(jsonData),
    };

    http.Response response = await http.post(uri, body: data);

    print(response.body);

    if (response.statusCode == 200) {
      if (response.body == 1.toString()) {
        // Menampilkan dialog registrasi berhasil
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Registration Success"),
              content: const Text("You have registered!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Menutup dialog
                    // Navigasi ke halaman login setelah berhasil
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        showMessageBox(context, "Error", "Registration failed!",
            backgroundColor: Colors.redAccent);
      }
    } else {
      showMessageBox(
        context,
        "Error",
        "The server returned a ${response.statusCode} error.",
        backgroundColor: Colors.redAccent,
      );
    }
  }
}
