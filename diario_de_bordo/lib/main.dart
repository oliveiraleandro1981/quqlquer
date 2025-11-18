import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const DrivingLogApp());

class DrivingLogApp extends StatelessWidget {
  const DrivingLogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diário de Bordo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LogScreen(),
    );
  }
}

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _formattedTime = '00:00:00';
  String _status = 'Parado';
  bool _isRunning = false;

  void _startDriving() {
    setState(() {
      _status = 'Dirigindo';
      _isRunning = true;
    });
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  void _startResting() {
    setState(() {
      _status = 'Descansando';
      _isRunning = true;
    });
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  void _stopTimer() {
    setState(() {
      _status = 'Parado';
      _isRunning = false;
    });
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _updateTime(null);
  }

  void _updateTime(Timer? timer) {
    final elapsed = _stopwatch.elapsed;
    setState(() {
      _formattedTime =
          '${elapsed.inHours.toString().padLeft(2, '0')}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    });

    if (_status == 'Dirigindo' && elapsed.inSeconds == 18900) {
      // 5.5 hours = 19800 seconds. Alert at 5 hours and 15 minutes (18900 seconds).
      print('Alerta: Limite de condução se aproximando!');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Bordo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tempo Decorrido:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _formattedTime,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Status: $_status',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton(
                    onPressed: _startDriving,
                    child: const Text('Iniciar Condução'),
                  ),
                if (!_isRunning)
                  const SizedBox(width: 20),
                if (!_isRunning)
                  ElevatedButton(
                    onPressed: _startResting,
                    child: const Text('Iniciar Descanso'),
                  ),
                if (_isRunning)
                  ElevatedButton(
                    onPressed: _stopTimer,
                    child: const Text('Parar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
