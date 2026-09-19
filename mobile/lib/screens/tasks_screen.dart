import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/task.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/app_bottom_nav.dart';
import 'login_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();
  final _pageController = PageController();
  Timer? _debounce;

  List<Task> _allTasks = [];
  bool _loading = true;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await context.read<TaskService>().fetchTasks(search: _searchController.text);
      if (!mounted) return;
      setState(() => _allTasks = tasks);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _loadTasks);
  }

  List<Task> _tasksFor(TaskStatus status) =>
      _allTasks.where((t) => t.status == status).toList(growable: false);

  Map<TaskStatus, int> get _counts => {
        for (final s in TaskStatus.values) s: _tasksFor(s).length,
      };

  Future<void> _createTask({TaskStatus? defaultStatus}) async {
    final result = await showTaskFormSheet(context, initialStatus: defaultStatus);
    if (result == null) return;
    try {
      await context.read<TaskService>().createTask(
            title: result.title,
            description: result.description,
            status: result.status,
          );
      _loadTasks();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await showTaskFormSheet(context, initial: task);
    if (result == null) return;
    try {
      await context.read<TaskService>().updateTask(
            id: task.id,
            title: result.title,
            description: result.description,
            status: result.status,
          );
      _loadTasks();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette tâche ?'),
        content: Text(task.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true) return;

    // Suppression optimiste : la carte disparaît immédiatement, rollback si l'API échoue.
    final previous = _allTasks;
    setState(() => _allTasks = _allTasks.where((t) => t.id != task.id).toList());
    try {
      await context.read<TaskService>().deleteTask(task.id);
    } on ApiException catch (e) {
      setState(() => _allTasks = previous);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// Appelé quand une tâche est déposée sur un onglet de la bottom navbar.
  Future<void> _onTaskDropped(Task task, TaskStatus newStatus) async {
    final previous = _allTasks;
    // Mise à jour optimiste : la carte change de colonne instantanément.
    setState(() {
      _allTasks = _allTasks
          .map((t) => t.id == task.id
              ? Task(
                  id: t.id,
                  title: t.title,
                  description: t.description,
                  status: newStatus,
                  createdAt: t.createdAt,
                  updatedAt: DateTime.now(),
                )
              : t)
          .toList();
    });

    try {
      await context.read<TaskService>().updateTask(
            id: task.id,
            title: task.title,
            description: task.description ?? '',
            status: newStatus,
          );
    } on ApiException catch (e) {
      setState(() => _allTasks = previous); // rollback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _logout() async {
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = kNavDestinations[_currentIndex].status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Déconnexion', onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Rechercher une tâche...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentIndex = i),
                        children: kNavDestinations.map((dest) => _buildList(dest.status)).toList(),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTask(defaultStatus: currentStatus),
        backgroundColor: AppColors.of(currentStatus),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        counts: _counts,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        },
        onTaskDropped: _onTaskDropped,
      ),
    );
  }

  Widget _buildList(TaskStatus status) {
    final tasks = _tasksFor(status);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('Aucune tâche ici', style: TextStyle(color: Colors.grey.shade400)),
            const SizedBox(height: 4),
            Text(
              'Glisse une carte sur un onglet pour la déplacer',
              style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => _editTask(task),
            onDelete: () => _deleteTask(task),
          );
        },
      ),
    );
  }
}
