import 'package:dio/dio.dart';
import '../models/task.dart';
import 'api_client.dart';

class TaskService {
  final ApiClient _apiClient;
  TaskService(this._apiClient);

  Future<List<Task>> fetchTasks({TaskStatus? status, String? search}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status.toJson();
      if (search != null && search.trim().isNotEmpty) params['search'] = search.trim();

      final response = await _apiClient.dio.get('/api/tasks', queryParameters: params);
      return (response.data as List)
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(ApiClient.readableError(e));
    }
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required TaskStatus status,
  }) async {
    try {
      final response = await _apiClient.dio.post('/api/tasks', data: {
        'title': title,
        'description': description,
        'status': status.toJson(),
      });
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.readableError(e));
    }
  }

  Future<Task> updateTask({
    required int id,
    required String title,
    required String description,
    required TaskStatus status,
  }) async {
    try {
      final response = await _apiClient.dio.put('/api/tasks/$id', data: {
        'title': title,
        'description': description,
        'status': status.toJson(),
      });
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.readableError(e));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiClient.dio.delete('/api/tasks/$id');
    } on DioException catch (e) {
      throw ApiException(ApiClient.readableError(e));
    }
  }
}
