# Keep-Alive Service Guide 🚀

## Overview

The Keep-Alive Service prevents your Render backend from going to sleep due to inactivity. Render's free tier puts services to sleep after 15 minutes of no incoming requests, causing cold starts that can take 30-60 seconds to wake up.

## How It Works

### 🔄 Automatic Pings
- **External Ping**: Every 14 minutes, the service pings itself at `https://indiantradebackend.onrender.com/health`
- **Self Ping**: Every 5 minutes, internal health check (backup mechanism)
- **Status Logging**: Hourly status reports in logs

### 📊 Smart Logging
- Keep-alive pings are logged as INFO level
- Regular health checks are logged as DEBUG
- Java User-Agent requests are identified as keep-alive pings
- Client IP addresses are tracked for monitoring

## Configuration

### Environment Variables
```properties
# Enable/disable keep-alive service
app.keep-alive.enabled=true

# Ping interval (14 minutes in milliseconds)
app.keep-alive.interval=840000

# Self-ping interval (5 minutes)
app.keep-alive.self-ping-interval=300000

# Your Render service URL
app.render.url=https://indiantradebackend.onrender.com
```

### Memory Optimization
The service is optimized for Render's 512MB memory limit:

**Development/Production:**
- Core threads: 2-3
- Max threads: 5-8
- Queue capacity: 100-200

**Render (Memory Optimized):**
- Core threads: 1
- Max threads: 2
- Queue capacity: 50

## Endpoints

### Health Check Endpoints

#### `/health`
Simple health check optimized for keep-alive pings:
```json
{
  "status": "UP",
  "application": "itech-backend",
  "timestamp": "2025-09-30 19:00:00",
  "keepAliveEnabled": true,
  "message": "Service is healthy and running"
}
```

#### `/api/health`
Detailed health status with system information:
```json
{
  "status": "UP",
  "application": "itech-backend",
  "timestamp": "2025-09-30 19:00:00",
  "keepAliveService": "ACTIVE",
  "version": "1.0.0",
  "environment": "production",
  "system": {
    "javaVersion": "11.0.x",
    "freeMemory": 268435456,
    "totalMemory": 536870912,
    "maxMemory": 536870912,
    "availableProcessors": 1
  }
}
```

#### `/keep-alive/status`
Keep-alive service specific status:
```json
{
  "keepAliveEnabled": true,
  "status": "ACTIVE",
  "message": "Keep-Alive service is preventing the application from sleeping",
  "timestamp": "2025-09-30 19:00:00"
}
```

#### `/`
Root endpoint with basic service info:
```json
{
  "service": "itech-backend",
  "status": "Running",
  "message": "IndianTradeMart Backend API is live!",
  "timestamp": "2025-09-30 19:00:00"
}
```

## Service Behavior

### Timing Strategy
- **14 minutes**: Just before Render's 15-minute sleep timeout
- **5 minutes**: Self-ping for internal health monitoring
- **1 hour**: Status logging for monitoring

### Error Handling
- If primary health endpoint fails, tries root endpoint as backup
- All failures are logged but don't stop the service
- Self-ping failures are logged as DEBUG (normal in some deployments)

### Performance Impact
- Minimal CPU usage (scheduled tasks)
- Low memory footprint (optimized for Render)
- Network overhead: ~1KB per ping every 14 minutes

## Logs to Monitor

### Successful Keep-Alive
```
INFO  - Keep-Alive Service initialized. Will ping every 14 minutes
INFO  - Keep-Alive ping started at: 2025-09-30 19:00:00
INFO  - Keep-Alive ping successful - Status: 200 OK
INFO  - Keep-Alive ping received from: 1.2.3.4 at 2025-09-30 19:00:00
```

### Service Status
```
INFO  - System Status Check - Keep-Alive Service is running at: 2025-09-30 19:00:00
INFO  - Keep-Alive interval: 14 minutes
INFO  - Target URL: https://indiantradebackend.onrender.com
```

### Error Scenarios
```
ERROR - Keep-Alive ping failed: Connection timeout
INFO  - Backup ping successful - Status: 200 OK
```

## Benefits

### 🚀 Performance
- **No more cold starts**: Service stays warm 24/7
- **Instant response**: Frontend gets immediate API responses
- **Better UX**: Users don't wait for 30-60 second wake-up times

### 📈 Reliability
- **Always available**: Service responds immediately
- **Backup mechanisms**: Multiple ping strategies
- **Smart monitoring**: Detailed logging for troubleshooting

### 💰 Cost Effective
- **Free tier optimization**: Works within Render's limits
- **Minimal resource usage**: Optimized for 512MB memory
- **No external dependencies**: Self-contained solution

## Troubleshooting

### Service Not Starting
1. Check if `@EnableScheduling` and `@EnableAsync` are present in main application class
2. Verify RestTemplate bean is configured
3. Check application properties for keep-alive configuration

### Pings Failing
1. Verify `app.render.url` points to correct Render service URL
2. Check network connectivity and firewall settings
3. Monitor logs for specific error messages

### Memory Issues
1. Reduce thread pool sizes in properties
2. Check if other services are consuming too much memory
3. Monitor memory usage via `/api/health` endpoint

### Disabling the Service
Set `app.keep-alive.enabled=false` in your properties file.

## Integration with Frontend

Your frontend on Elastic Beanstalk is already configured to connect to:
```
https://indiantradebackend.onrender.com
```

With the Keep-Alive service active, your frontend will always get instant responses from the backend!

## Conclusion

The Keep-Alive service ensures your IndianTradeMart backend is always ready to serve your Elastic Beanstalk frontend with zero cold start delays. The service is production-ready, memory-optimized, and provides comprehensive monitoring capabilities.

🎉 **Your backend will now stay active 24/7 on Render!**