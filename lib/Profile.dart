import 'package:flutter/material.dart';
import 'package:work/Login.dart';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}
bool admin = false;

class _ProfileState extends State<Profile> {
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
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login()));
            },
            child: Text("Login as Admin",style: TextStyle(fontSize: 20),),
            style: ButtonStyle(backgroundColor:MaterialStateProperty.all(Colors.green)),
          ),
        ),
      ),
    );
  }
}
