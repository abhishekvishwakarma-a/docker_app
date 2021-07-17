import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyTerminal(),
  );
}

class MyTerminal extends StatefulWidget {
  @override
  Mystate createState() => Mystate();
}

class Mystate extends State<MyTerminal> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  bool isloggedin = false;
  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  getUser() async {
    User firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
  }

  var msgcontroller = TextEditingController();

  var state;

  String work;
  /*
  String osname;
  String imagename;
  String drivername;
  String netname;
  String basic;
  String work;
  String contname;
*/
  var fsconnect = FirebaseFirestore.instance;

  command(work) async {
    var url = http
        .get(Uri.parse("http://192.168.43.204/cgi-bin/docker.py?a=${work}"));

    var response = await http
        .get(Uri.parse("http://192.168.43.204/cgi-bin/docker.py?a=${work}"));

    setState(() {
      state = response.body;
    });
    await fsconnect.collection('DockerCommandOutput').add({'$work': '$state'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terminal',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade900,
        actions: <Widget>[
          IconButton(
              icon: Icon( 
                Icons.logout,
                color: Colors.tealAccent,
              ),
              onPressed: signOut),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    color: Colors.tealAccent,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          onChanged: (value) {
                            work = value;
                          },
                          autocorrect: false,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter Your Command",
                              prefixIcon: Icon(
                                Icons.android_outlined,
                                color: Colors.blue,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Material(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 10,
                    child: MaterialButton(
                      splashColor: Colors.blue,
                      minWidth: 80,
                      height: 40,
                      onPressed: () {
                        command(work);
                        msgcontroller.clear();
                      },
                      child: Text(
                        'Run',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  width: 340,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red.shade900),
                  child: Card(
                    color: Colors.black,
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(
                          state ?? "  ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
