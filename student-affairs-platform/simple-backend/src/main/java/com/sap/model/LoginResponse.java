package com.sap.model;

import lombok.Builder;
import lombok.Data;

import java.util.Set;

@Data
@Builder
public class LoginResponse {
    private String token;
    private Long expiresIn;
    private Long userId;
    private String username;
    private String nickname;
    private String avatar;
    private Set<String> roles;
    private Set<String> permissions;
}
