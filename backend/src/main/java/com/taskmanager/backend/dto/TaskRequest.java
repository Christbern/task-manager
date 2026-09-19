package com.taskmanager.backend.dto;

import com.taskmanager.backend.entity.TaskStatus;
import jakarta.validation.constraints.NotBlank;

public record TaskRequest(
        @NotBlank(message = "Le titre est requis")
        String title,

        String description,

        TaskStatus status
) {}
