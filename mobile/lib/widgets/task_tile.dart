import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({super.key, required this.task, required this.onEdit, required this.onDelete});

  Color _statusColor(BuildContext context) {
    switch (task.status) {
      case TaskStatus.todo:
        return Colors.grey.shade400;
      case TaskStatus.inProgress:
        return Theme.of(context).colorScheme.primary;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(task.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        leading: CircleAvatar(
          radius: 6,
          backgroundColor: _statusColor(context),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(task.status.label), visualDensity: VisualDensity.compact),
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
