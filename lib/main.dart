import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projek/db/contacts_list.dart';
import 'package:projek/db/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Colors.white,
          secondary: Colors.amber,
          background: Colors.grey.shade800,
          surface: Colors.grey.shade800,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey.shade900,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.amber,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(
              color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const MyHomePage(title: 'LockBook'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _msg = "";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              "Login",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                  labelText: "Username", hintText: "Enter Username"),
            ),
            const SizedBox(
              height: 30.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "Password", hintText: "Enter Password"),
            ),
            const SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
              onPressed: () {
                login();
              },
              child: const Text(
                "Login",
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Text(
              _msg,
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(
              height: 30.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Register(),
                  ),
                );
              },
              child: const Text(
                "No account? Register here",
                style: TextStyle(
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  fontSize: 20.0,
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  void login() async {
    String url = "http://10.0.2.2/flutter/api/users.php";

    final Map<String, dynamic> jsonData = {
      "username": _usernameController.text,
      "password": _passwordController.text
    };

    final Map<String, dynamic> queryParams = {
      "operation": "login",
      "json": jsonEncode(jsonData),
    };

    try {
      http.Response response =
          await http.get(Uri.parse(url).replace(queryParameters: queryParams));

      if (response.statusCode == 200) {
        var user = jsonDecode(response.body); //return type list<Map>
        if (user.isNotEmpty) {
          //navigate to next page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactsList(
                  userId: int.parse(user[0]['usr_id']),
                  userFullName: user[0]['usr_fullname']),
            ),
          );
        } else {
          setState(() {
            _msg = "Invalid Username or password.";
          });
        }
      } else {
        setState(() {
          _msg = "${response.statusCode} ${response.reasonPhrase}";
        });
      }
    } catch (error) {
      setState(() {
        _msg = "$error";
      });
    }
  }
}
