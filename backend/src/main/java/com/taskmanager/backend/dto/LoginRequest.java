package com.taskmanager.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank @Email(message = "Email invalide")
        String email,

        @NotBlank(message = "Le mot de passe est requis")
        String password
) {}
