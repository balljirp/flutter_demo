import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Welcome'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // variable
  bool isLoading = false;
  bool checkDataValue = false;
  bool checkValid = false;
  dynamic resultData;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // function call api
  Future<void> performSignin() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> body = {
      'username': _userNameController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    final response = await http.post(
        Uri.parse('http://103.13.231.185:8080/api/v1/test_login/'),
        body: body);

    var result = jsonDecode(response.body);
    resultData = result['meta'];

    // custom response data
    var responseText = resultData['response_data'].toString();
    var fullname = 'Jiraphorn Jitamphai';
    String textMessage = responseText.replaceFirst('Hi', 'Hi $fullname');

    if (response.statusCode == 200) {
      if (resultData['response_code'] == 20000) {
        // case success
        setState(() {
          checkValid = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              message: textMessage,
            ),
          ),
        );
      } else if (resultData['response_code'] == 40001) {
        // case unauthorized
        setState(() {
          checkValid = true;
        });
      } else {
        // case exception occurred
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("${resultData['response_desc']}"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // when can't connection api
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("Exception Occurred"),
            actions: <Widget>[
              TextButton(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // on click signin button
  Future<void> _onCheckDataValue() async {
    setState(() {
      checkDataValue = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _userNameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    labelText: 'Username'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    labelText: 'Password'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              if (checkValid)
                const Text(
                  'Invalid username or password',
                  style: TextStyle(color: Colors.red),
                ),
              if (checkDataValue &&
                  (_userNameController.text.trim().isEmpty ||
                      _passwordController.text.trim().isEmpty))
                const Text(
                  'Please fill out the information completely',
                  style: TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            checkValid = false;
                          });

                          String username = _userNameController.text.trim();
                          String password = _passwordController.text.trim();

                          if (username.isEmpty || password.isEmpty) {
                            _onCheckDataValue();
                          } else {
                            performSignin();
                          }
                        },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Sign in',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ))
            ],
          ),
        ));
  }
}
