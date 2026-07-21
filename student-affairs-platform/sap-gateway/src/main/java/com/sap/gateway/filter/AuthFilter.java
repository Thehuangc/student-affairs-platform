package com.sap.gateway.filter;

import com.sap.gateway.config.GatewayConfig;
import com.sap.gateway.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * 全局鉴权过滤器
 */
@Slf4j
@Component
public class AuthFilter implements GlobalFilter, Ordered {

    @Autowired
    private GatewayConfig gatewayConfig;

    @Autowired
    private JwtUtil jwtUtil;

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();

        // 白名单路径直接放行
        if (isWhiteListed(path)) {
            return chain.filter(exchange);
        }

        // 获取Token
        String token = getToken(request);
        if (token == null || token.isEmpty()) {
            return unauthorizedResponse(exchange, "令牌不能为空");
        }

        // 验证Token
        try {
            if (jwtUtil.isTokenExpired(token)) {
                return unauthorizedResponse(exchange, "令牌已过期");
            }

            // 解析Token获取用户信息
            Long userId = jwtUtil.getUserId(token);
            String username = jwtUtil.getUsername(token);

            // 将用户信息放入请求头传递给下游服务
            ServerHttpRequest mutatedRequest = request.mutate()
                    .header("X-User-Id", String.valueOf(userId))
                    .header("X-Username", username)
                    .build();

            return chain.filter(exchange.mutate().request(mutatedRequest).build());
        } catch (Exception e) {
            log.error("令牌解析失败: {}", e.getMessage());
            return unauthorizedResponse(exchange, "令牌无效");
        }
    }

    /**
     * 判断是否在白名单中
     */
    private boolean isWhiteListed(String path) {
        List<String> whiteList = gatewayConfig.getWhiteList();
        if (whiteList == null || whiteList.isEmpty()) {
            return false;
        }
        return whiteList.stream().anyMatch(pattern -> pathMatcher.match(pattern, path));
    }

    /**
     * 获取Token
     */
    private String getToken(ServerHttpRequest request) {
        String authorization = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        // 也支持从参数中获取Token
        String token = request.getQueryParams().getFirst("token");
        if (token != null && !token.isEmpty()) {
            return token;
        }
        return null;
    }

    /**
     * 未授权响应
     */
    private Mono<Void> unauthorizedResponse(ServerWebExchange exchange, String message) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);
        String body = "{\"code\":401,\"msg\":\"" + message + "\",\"data\":null}";
        DataBuffer buffer = response.bufferFactory().wrap(body.getBytes(StandardCharsets.UTF_8));
        return response.writeWith(Mono.just(buffer));
    }

    @Override
    public int getOrder() {
        return -100;
    }
}
