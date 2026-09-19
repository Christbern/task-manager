import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'screens/login_screen.dart';
import 'screens/tasks_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nécessaire pour DateFormat('d MMM', 'fr_FR') utilisé sur les cartes de tâches.
  await initializeDateFormatting('fr_FR', null);

  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthService(apiClient)),
        Provider(create: (_) => TaskService(apiClient)),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.initialized) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: auth.isAuthenticated
                ? const TasksScreen(key: ValueKey('tasks'))
                : const LoginScreen(key: ValueKey('login')),
          );
        },
      ),
    );
  }
}
