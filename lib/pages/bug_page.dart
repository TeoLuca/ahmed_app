import 'package:ahmed_app/services/database_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class BugPage extends StatefulWidget {
  @override
  _BugPageState createState() => _BugPageState();
}

class _BugPageState extends State<BugPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I Spotted a Bug'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Describe your suggestion',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              scrollPadding: EdgeInsets.all(20.0),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 99999,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      await Firebase.initializeApp();
                      await DatabaseFirebase().updateBugsData(
                        titleController.text,
                        descriptionController.text,
                      );
                      titleController.clear();
                      descriptionController.clear();
                      Navigator.pop(context);
                      _showAlertDialog(
                        'Thanks for reporting a bug!',
                        'We try to make the app better with every day! You are an important part in making this a great app.\nThank you!',
                      );
                    },
                    child: Text('SEND'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCEL'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
