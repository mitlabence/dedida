import 'package:dedida/SessionOrchestrator.dart';
import 'package:flutter/cupertino.dart';

class UserOverview extends StatefulWidget {
  final SessionOrchestrator sessionOrchestrator;
  const UserOverview({super.key, required this.sessionOrchestrator});

  @override
  State<UserOverview> createState() => _UserOverviewState();
}

class _UserOverviewState extends State<UserOverview> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
