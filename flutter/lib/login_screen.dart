import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_up.dart';

// Define color constants
const Color primaryPink = Color(0xFFE91E63);
const Color secondaryPink = Color.fromARGB(255, 238, 40, 119);
const Color lightPink = Color(0xFFF8BBD0);
const Color backgroundPink = Color(0xFFF8BBD0);
const Color buttonBlue = Color(0xFF4FC3F7);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instance of FirebaseAuth for authentication
  final _auth = FirebaseAuth.instance;

  // Variable to store error messages
  String _errorMessage = '';

  // Function to handle user login
  void _login() async {
    try {
      // Attempt to sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Navigate to home screen if login is successful
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            _errorMessage = 'Wrong password provided.';
            break;
          default:
            _errorMessage = 'Login failed. Please try again.';
        }
      });
    }
  }

  // Function to navigate to the sign-up screen
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPink, // Set background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or image at the top of the screen
            Image.asset(
              'assets/images/medical-team.png', // Ensure this image is in the assets folder
              height: 150,
            ),
            SizedBox(height: 20),
            
            // Title text
            Text(
              'Health Care Monitor',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: secondaryPink,
              ),
            ),
            SizedBox(height: 20),
            
            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: secondaryPink),
                filled: true, // Fill background
                fillColor: Colors.white, // Background color
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
            SizedBox(height: 20),
            
            // Password input field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: secondaryPink),
                filled: true, // Fill background
                fillColor: Colors.white, // Background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryPink),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: secondaryPink),
                ),
              ),
              obscureText: true, // Hide password text
            ),
            SizedBox(height: 20),
            
            // Display error message if any
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            
            // Login button
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
              ),
              child: Text('Log in'),
            ),
            SizedBox(height: 10),
            
            // Navigate to sign-up screen button
            ElevatedButton(
              onPressed: _navigateToSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
              ),
              child: Text('Create Account'),
            ),
            SizedBox(height: 20),
            
            // Instructions for new users
            Text(
              'If you are new to the app, Please create an account!',
              style: TextStyle(color: secondaryPink),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
