// review.dart
import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';

class Review extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String? specialty; // Optional if you want to show specialty
  final String? imageUrl;  // Optional if you want to show doctor image

  const Review({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    this.specialty,
    this.imageUrl,
  }) : super(key: key);

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  int _selectedIndex = 0;
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Review',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Your feedback helps us improve your healthcare experience. Please share your thoughts about the consultation.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppPallete.textColor),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.imageUrl != null
                  ? NetworkImage(widget.imageUrl!)
                  : AssetImage('assets/images/doc2.jpeg') as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(
              widget.doctorName,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppPallete.primaryColor,
              ),
            ),
            Text(
              widget.specialty ?? 'Specialty not specified',
              style: TextStyle(fontSize: 14, color: AppPallete.textColor),
            ),
            SizedBox(height: 20),
            // Rating widget would go here
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter Your Comment Here…',
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Add Review', style: TextStyle(fontSize: 16, color: AppPallete.whiteColor)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppPallete.primaryColor,
        unselectedItemColor: AppPallete.greyColor,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""),
        ],
      ),
    );
  }

  void _submitReview() {
    // Implement review submission logic here
    final reviewData = {
      'doctor_id': widget.doctorId,
      'rating': _rating,
      'comment': _commentController.text,
      'created_at': DateTime.now().toString(),
    };

    // Save the review (you would typically call your API here)
    print('Submitting review: $reviewData');

    // Show success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review submitted successfully!')),
    );
    Navigator.pop(context);
  }
}