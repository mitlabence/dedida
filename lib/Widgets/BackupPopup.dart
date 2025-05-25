import 'package:flutter/material.dart';

void showBackupDialog(
    BuildContext context, Future<void> Function() backupFunction) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside the dialog
    builder: (BuildContext context) {
      bool isBackingUp = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Backup"),
            content: isBackingUp
                ? Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text("Backup in progress..."),
                    ],
                  )
                : Text("Do you want to back up your data?"),
            actions: [
              TextButton(
                onPressed:
                    isBackingUp ? null : () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: isBackingUp
                    ? null
                    : () async {
                        setState(() {
                          isBackingUp = true;
                        });
                        await backupFunction(); // Call your async backup function
                        setState(() {
                          isBackingUp = false;
                        });
                        Navigator.of(context).pop(); // Close the popup
                      },
                child: Text("Backup"),
              ),
            ],
          );
        },
      );
    },
  );
}
