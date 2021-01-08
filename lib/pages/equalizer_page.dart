import 'package:ahmed_app/components/custom_eq.dart';
import 'package:equalizer/equalizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EqualizerPage extends StatefulWidget {
  @override
  _EqualizerPageState createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  bool enableCustomEQ = false;

  @override
  void initState() {
    super.initState();
    Equalizer.init(0);
  }

  @override
  void dispose() {
    Equalizer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer example'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10.0),
          Center(
            child: Builder(
              builder: (context) {
                return FlatButton.icon(
                  icon: Icon(Icons.equalizer),
                  label: Text('Open device equalizer'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () async {
                    try {
                      await Equalizer.open(0);
                    } on PlatformException catch (e) {
                      final snackBar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('${e.message}\n${e.details}'),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            color: Colors.grey.withOpacity(0.1),
            child: SwitchListTile(
              title: Text('Custom Equalizer'),
              value: enableCustomEQ,
              onChanged: (value) {
                Equalizer.setEnabled(value);
                setState(() {
                  enableCustomEQ = value;
                });
              },
            ),
          ),
          FutureBuilder<List<int>>(
            future: Equalizer.getBandLevelRange(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? CustomEQ(enableCustomEQ, snapshot.data)
                  : CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
