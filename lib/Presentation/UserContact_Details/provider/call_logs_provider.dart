import 'package:call_log/call_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callLogsProvider = FutureProvider<List<CallLogEntry>>((ref) async {
  final logs = await CallLog.get();
  return logs.toList();
});
