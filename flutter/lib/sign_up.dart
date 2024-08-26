import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color primaryPink = Color(0xFFE91E63);
const Color secondaryPink = Color(0xFFC2185B);
const Color lightPink = Color(0xFFF8BBD0);

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _errorMessage = ''; // Stores error messages

  // Function to handle user registration
  void _register() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to home screen on successful registration
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Update error message based on the type of Firebase exception
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'The email address is already in use.';
            break;
          case 'weak-password':
            _errorMessage = 'The password provided is too weak.';
            break;
          default:
            _errorMessage = 'Registration failed. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink, // Set the background color of the screen
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: secondaryPink,
              ),
            ),
            SizedBox(height: 20), // Space between elements
            TextField(
              controller: _emailController, // Controller for the email input
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: secondaryPink),
                filled: true, // Fill the background of the text field
                fillColor: Colors.white, // Background color of the text field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryPink),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: secondaryPink),
                ),
              ),
            ),
            SizedBox(height: 20), // Space between elements
            TextField(
              controller: _passwordController, // Controller for the password input
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: secondaryPink),
                filled: true, // Fill the background of the text field
                fillColor: Colors.white, // Background color of the text field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryPink),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: secondaryPink),
                ),
              ),
              obscureText: true, // Hide the password text
            ),
            SizedBox(height: 20), // Space between elements
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20), // Padding below the error message
                child: Text(
                  _errorMessage, // Display error message
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _register, // Register button action
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(primaryPink), // Button background color
                foregroundColor: MaterialStateProperty.all(Colors.white), // Button text color
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                )),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 15, horizontal: 100), // Button padding
                ),
              ),
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
