import 'package:ahmed_app/components/custom_eq.dart';
import 'package:equalizer/equalizer.dart';
import 'package:flutter/material.dart';

class EqualizerPage extends StatefulWidget {
  @override
  _EqualizerPageState createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  @override
  void initState() {
    super.initState();
    // Equalizer.init(0);
    // Equalizer.setEnabled(true);
  }

  @override
  void dispose() {
    //Equalizer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
      ),
      body: ListView(
        children: [
          FutureBuilder<List<int>>(
            future: Equalizer.getBandLevelRange(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? CustomEQ(snapshot.data)
                  : CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
