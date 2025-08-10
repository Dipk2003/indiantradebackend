package com.itech.itech_backend.modules.shared.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.itech.itech_backend.modules.buyer.model.Product;
import com.itech.itech_backend.modules.core.model.User;
import com.itech.itech_backend.modules.buyer.repository.BuyerProductRepository;
import com.itech.itech_backend.modules.buyer.repository.OrderRepository;
import com.itech.itech_backend.modules.buyer.repository.ReviewRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class OpenAiService {

    @Value("${openai.api.key}")
    private String apiKey;

    @Value("${openai.api.url}")
    private String apiUrl;
    
    @Autowired
    private BuyerProductRepository productRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private ReviewRepository reviewRepository;

    public String generateResponse(String userMessage) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "gpt-3.5-turbo");

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of("role", "system", "content", "You are an assistant for vendor and product recommendations."));
        messages.add(Map.of("role", "user", "content", userMessage));

        requestBody.put("messages", messages);
        requestBody.put("temperature", 0.7);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

        try {
            @SuppressWarnings("rawtypes")
            ResponseEntity<Map> response = restTemplate.postForEntity(apiUrl, request, Map.class);
            @SuppressWarnings("unchecked")
            Map<String, Object> responseBody = (Map<String, Object>) response.getBody();
            if (responseBody != null) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> choices = (List<Map<String, Object>>) responseBody.get("choices");
                if (choices != null && !choices.isEmpty()) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                    if (message != null) {
                        return (String) message.get("content");
                    }
                }
            }
        } catch (Exception e) {
            log.error("OpenAI error: {}", e.getMessage());
        }

        return "Sorry, I couldn't understand that.";
    }
    
    /**
     * Generate AI-powered product recommendations based on user preferences
     */
    public List<Product> getAIProductRecommendations(User user, String query, int limit) {
        try {
            // Get user's purchase history for context
            String userContext = buildUserContext(user);
            
            // Create AI prompt for product recommendations
            String prompt = String.format(
                "Based on the following user context and query, recommend products from our marketplace:\n\n" +
                "User Context: %s\n\n" +
                "User Query: %s\n\n" +
                "Available Product Categories: Medical Equipment, Laboratory Supplies, Pharmaceuticals, Surgical Instruments, Diagnostic Tools\n\n" +
                "Please provide product recommendations in JSON format with reasoning.",
                userContext, query
            );
            
            String aiResponse = generateResponse(prompt);
            
            // Parse AI response and match with actual products
            List<Product> recommendations = matchProductsFromAIResponse(aiResponse, limit);
            
            // If AI recommendations are insufficient, fall back to collaborative filtering
            if (recommendations.size() < limit) {
                List<Product> fallbackProducts = getCollaborativeFilteringRecommendations(user, limit - recommendations.size());
                recommendations.addAll(fallbackProducts);
            }
            
            return recommendations.stream().distinct().limit(limit).collect(Collectors.toList());
            
        } catch (Exception e) {
            log.error("Error generating AI recommendations: {}", e.getMessage());
            // Fallback to basic recommendations
            return getBasicRecommendations(limit);
        }
    }
    
    /**
     * Generate smart search suggestions using AI
     */
    public List<String> getAISearchSuggestions(String partialQuery) {
        try {
            String prompt = String.format(
                "Given the partial search query '%s' for a B2B medical equipment marketplace, " +
                "suggest 5 complete search terms that buyers might be looking for. " +
                "Focus on medical equipment, laboratory supplies, pharmaceuticals, and healthcare products. " +
                "Return only the suggestions, one per line.",
                partialQuery
            );
            
            String response = generateResponse(prompt);
            
            return List.of(response.split("\n"))
                .stream()
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .limit(5)
                .collect(Collectors.toList());
                
        } catch (Exception e) {
            log.error("Error generating search suggestions: {}", e.getMessage());
            return getBasicSearchSuggestions(partialQuery);
        }
    }
    
    /**
     * Generate product descriptions using AI
     */
    public String generateProductDescription(String productName, String category, String features) {
        try {
            String prompt = String.format(
                "Generate a professional product description for a B2B medical marketplace:\n\n" +
                "Product Name: %s\n" +
                "Category: %s\n" +
                "Key Features: %s\n\n" +
                "Create a compelling, professional description that highlights benefits for healthcare professionals. " +
                "Include technical specifications and compliance information where relevant. " +
                "Keep it between 150-250 words.",
                productName, category, features
            );
            
            return generateResponse(prompt);
            
        } catch (Exception e) {
            log.error("Error generating product description: {}", e.getMessage());
            return "Professional medical equipment designed for healthcare facilities.";
        }
    }
    
    private String buildUserContext(User user) {
        StringBuilder context = new StringBuilder();
        
        // Add user role and preferences
        context.append("User Role: ").append(user.getRole() != null ? user.getRole() : "USER").append("\n");
        
        // Add purchase history context (simplified)
        try {
            long orderCount = orderRepository.countByUserId(user.getId());
            context.append("Previous Orders: ").append(orderCount).append("\n");
            
            // Add recent product categories if available
            // This would need more specific repository methods
            context.append("Preferred Categories: Medical Equipment, Laboratory Supplies\n");
            
        } catch (Exception e) {
            log.warn("Could not build complete user context: {}", e.getMessage());
        }
        
        return context.toString();
    }
    
    private List<Product> matchProductsFromAIResponse(String aiResponse, int limit) {
        List<Product> products = new ArrayList<>();
        
        try {
            // Extract product keywords from AI response
            String[] keywords = extractKeywordsFromResponse(aiResponse);
            
            // Search for products matching these keywords
            for (String keyword : keywords) {
                List<Product> matchingProducts = productRepository.findByNameContainingIgnoreCase(keyword);
                products.addAll(matchingProducts);
                
                if (products.size() >= limit) {
                    break;
                }
            }
            
        } catch (Exception e) {
            log.error("Error matching products from AI response: {}", e.getMessage());
        }
        
        return products.stream().distinct().limit(limit).collect(Collectors.toList());
    }
    
    private String[] extractKeywordsFromResponse(String response) {
        // Simple keyword extraction - in a real implementation, this would be more sophisticated
        return response.toLowerCase()
            .replaceAll("[^a-zA-Z\s]", "")
            .split("\s+");
    }
    
    private List<Product> getCollaborativeFilteringRecommendations(User user, int limit) {
        // Simplified collaborative filtering - recommend popular products
        try {
            return productRepository.findTopRatedProducts(PageRequest.of(0, limit));
        } catch (Exception e) {
            log.error("Error in collaborative filtering: {}", e.getMessage());
            return new ArrayList<>();
        }
    }
    
    private List<Product> getBasicRecommendations(int limit) {
        try {
            return productRepository.findTopRatedProducts(PageRequest.of(0, limit));
        } catch (Exception e) {
            log.error("Error getting basic recommendations: {}", e.getMessage());
            return new ArrayList<>();
        }
    }
    
    private List<String> getBasicSearchSuggestions(String partialQuery) {
        // Basic fallback suggestions
        return List.of(
            "Medical Equipment",
            "Laboratory Supplies",
            "Surgical Instruments",
            "Diagnostic Tools",
            "Pharmaceutical Products"
        ).stream()
            .filter(s -> s.toLowerCase().contains(partialQuery.toLowerCase()))
            .collect(Collectors.toList());
    }
}

