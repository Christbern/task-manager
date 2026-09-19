package com.taskmanager.backend.service;

import com.taskmanager.backend.dto.TaskRequest;
import com.taskmanager.backend.dto.TaskResponse;
import com.taskmanager.backend.entity.Task;
import com.taskmanager.backend.entity.TaskStatus;
import com.taskmanager.backend.entity.User;
import com.taskmanager.backend.exception.ResourceNotFoundException;
import com.taskmanager.backend.repository.TaskRepository;
import com.taskmanager.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    public List<TaskResponse> listTasks(String userEmail, TaskStatus status, String search) {
        User user = getUser(userEmail);
        return taskRepository.search(user, status, search).stream()
                .map(TaskResponse::fromEntity)
                .toList();
    }

    public TaskResponse createTask(String userEmail, TaskRequest request) {
        User user = getUser(userEmail);

        Task task = Task.builder()
                .title(request.title())
                .description(request.description())
                .status(request.status() != null ? request.status() : TaskStatus.TODO)
                .user(user)
                .build();

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    public TaskResponse updateTask(String userEmail, Long taskId, TaskRequest request) {
        User user = getUser(userEmail);
        Task task = getOwnedTask(taskId, user);

        task.setTitle(request.title());
        task.setDescription(request.description());
        if (request.status() != null) {
            task.setStatus(request.status());
        }

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    public void deleteTask(String userEmail, Long taskId) {
        User user = getUser(userEmail);
        Task task = getOwnedTask(taskId, user);
        taskRepository.delete(task);
    }

    private User getUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur introuvable"));
    }

    // Empêche un utilisateur d'accéder/modifier les tâches d'un autre utilisateur.
    private Task getOwnedTask(Long taskId, User user) {
        return taskRepository.findByIdAndUser(taskId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Tâche introuvable"));
    }
}
