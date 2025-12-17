import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/call_logs_provider.dart';

class CallLogsScreen extends ConsumerWidget {
  const CallLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callLogs = ref.watch(callLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Call Logs')),
      body: callLogs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (logs) => ListView.builder(
          itemCount: logs.length,
          itemBuilder: (_, index) {
            final log = logs[index];
            return ListTile(
              leading: const Icon(Icons.call),
              title: Text(log.name ?? log.number ?? 'Unknown'),
              subtitle: Text(
                'Duration: ${log.duration}s\nType: ${log.callType}',
              ),
              trailing: Text(
                DateTime.fromMillisecondsSinceEpoch(
                  log.timestamp ?? 0,
                ).toString(),
              ),
            );
          },
        ),
      ),
    );
  }
}
