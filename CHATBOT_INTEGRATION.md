# Enhanced Chatbot Integration

## Overview
Your iTech backend now includes advanced AI-powered chatbot functionality with OpenAI GPT-3.5-turbo integration.

## New Features Added

### 🤖 OpenAI Integration
- **Advanced AI Responses**: For queries that don't match predefined patterns, the chatbot now uses OpenAI GPT-3.5-turbo for intelligent responses
- **Natural Language Processing**: Better understanding of complex user queries
- **Context-Aware Conversations**: More natural and helpful interactions

### 🔧 New Components Added

#### 1. OpenAiService
- **Location**: `src/main/java/com/itech/itech_backend/service/OpenAiService.java`
- **Features**:
  - GPT-3.5-turbo integration
  - Configurable temperature and model settings
  - Error handling and fallback responses
  - System prompts for vendor/product recommendations

#### 2. Enhanced ChatbotService
- **Enhanced with**:
  - OpenAI fallback for unrecognized queries
  - `startSession()` method for session initialization
  - Improved response generation logic

### ⚙️ Configuration

#### OpenAI Settings (in `application.properties`)
```properties
# OpenAI Configuration
openai.api.key=${OPENAI_API_KEY:your-openai-api-key-here}
openai.api.url=https://api.openai.com/v1/chat/completions
```

**⚠️ Important**: Set the `OPENAI_API_KEY` environment variable with your own OpenAI API key.

## How It Works

### 1. Query Processing Flow
```
User Message → Pattern Matching → Response Generation
    ↓
    Product Query? → Vendor Recommendations
    ↓
    Service Query? → Service Provider Recommendations  
    ↓
    Greeting? → Welcome Message
    ↓
    Help Query? → Help Instructions
    ↓
    Other? → OpenAI GPT Response ✨ (NEW!)
```

### 2. Predefined Patterns Still Supported
- **Product Queries**: "product", "item", "buy", "purchase", "price", "cost", "sell", "selling", "available", "stock"
- **Service Queries**: "service", "provider", "company", "business", "offer", "provides", "specializes", "expert", "professional"
- **Greetings**: "hi", "hello", "hey", "good morning", "good afternoon", "good evening"
- **Help Queries**: "help", "assist", "support", "how to", "what can", "options", "menu"

### 3. AI-Enhanced Responses
For any query that doesn't match the above patterns, the chatbot now uses OpenAI to generate contextually appropriate responses focused on vendor and product recommendations.

## API Endpoints

All existing endpoints remain the same:

- `POST /api/chatbot/chat` - Send a message to the chatbot
- `POST /api/chatbot/start-session` - Start a new chat session
- `GET /api/chatbot/history/{sessionId}` - Get chat history
- `GET /api/chatbot/health` - Health check

### Admin Endpoints:
- `GET /admin/chatbot/analytics` - Get chatbot analytics
- `GET /admin/chatbot/conversations` - Get all conversations
- `GET /admin/chatbot/conversation/{sessionId}` - Get specific conversation
- `DELETE /admin/chatbot/conversation/{sessionId}` - Delete conversation
- `GET /admin/chatbot/recent-queries` - Get recent queries

## Testing the Integration

### Sample Requests

#### 1. General AI Query (NEW!)
```json
POST /api/chatbot/chat
{
  "message": "What are the benefits of working with premium vendors?",
  "sessionId": "test-session-123"
}
```

#### 2. Product Query (Enhanced)
```json
POST /api/chatbot/chat
{
  "message": "I need electronics products",
  "sessionId": "test-session-123"
}
```

#### 3. Service Query (Enhanced)  
```json
POST /api/chatbot/chat
{
  "message": "Who provides web development services?",
  "sessionId": "test-session-123"
}
```

## Benefits of the Integration

### ✅ Enhanced User Experience
- More natural conversations
- Better handling of complex queries
- Contextually appropriate responses

### ✅ Improved Business Logic
- Still prioritizes vendor recommendations
- Maintains existing functionality
- Adds AI intelligence as a fallback

### ✅ Scalable Architecture
- Easy to update AI models
- Configurable through properties
- Robust error handling

## Troubleshooting

### Common Issues:

1. **OpenAI API Key Issues**
   - Ensure your API key is valid and has credits
   - Check the `openai.api.key` in `application.properties`

2. **Network Issues**
   - Verify internet connectivity
   - Check firewall settings for outbound HTTPS requests

3. **Rate Limiting**
   - OpenAI has rate limits based on your plan
   - The service includes error handling for API failures

### Fallback Behavior
If OpenAI service fails, the chatbot will return: "Sorry, I couldn't understand that." and continue working with predefined patterns.

## Next Steps

1. **Replace OpenAI API Key**: Update with your own API key in production
2. **Test All Scenarios**: Verify both AI responses and vendor recommendations
3. **Monitor Usage**: Track OpenAI API usage and costs
4. **Customize System Prompts**: Modify the system prompt in OpenAiService for your specific use case

Your chatbot is now significantly more intelligent and capable of handling a wide variety of user queries!
