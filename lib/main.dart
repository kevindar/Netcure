import 'package:flutter/material.dart';
import 'package:netcure/hospitalmap.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:netcure/hospitalmap_new.dart';
import 'dart:async';
import 'lang.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: NetCure(),
  ));
}

class NetCure extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NetCure> {
  route() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => NetCure_Login()));
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Stack(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(150, 0, 0, 0),
                  child: Hero(
                      tag: 'pills_hero',
                      child: Image.asset(
                        "assets/images/pills.png",
                      ))),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Hero(
                      tag: 'banner_hero',
                      child: Image.asset(
                        "assets/images/banner.png",
                        height: 70,
                      )))
            ],
          )),
    );
  }
}

class NetCure_Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<NetCure_Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                Container(
                                    padding: EdgeInsets.fromLTRB(150, 0, 0, 0),
                                    child: Hero(
                                        tag: 'pills_her',
                                        child: Image.asset(
                                          "assets/images/pills.png",
                                        ))),
                                Container(
                                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                                    child: Hero(
                                        tag: 'banner_hero',
                                        child: Image.asset(
                                          "assets/images/banner.png",
                                          height: 70,
                                        )))
                              ],
                            )),
                        SizedBox(height: 20),
                        Container(
                            child: Column(children: [
                          Row(children: [
                            SizedBox(
                              width: 40,
                            ),
                            Text("Email",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 10)),
                          ]),
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: TextField(
                              textAlign: TextAlign.center,
                              controller: nameController,
                              decoration: InputDecoration(
                                isDense: true,
                              ),
                            ),
                          ),
                          Row(children: [
                            SizedBox(
                              width: 40,
                            ),
                            Text("Password",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 10)),
                          ]),
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: TextField(
                              obscureText: true,
                              textAlign: TextAlign.center,
                              controller: passwordController,
                              decoration: InputDecoration(
                                isDense: true,
                              ),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              //forgot password screen
                            },
                            textColor: Colors.black,
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width - 75,
                              child: Expanded(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                      child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 8, 8, 8),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            textColor: Colors.white,
                                            color:
                                                Color.fromRGBO(99, 219, 167, 1),
                                            child: Text('Sign Up'),
                                            onPressed: () {
                                              //go to Sign Up Page
                                            },
                                          ))),
                                  Expanded(
                                      child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 8, 8, 8),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            textColor: Colors.white,
                                            color: Color.fromRGBO(
                                                155, 246, 161, 1),
                                            child: Text('Login'),
                                            onPressed: () {
                                              print(nameController.text);
                                              print(passwordController.text);
                                            },
                                          ))),
                                ],
                              )))
                        ])),
                        SizedBox(
                          height: 5,
                        )
                      ],
                    )))));
  }
}
