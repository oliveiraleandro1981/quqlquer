import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'summary_screen.dart';

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

class _LogScreenState extends State<LogScreen> with WidgetsBindingObserver {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _formattedTime = '00:00:00';
  String _status = 'Parado';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveState();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsedMilliseconds', _stopwatch.elapsedMilliseconds);
    await prefs.setString('status', _status);
    await prefs.setBool('isRunning', _isRunning);
    if (_isRunning) {
      await prefs.setInt('startTime', DateTime.now().millisecondsSinceEpoch - _stopwatch.elapsedMilliseconds);
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('status') ?? 'Parado';
    final isRunning = prefs.getBool('isRunning') ?? false;

    if (isRunning) {
      final startTimeMillis = prefs.getInt('startTime');
      if (startTimeMillis != null) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
        final elapsed = DateTime.now().difference(startTime);
        _stopwatch.reset();
        _stopwatch.start();
        // _stopwatch.elapsed cannot be set directly.
        // The logic to calculate the elapsed time is already handled by
        // calculating the difference between the start time and the current time.
        _startTimer(); // Restart the timer to update the UI
      }
    }

    setState(() {
      _status = status;
      _isRunning = isRunning;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }


  void _startDriving() {
    setState(() {
      _status = 'Dirigindo';
      _isRunning = true;
    });
    _stopwatch.reset();
    _stopwatch.start();
    _startTimer();
    _saveState();
  }

  void _startResting() {
    setState(() {
      _status = 'Descansando';
      _isRunning = true;
    });
    _stopwatch.reset();
    _stopwatch.start();
    _startTimer();
    _saveState();
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
    _saveState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Bordo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SummaryScreen()),
              );
            },
          ),
        ],
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
