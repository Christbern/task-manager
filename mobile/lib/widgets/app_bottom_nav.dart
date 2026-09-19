import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/task.dart';

class NavDestinationData {
  final TaskStatus status;
  final IconData icon;
  final String label;
  const NavDestinationData(this.status, this.icon, this.label);
}

const kNavDestinations = [
  NavDestinationData(TaskStatus.todo, Icons.radio_button_unchecked, 'À faire'),
  NavDestinationData(TaskStatus.inProgress, Icons.autorenew, 'En cours'),
  NavDestinationData(TaskStatus.done, Icons.check_circle_outline, 'Terminée'),
];

/// Bottom navbar stylée : chaque onglet est aussi une DragTarget — on peut y
/// déposer une tâche glissée depuis la liste pour changer son statut instantanément.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Map<TaskStatus, int> counts;
  final ValueChanged<int> onTap;
  final void Function(Task task, TaskStatus newStatus) onTaskDropped;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.counts,
    required this.onTap,
    required this.onTaskDropped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(kNavDestinations.length, (index) {
            final dest = kNavDestinations[index];
            final isActive = index == currentIndex;
            final count = counts[dest.status] ?? 0;

            return Expanded(
              child: DragTarget<Task>(
                onWillAcceptWithDetails: (details) => details.data.status != dest.status,
                onAcceptWithDetails: (details) => onTaskDropped(details.data, dest.status),
                builder: (context, candidateData, rejectedData) {
                  final isHovering = candidateData.isNotEmpty;
                  return GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? AppColors.of(dest.status).withOpacity(0.15)
                            : (isActive ? AppColors.bgOf(dest.status) : Colors.transparent),
                        borderRadius: BorderRadius.circular(14),
                        border: isHovering
                            ? Border.all(color: AppColors.of(dest.status), width: 1.5)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                dest.icon,
                                size: 22,
                                color: (isActive || isHovering) ? AppColors.of(dest.status) : Colors.grey.shade400,
                              ),
                              if (count > 0)
                                Positioned(
                                  right: -8,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHovering ? 'Déposer ici' : dest.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isActive || isHovering ? FontWeight.w700 : FontWeight.w500,
                              color: (isActive || isHovering) ? AppColors.of(dest.status) : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
