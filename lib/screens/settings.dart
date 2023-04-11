import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool music = true;
  bool effects = true;

  @override
  void initState() {
    super.initState();
    getMusic();
    getEffects();
  }

  void setMusic(newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('music', newValue!);
    setState(() {
      music = newValue!;
    });
  }

  void setEffects(newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('effects', newValue!);
    setState(() {
      effects = newValue!;
    });
  }

  void getMusic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool newValue = prefs.getBool('music') ?? true;
    setState(() {
      music = newValue;
    });
  }

  void getEffects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool newValue = prefs.getBool('effects') ?? true;
    setState(() {
      effects = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text("Music"),
              value: music,
              onChanged: (newValue) {
                setMusic(newValue);
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text("Effects"),
              value: effects,
              onChanged: (newValue) {
                setEffects(newValue);
              },
              controlAffinity: ListTileControlAffinity.leading,
            )
          ],
        ),
      ),
    );
  }
}
