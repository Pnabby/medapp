import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work/Dashboard.dart';
class AdminProfile extends StatefulWidget {

  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  bool loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    setState(() {
      loading=true;
    });
    await _auth.signOut();
    setState(() {
      loading= false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Dashboard()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile",style: TextStyle(color: Colors.green),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          height: 50,
          width: 200,
          child: ElevatedButton(
            onPressed: (){
             _signOut(context);
            },
            child: loading? CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.0,
            ):Text("Logout",style: TextStyle(fontSize: 20),),
            style: ButtonStyle(backgroundColor:MaterialStateProperty.all(Colors.green)),
          ),
        ),
      ),
    );
  }
}

