import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({super.key, required this.task, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      delay: const Duration(milliseconds: 180),
      feedback: TaskCardDragFeedback(task: task),
      childWhenDragging: Opacity(opacity: 0.35, child: _buildCard(context)),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // La suppression réelle passe par l'API ; on ne laisse pas Flutter retirer le widget seul.
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 34,
                      margin: const EdgeInsets.only(right: 10, top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.of(task.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (task.description != null && task.description!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              task.description!,
                              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('d MMM', 'fr_FR').format(task.updatedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Version compacte affichée sous le doigt pendant le drag (feedback visuel).
class TaskCardDragFeedback extends StatelessWidget {
  final Task task;
  const TaskCardDragFeedback({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 28,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColors.of(task.status),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
