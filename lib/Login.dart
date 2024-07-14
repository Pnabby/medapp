import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work/AdminDashboard.dart';
import 'package:work/Dashboard.dart';
import 'package:work/Reset.dart';
//import 'package:firebase_auth/firebase_auth.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

final _auth = FirebaseAuth.instance;
bool eye = false;
bool loading = false;
class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _signIn() async {
    try {
      setState(() {
        loading = true;
      });
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
        //email: "paulbletcher9@gmail.com",
        //password: "helloworld"
      );

      User? user = userCredential.user;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email or password incorrect.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong.'),
        ),
      );
      print(e); // Handle the error accordingly
    } finally{
      setState(() {
        loading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //top
          /*Positioned(
            top: -80,
            left: -80,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  color:  Colors.blue,
                  borderRadius: BorderRadius.circular(100)
              ),
              child: Text(" "),// Example color
            ),
          ),
          //bottom
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  color:  Colors.greenAccent,
                  borderRadius: BorderRadius.circular(100)
              ),
              child: Text(" "),
            ),
          ),*/

          //reset button
          Positioned(
              bottom: 60,
              left: MediaQuery.of(context).size.width / 2-62,
              child: TextButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Reset()));
                },
                child: Text("Reset Password",style: TextStyle(
                    color: Colors.green.shade800, fontSize: 15
                ),),
              )
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Login", style: TextStyle(fontSize: 35,color: Colors.green.shade800,fontWeight: FontWeight.bold),),
                  SizedBox(height: 30,),
                  Container(height: 150, width: 150, color: Colors.transparent, child: Image.asset("assets/loginimage.png"),),

                  Container(
                    height: 50,
                    margin: EdgeInsets.all(15),
                    child: TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        hintText: " Email",
                        hintStyle: TextStyle(color: Colors.white,),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide(color: Colors.green.shade50),
                      ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide(color: Colors.green.shade50),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide(color: Colors.green.shade50),
                        ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.fromLTRB(30, 10, 20, 10), // Adjust as needed
                        child: FaIcon(FontAwesomeIcons.solidEnvelope,size: 25, color: Colors.white,),
                      ),
                        filled: true,
                        fillColor: Colors.green.shade300,

                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.all(15),
                    child: TextFormField(
                      controller: _password,
                      obscureText: !eye,
                      decoration: InputDecoration(
                        hintText: " Password",
                        hintStyle: TextStyle(color: Colors.white,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide(color: Colors.green.shade50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide(color: Colors.green.shade50),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.fromLTRB(30, 10, 20, 10), // Adjust as needed
                        child: FaIcon(FontAwesomeIcons.lock,size: 25, color: Colors.white,),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.fromLTRB(0,0,0,0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                          child: IconButton(
                            icon: FaIcon(eye?FontAwesomeIcons.eye:FontAwesomeIcons.eyeSlash,size: 25, color: Colors.white,),
                            onPressed: (){
                              setState(() {
                                eye = !eye;
                              });
                            },
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.green.shade300,
                      ),
                    ),
                  ),
                  SizedBox(height: 50,),
                  Container(
                    height: 50,
                    width: double.infinity, // Stretch the button horizontally
                    margin: EdgeInsets.symmetric(horizontal: 15), // Add some margin for spacing
                    child: OutlinedButton(
                      onPressed: () async {
                        _signIn();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green.shade500),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Set rounded edges
                          ),
                        ),
                      ),
                      child: loading? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ):Text("Login", style: TextStyle(fontSize: 18,color: Colors.white),),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

