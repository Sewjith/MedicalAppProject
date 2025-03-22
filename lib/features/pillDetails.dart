import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/core/bottom_nav.dart';
import 'package:medical_app/features/medication_reminder.dart';

class pillDetails extends StatefulWidget {
  final String name;
  final String details;

  pillDetails(
      {required this.name, required this.details});

  @override
  _pillDetailsState createState() => _pillDetailsState();
}
class _pillDetailsState extends State<pillDetails>{
  int _progressCount = 0;
  late int _totalDays = 10;

  void _editTotalDays(){
    TextEditingController _controller = TextEditingController(text: _totalDays.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Total Days"),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Total Days"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _totalDays = int.tryParse(_controller.text) ?? _totalDays;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _incrementProgress(){
    if (_progressCount < _totalDays) {
      setState(() {
        _progressCount++;
      });
    }
  }
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.headings),
        onPressed: (){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ReminderPage()));
        }),
        actions: [
          TextButton(onPressed: _editTotalDays,
          child: Text(
            'Edit',
            style: TextStyle(
              color: AppPallete.headings,
              fontSize: 16
            ),
          ),),
        ],
      ),
      body: SafeArea(
          child: Padding(padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Image.asset(
                'assets/images/pills.png',
                width: 200,
              ),
              SizedBox(height: 20),
              Text(
                widget.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: AppPallete.headings
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppPallete.lightBackground
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppPallete.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.details,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black45
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppPallete.lightBackground
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppPallete.textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('$_progressCount/$_totalDays days done',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                  ),),
                ],
              ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () => _showSkipDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.lightBackground,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppPallete.headings,
                        fontSize: 20
                      ),
                    ),
                      ),
                  ElevatedButton(
                    onPressed: (){
                      _incrementProgress();
                      _showDoneDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.headings,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                          color: AppPallete.lightBackground,
                          fontSize: 20
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
          ),
      ),
    );
  }
  void _showSkipDialog(BuildContext context){
    showDialog(context: context,
        builder: (BuildContext context){
      return AlertDialog(
        title: Text('Skipped'),
        content: Text('You have skipped this pill.'),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
              onPressed: (){
              Navigator.of(context).pop();
              },
          ),
        ],
      );
        },
    );
  }
  void _showDoneDialog(BuildContext context){
    showDialog(context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Completed'),
          content: Text('You have taken this pill.'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}