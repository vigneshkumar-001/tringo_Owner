import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Presentation/Register/controller/owner_info_notifier.dart';

class OwnerInfoScreen extends ConsumerStatefulWidget {
  const OwnerInfoScreen({super.key});

  @override
  ConsumerState<OwnerInfoScreen> createState() => _OwnerInfoScreenState();
}

class _OwnerInfoScreenState extends ConsumerState<OwnerInfoScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerInfoNotifierProvider);
    final notifier = ref.read(ownerInfoNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Owner Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notifier.insertOwnerInfo(phoneController.text);
              },
              child: state.isLoading
                  ? CircularProgressIndicator()
                  : Text('Submit'),
            ),
            SizedBox(height: 20),

            if (state.error.isNotEmpty)
              Text(state.error, style: TextStyle(color: Colors.red)),
            if (state.response != null)
              Text(
                'Success: ${state.response!.success}\nMessage: ${state.response!.message}',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
