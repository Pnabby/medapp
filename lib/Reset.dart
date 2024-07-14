import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool loading = false;

  Future<void> sendResetPasswordLink(String email) async {
    try {
      setState(() {
        loading = true;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to ${email}!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        if(_emailController.text!= null) {
          setState(() {
            loading = true;
          });
          await FirebaseAuth.instance
              .sendPasswordResetEmail(email: _emailController.text.trim());
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset email sent!')),
          );
          Navigator.pop(context);
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
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
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Reset Password", style: TextStyle(fontSize: 35,color: Colors.green.shade800,fontWeight: FontWeight.bold),),
                  SizedBox(height: 50,),
                  Container(
                    height: 50,
                    margin: EdgeInsets.all(15),
                    child: TextFormField(
                      controller: _emailController,
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
                        fillColor: Colors.green.shade100,

                      ),
                    ),
                  ),
                  SizedBox(height: 50,),

                  Container(
                    height: 40,
                    width: double.infinity, // Stretch the button horizontally
                    margin: EdgeInsets.symmetric(horizontal: 15), // Add some margin for spacing
                    child: OutlinedButton(
                      onPressed: () {
                        sendResetPasswordLink(_emailController.text);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green.shade500),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Set rounded edges
                          ),
                        ),
                      ),
                      child: loading?CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ):Text("Receive reset email", style: TextStyle(fontSize: 15,color: Colors.white),),
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
