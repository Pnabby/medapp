import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:work/Login.dart';
import 'Dashboard.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Dashboard(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.green,
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
          ),
           */


          Positioned(
            left: MediaQuery.of(context).size.width/2 -320,
            bottom: MediaQuery.of(context).size.height/2-325,
            child: Container(
              height: 750,
              width: 650,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(300),

              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 2-50,
            child: CircleAvatar(
              backgroundColor: Colors.green.shade400,
              radius: 45,
              child: IconButton(
                padding: EdgeInsets.fromLTRB(0, 0, 35, 35),
                alignment: Alignment.center,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login()));
                },
                icon: Icon(Icons.arrow_forward_rounded,size: 60,),
                color: Colors.white,
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height/3-50,
            left: MediaQuery.of(context).size.width / 2-90,
            child: TextButton(
              onPressed: (){},
              child: Text("PODAWRFID",style: TextStyle(
                  color: Colors.green.shade800, fontSize: 30,fontWeight: FontWeight.w900
              ),),
            )
          ),
          Positioned(
              bottom: MediaQuery.of(context).size.height/2-70,
              left: MediaQuery.of(context).size.width / 2-180,
              child: TextButton(
                onPressed: (){},
                child: Image.asset("assets/begin.jpg", height: 350, width: 350,)
              )
          ),
        ],
      ),
    );
  }
}



