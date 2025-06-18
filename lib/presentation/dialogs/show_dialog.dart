import 'package:flutter/material.dart';
import 'package:university_events/presentation/dialogs/error_dialog.dart';

void showErrorDialog(
  BuildContext context, {
  required String? error,
}) {
  showDialog(
    context: context,
    builder: (_) => ErrorDialog(error),
  );
}
