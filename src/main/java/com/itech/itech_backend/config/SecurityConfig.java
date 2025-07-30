package com.itech.itech_backend.config;

import com.itech.itech_backend.filter.JwtFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtFilter jwtFilter;
    
    @Value("${spring.web.cors.allowed-origins:*}")
    private String allowedOrigins;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/auth/**",
                                "/health/**",
                                "/health",
                                "/api/products/search",
                                "/api/products/category/**",
                                "/api/products/vendor/{vendorId}",
                                "/api/products/vendor1/products",
                                "/api/products/featured",
                                "/api/products/{productId}",
                                "/api/products/test/**",
                                "/categories/**",
                                "/api/categories/**",
                                "/contact/**",
                                "/api/chatbot/**",
                                "/test/**",
                                "/api/files/**",
                                "/api/gst/**",
                                "/api/pan/**",
                                "/api/vendors/**",
                                "/api/leads/**",
                                "/api/orders/**",
                                "/api/cart/**",
                                "/api/upload/**",
                                "/api/excel/**",
                                "/api/dataentry/**",
                                "/api/reviews/product/**",
                                "/api/reviews/vendor/**",
                                "/api/payments/subscription-plans",
                                "/api/content/banners",
                                "/api/content/coupons/validate/**",
                                "/api/analytics/dashboard"
                        ).permitAll()
                        .requestMatchers("/api/inquiries").hasAnyRole("USER", "VENDOR", "ADMIN")
                        .requestMatchers("/api/quotes").hasAnyRole("VENDOR", "ADMIN")
                        .requestMatchers("/api/reviews/**").hasAnyRole("USER", "ADMIN")
                        .requestMatchers("/api/support-tickets").hasAnyRole("USER", "VENDOR", "ADMIN")
                        .requestMatchers("/api/wishlist/**").hasAnyRole("USER", "ADMIN")
                        .requestMatchers("/api/payments/**").hasAnyRole("VENDOR", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/products").permitAll()
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/products").hasRole("VENDOR")
                        .requestMatchers("/api/products/vendor/my-products").hasRole("VENDOR")
                        .requestMatchers("/api/products/vendor/add").hasRole("VENDOR")
                        .requestMatchers("/api/products/*/images").hasRole("VENDOR")
                        .requestMatchers("/api/products/*/status").hasRole("VENDOR")
                        .requestMatchers("/api/products/*/approve").hasRole("ADMIN")
                        .requestMatchers("/api/products/*/feature").hasRole("ADMIN")
                        .requestMatchers("/api/products/pending-approval").hasRole("ADMIN")
                        .requestMatchers("/admin/**").hasRole("ADMIN")
                        .requestMatchers("/vendor/**").hasAnyRole("VENDOR", "ADMIN")
                        .requestMatchers("/user/**").hasAnyRole("USER", "ADMIN")
                        .anyRequest().authenticated()
                )
                .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Use environment variable for allowed origins, fallback to wildcard
        if (allowedOrigins != null && !allowedOrigins.equals("*")) {
            List<String> origins = Arrays.asList(allowedOrigins.split(","));
            configuration.setAllowedOrigins(origins);
        } else {
            configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        }
        
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L); // 1 hour
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
