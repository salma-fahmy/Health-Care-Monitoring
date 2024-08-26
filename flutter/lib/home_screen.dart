import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Define color constants
const Color primaryPink = Color(0xFFE91E63);
const Color secondaryPink = Color(0xFFC2185B);
const Color lightPink = Color(0xFFFFEBEE);
const Color backgroundPink = Color(0xFFF8BBD0);

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to handle user logout
  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Method to show dialog for account removal
  void _confirmRemoveAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _passwordController = TextEditingController();

        return AlertDialog(
          title: Text('Confirm Remove Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please enter your password to remove your account:'),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = _auth.currentUser!;
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: _passwordController.text,
                  );

                  await user.reauthenticateWithCredential(credential);
                  await user.delete();
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect password. Account not removed.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Remove Account'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // List of items with images, labels, and routes
    final items = [
      {
        'image': 'assets/images/photo_2024-08-26_13-42-41.jpg',
        'label': 'Temperature',
        'route': '/temperature'
      },
      {
        'image': 'assets/images/photo_2024-08-26_13-40-25.jpg',
        'label': 'ECG Heart Rate',
        'route': '/ecgHeartRate'
      },
      {
        'image': 'assets/images/photo_2024-08-26_13-41-40.jpg',
        'label': 'Pressure',
        'route': '/pressure'
      },
      {
        'image': 'assets/images/photo_2024-08-26_13-42-30.jpg',
        'label': 'Oxygen & Heart Rate',
        'route': '/oxygenHeartRate'
      },
      {
        'image': 'assets/images/photo_2024-08-26_13-42-04.jpg',
        'label': 'Medecine',
        'route': '/sendServo'
      },
      {'image': 'assets/images/photo_2024-08-27_00-56-12.jpg', 'label': 'Chat', 'route': '/chat'}
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryPink,
        actions: [
          // Button to confirm account removal
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmRemoveAccount(context),
          ),
          // Button to log out
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        color: backgroundPink,
        child: Column(
          children: [
            SizedBox(height: 20),
            // Welcome message
            Text(
              'Hello 😊',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: secondaryPink,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final image = item['image'];
                  final label = item['label'];
                  final route = item['route'];

                  return GestureDetector(
                    onTap: () {
                      if (route != null) {
                        Navigator.pushNamed(context, route);
                      }
                    },
                    child: Card(
                      color: lightPink,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Display image
                          image != null
                              ? Image.asset(
                                  image,
                                  height: 50,
                                  width: 50,
                                )
                              : Container(),
                          SizedBox(height: 10),
                          // Display label
                          Text(
                            label ?? '',
                            style: TextStyle(
                              color: secondaryPink,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
