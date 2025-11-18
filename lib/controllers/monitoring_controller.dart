import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:watcheye/constants.dart';

/// Encapsulates accelerometer monitoring and alarm playback.
class MonitoringController {
  bool _isBeeping = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<UserAccelerometerEvent>? _streamSubscription;

  /// Toggle monitoring based on the current UI state.
  /// Returns the new monitoring state to be reflected by the caller.
  Future<bool> toggleMonitoring(bool currentlyMonitoring) async {
    if (currentlyMonitoring) {
      _stopMonitoring();
      return false;
    } else {
      _startMonitoring();
      return true;
    }
  }

  void _startMonitoring() {
    if (_streamSubscription != null) return;
    _streamSubscription = userAccelerometerEventStream().listen(
      _onAccelerometerEvent,
    );
  }

  void _stopMonitoring() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _stopAlarm();
  }

  void _onAccelerometerEvent(UserAccelerometerEvent event) {
    final double magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (magnitude > Constants.senseCoefficient) {
      _triggerBeepIfNeeded();
    }
  }

  void _triggerBeepIfNeeded() {
    if (_isBeeping) return;
    _playAlarm();
  }

  Future<void> _playAlarm() async {
    _isBeeping = true;
    try {
      await _audioPlayer.play(AssetSource('security_alarm.mp3'));
    } catch (_) {
      // Fail silently to keep the caller UI responsive.
    } finally {
      _isBeeping = false;
    }
  }

  Future<void> _stopAlarm() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // ignore stop errors
    } finally {
      _isBeeping = false;
    }
  }

  /// Clean up resources when the controller is no longer needed.
  void dispose() {
    _streamSubscription?.cancel();
    _audioPlayer.dispose();
  }
}
