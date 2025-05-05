import 'package:flutter/material.dart';
import 'widgets/resource_list_view.dart';
import 'widgets/empty_resource_message.dart';

class ResourceListPage extends StatelessWidget {
  const ResourceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasResources = true; // TODO: 상태 연동

    return Scaffold(
      appBar: AppBar(title: const Text('자료실')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            hasResources
                ? const ResourceListView()
                : const EmptyResourceMessage(),
      ),
    );
  }
}
