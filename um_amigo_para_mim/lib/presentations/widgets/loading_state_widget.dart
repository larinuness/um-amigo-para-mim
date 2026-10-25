import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key, this.message = 'Buscando amigos...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
