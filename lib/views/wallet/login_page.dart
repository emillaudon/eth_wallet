import 'package:eth_wallet/views/wallet/home_page.dart';
import 'package:flutter/material.dart';
import 'create_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController myUserNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Color(0xFF1D1E33),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 90.0),
            Image(
              image: AssetImage('images/eth.png'),
              height: 150,
              width: 150,
            ),
            SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextField(
                controller: myUserNameController,
                cursorColor: Colors.purple,
                decoration: InputDecoration(
                    hintText: 'Username', border: OutlineInputBorder()),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextField(
                cursorColor: Colors.purple,
                decoration: InputDecoration(
                    hintText: 'Password', border: OutlineInputBorder()),
              ),
            ),
            SizedBox(height: 25.0),
            ButtonTheme(
              height: 50,
              minWidth: 200.0,
              child: RaisedButton(
                color: Color(0xFF454A75),
                disabledColor: Color(0xFF454A75),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  });
                },
              ),
            ),
            SizedBox(height: 15.0),
            ButtonTheme(
              height: 50,
              minWidth: 200.0,
              child: RaisedButton(
                color: Color(0xFF454A75),
                disabledColor: Color(0xFF454A75),
                child: Text(
                  'Create New Account',
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreatePage()));
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
