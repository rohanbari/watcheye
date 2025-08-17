/*
 * Copyright (c) 2025 Rohan Bari <rohanbari@outlook.com>
 */

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:watcheye/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isActive = false;
  bool _isBeep = false;
  Icon icon = Icon(Icons.notification_add_outlined);

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<UserAccelerometerEvent>? _streamSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.appName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('STATUS', style: Theme.of(context).textTheme.titleSmall),
            Text(_isActive ? 'Sleep peacefully 👁️' : 'Currently inactive 😴'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isActive = !_isActive;
            if (_isActive) {
              _initMonitoring();
            }

            icon = Icon(
              _isActive
                  ? Icons.back_hand_outlined
                  : Icons.notification_add_outlined,
            );
          });
        },
        child: icon,
      ),
    );
  }

  void _initMonitoring() {
    _streamSubscription = userAccelerometerEventStream().listen((event) {
      double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > 12 && _isActive) {
        _triggerBeep();
      }
    });
  }

  void _triggerBeep() async {
    if (_isBeep) {
      return;
    } else {
      _isBeep = true;
    }

    await _audioPlayer.play(AssetSource('security_alarm.mp3'));
    _isBeep = false;
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
