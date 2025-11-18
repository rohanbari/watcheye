import 'package:flutter/material.dart';
import 'package:watcheye/constants.dart';
import 'package:watcheye/controllers/monitoring_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMonitoring = false;

  final MonitoringController _monitoringController = MonitoringController();

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
            Text(
              _isMonitoring
                  ? 'I\'m active! Sleep peacefully 👁️'
                  : 'Currently inactive 😴',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMonitoring,
        child: Icon(_fabIconData),
      ),
    );
  }

  IconData get _fabIconData => _isMonitoring
      ? Icons.back_hand_outlined
      : Icons.notification_add_outlined;

  void _toggleMonitoring() async {
    final newState = await _monitoringController.toggleMonitoring(
      _isMonitoring,
    );
    if (mounted) {
      setState(() {
        _isMonitoring = newState;
      });
    }
  }

  @override
  void dispose() {
    _monitoringController.dispose();
    super.dispose();
  }
}
