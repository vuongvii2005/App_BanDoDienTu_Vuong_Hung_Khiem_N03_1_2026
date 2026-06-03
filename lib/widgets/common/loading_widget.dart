import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!,
                style: const TextStyle(color: AppTheme.grey, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
