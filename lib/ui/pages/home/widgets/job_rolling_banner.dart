import 'package:flutter/material.dart';

class JobRollingBanner extends StatelessWidget {
  const JobRollingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.blue[100],
      child: const Center(child: Text('공채정보 롤링배너')),
    );
  }
}
