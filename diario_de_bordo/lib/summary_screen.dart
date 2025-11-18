import 'package:flutter/material.dart';
import 'database_helper.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late Future<Map<String, Duration>> _summaryData;

  @override
  void initState() {
    super.initState();
    _summaryData = _getSummaryData();
  }

  Future<Map<String, Duration>> _getSummaryData() async {
    final now = DateTime.now();
    final dailyLogs = await DatabaseHelper().getDailyLogs(now);
    final weeklyLogs = await DatabaseHelper().getWeeklyLogs(now);

    Duration dailyDriving = Duration.zero;
    Duration dailyResting = Duration.zero;
    for (final log in dailyLogs) {
      if (log.status == 'Dirigindo') {
        dailyDriving += Duration(milliseconds: log.endTime - log.startTime);
      } else {
        dailyResting += Duration(milliseconds: log.endTime - log.startTime);
      }
    }

    Duration weeklyDriving = Duration.zero;
    Duration weeklyResting = Duration.zero;
    for (final log in weeklyLogs) {
      if (log.status == 'Dirigindo') {
        weeklyDriving += Duration(milliseconds: log.endTime - log.startTime);
      } else {
        weeklyResting += Duration(milliseconds: log.endTime - log.startTime);
      }
    }

    return {
      'dailyDriving': dailyDriving,
      'dailyResting': dailyResting,
      'weeklyDriving': weeklyDriving,
      'weeklyResting': weeklyResting,
    };
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
      ),
      body: FutureBuilder<Map<String, Duration>>(
        future: _summaryData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nenhum dado encontrado'));
          }

          final summary = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Resumo Diário:',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  'Condução: ${_formatDuration(summary['dailyDriving']!)}\nDescanso: ${_formatDuration(summary['dailyResting']!)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Resumo Semanal:',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  'Condução: ${_formatDuration(summary['weeklyDriving']!)}\nDescanso: ${_formatDuration(summary['weeklyResting']!)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
