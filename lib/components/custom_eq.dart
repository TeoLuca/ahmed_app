import 'package:flutter/material.dart';
import 'package:equalizer/equalizer.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomEQ extends StatefulWidget {
  const CustomEQ(this.enabled, this.bandLevelRange);

  final bool enabled;
  final List<int> bandLevelRange;

  @override
  _CustomEQState createState() => _CustomEQState();
}

class _CustomEQState extends State<CustomEQ> {
  SharedPreferences sharedPreferences;

  double min, max;
  String _selectedValue;
  Future<List<String>> fetchPresets;

  void initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    min = widget.bandLevelRange[0].toDouble();
    max = widget.bandLevelRange[1].toDouble();
    fetchPresets = Equalizer.getPresetNames();
    String preset = sharedPreferences.getString('PRESET') ?? '';
    bool customEQ = sharedPreferences.getBool('CUSTOM_EQ') ?? false;
    if (customEQ == false) {
      Equalizer.setPreset('Normal');
      setState(() {
        _selectedValue = 'Normal';
      });
    } else if (preset.length > 0) {
      Equalizer.setPreset(preset);
      setState(() {
        _selectedValue = preset;
      });
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int bandId = 0;

    return FutureBuilder<List<int>>(
      future: Equalizer.getCenterBandFreqs(),
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: snapshot.data
                        .map((freq) => _buildSliderBand(freq, bandId++))
                        .toList(),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildPresets(),
                  ),
                ],
              )
            : CircularProgressIndicator();
      },
    );
  }

  Widget _buildSliderBand(int freq, int bandId) {
    return Column(
      children: [
        SizedBox(
          height: 250.0,
          child: FutureBuilder<int>(
            future: Equalizer.getBandLevel(bandId),
            builder: (context, snapshot) {
              return FlutterSlider(
                //disabled: !widget.enabled,
                disabled: true,
                axis: Axis.vertical,
                rtl: true,
                min: min,
                max: max,
                values: [snapshot.hasData ? snapshot.data.toDouble() : 0],
                onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                  Equalizer.setBandLevel(bandId, lowerValue.toInt());
                },
              );
            },
          ),
        ),
        Text('${freq ~/ 1000} Hz'),
      ],
    );
  }

  Widget _buildPresets() {
    return FutureBuilder<List<String>>(
      future: fetchPresets,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final presets = snapshot.data;
          if (presets.isEmpty) return Text('No presets available!');
          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Available Presets',
              border: OutlineInputBorder(),
            ),
            value: _selectedValue,
            onChanged: widget.enabled
                ? (String value) {
                    Equalizer.setPreset(value);
                    setState(() {
                      _selectedValue = value;
                    });
                    sharedPreferences.setString('PRESET', value);
                  }
                : null,
            items: presets.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        } else if (snapshot.hasError)
          return Text(snapshot.error);
        else
          return CircularProgressIndicator();
      },
    );
  }
}
