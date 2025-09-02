#!/usr/bin/env node

/**
 * iTech B2B Marketplace - Integration Testing Script
 * Tests all aspects of the backend-frontend-database integration
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const https = require('https');
const http = require('http');

const execPromise = util.promisify(exec);

const CONFIG = {
  backend: {
    url: 'http://localhost:8080',
    path: 'D:\\itech-backend\\itech-backend'
  },
  frontend: {
    url: 'http://localhost:3000',
    path: 'C:\\Users\\Dipanshu pandey\\OneDrive\\Desktop\\itm-main-fronted-main'
  },
  database: {
    host: 'localhost',
    port: 3306,
    name: 'itech_db',
    username: 'root',
    password: 'root'
  }
};

// Test results storage
const testResults = {
  database: { passed: 0, failed: 0, tests: [] },
  backend: { passed: 0, failed: 0, tests: [] },
  frontend: { passed: 0, failed: 0, tests: [] },
  integration: { passed: 0, failed: 0, tests: [] }
};

function log(message, color = '\x1b[0m') {
  console.log(`${color}${message}\x1b[0m`);
}

function logSuccess(message) {
  log(`✅ ${message}`, '\x1b[32m');
}

function logError(message) {
  log(`❌ ${message}`, '\x1b[31m');
}

function logInfo(message) {
  log(`ℹ️  ${message}`, '\x1b[34m');
}

function logHeader(message) {
  log(`\n${'='.repeat(80)}`, '\x1b[36m');
  log(`🧪 ${message}`, '\x1b[36m');
  log('='.repeat(80), '\x1b[36m');
}

async function makeHttpRequest(url, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port,
      path: urlObj.pathname + urlObj.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'iTech-Integration-Test/1.0'
      }
    };

    if (data) {
      options.headers['Content-Length'] = Buffer.byteLength(data);
    }

    const req = (urlObj.protocol === 'https:' ? https : http).request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: body
        });
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.setTimeout(10000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    if (data) {
      req.write(data);
    }
    req.end();
  });
}

function recordTest(category, testName, passed, message) {
  testResults[category].tests.push({
    name: testName,
    passed: passed,
    message: message
  });
  
  if (passed) {
    testResults[category].passed++;
    logSuccess(`${testName}: ${message}`);
  } else {
    testResults[category].failed++;
    logError(`${testName}: ${message}`);
  }
}

async function testDatabase() {
  logHeader('Testing Database Integration');
  
  try {
    // Test 1: MySQL Connection
    const connectionTest = await execPromise(
      `mysql -h${CONFIG.database.host} -P${CONFIG.database.port} -u${CONFIG.database.username} -p${CONFIG.database.password} -e "SELECT VERSION();"`
    );
    recordTest('database', 'MySQL Connection', true, 'Connected successfully');
    
    // Test 2: Database Exists
    const dbExistsTest = await execPromise(
      `mysql -h${CONFIG.database.host} -P${CONFIG.database.port} -u${CONFIG.database.username} -p${CONFIG.database.password} -e "USE ${CONFIG.database.name}; SELECT 1;"`
    );
    recordTest('database', 'Database Exists', true, `Database ${CONFIG.database.name} is accessible`);
    
    // Test 3: Essential Tables
    const tablesTest = await execPromise(
      `mysql -h${CONFIG.database.host} -P${CONFIG.database.port} -u${CONFIG.database.username} -p${CONFIG.database.password} -D${CONFIG.database.name} -e "SHOW TABLES;"`
    );
    
    const essentialTables = ['user', 'vendors', 'buyer_category', 'admins'];
    let foundTables = 0;
    
    for (const table of essentialTables) {
      if (tablesTest.stdout.includes(table)) {
        foundTables++;
      }
    }
    
    recordTest('database', 'Essential Tables', 
      foundTables === essentialTables.length, 
      `Found ${foundTables}/${essentialTables.length} essential tables`);
    
  } catch (error) {
    recordTest('database', 'Database Connection', false, `Failed: ${error.message}`);
  }
}

async function testBackend() {
  logHeader('Testing Backend API');
  
  try {
    // Test 1: Health Check
    try {
      const healthResponse = await makeHttpRequest(`${CONFIG.backend.url}/health`);
      recordTest('backend', 'Health Endpoint', 
        healthResponse.statusCode === 200, 
        `Health check returned ${healthResponse.statusCode}`);
    } catch (error) {
      recordTest('backend', 'Health Endpoint', false, `Health endpoint failed: ${error.message}`);
    }
    
    // Test 2: Actuator Health
    try {
      const actuatorResponse = await makeHttpRequest(`${CONFIG.backend.url}/actuator/health`);
      recordTest('backend', 'Actuator Health', 
        actuatorResponse.statusCode === 200, 
        `Actuator health returned ${actuatorResponse.statusCode}`);
    } catch (error) {
      recordTest('backend', 'Actuator Health', false, `Actuator health failed: ${error.message}`);
    }
    
    // Test 3: CORS Headers
    try {
      const corsResponse = await makeHttpRequest(`${CONFIG.backend.url}/health`);
      const hasCors = corsResponse.headers['access-control-allow-origin'] || 
                     corsResponse.headers['Access-Control-Allow-Origin'];
      recordTest('backend', 'CORS Configuration', 
        !!hasCors, 
        hasCors ? 'CORS headers present' : 'No CORS headers found');
    } catch (error) {
      recordTest('backend', 'CORS Configuration', false, `CORS test failed: ${error.message}`);
    }
    
    // Test 4: API Routes
    const apiRoutes = [
      '/api/health',
      '/auth/health',
      '/api/categories',
      '/api/vendors',
      '/api/admin/analytics'
    ];
    
    for (const route of apiRoutes) {
      try {
        const response = await makeHttpRequest(`${CONFIG.backend.url}${route}`);
        const isValid = response.statusCode === 200 || response.statusCode === 401 || response.statusCode === 403;
        recordTest('backend', `API Route ${route}`, 
          isValid, 
          `Returned ${response.statusCode} (${isValid ? 'Expected' : 'Unexpected'})`);
      } catch (error) {
        recordTest('backend', `API Route ${route}`, false, `Failed: ${error.message}`);
      }
    }
    
    // Test 5: Authentication Endpoint
    try {
      const authData = JSON.stringify({
        email: 'test@example.com',
        password: 'wrongpassword'
      });
      
      const authResponse = await makeHttpRequest(`${CONFIG.backend.url}/auth/login`, 'POST', authData);
      const isAuthEndpoint = authResponse.statusCode === 401 || authResponse.statusCode === 400;
      recordTest('backend', 'Authentication Endpoint', 
        isAuthEndpoint, 
        `Auth endpoint responding (${authResponse.statusCode})`);
    } catch (error) {
      recordTest('backend', 'Authentication Endpoint', false, `Auth test failed: ${error.message}`);
    }
    
  } catch (error) {
    recordTest('backend', 'Backend Testing', false, `Backend tests failed: ${error.message}`);
  }
}

async function testFrontend() {
  logHeader('Testing Frontend Application');
  
  try {
    // Test 1: Frontend Server Response
    try {
      const frontendResponse = await makeHttpRequest(CONFIG.frontend.url);
      recordTest('frontend', 'Frontend Server', 
        frontendResponse.statusCode === 200, 
        `Frontend returned ${frontendResponse.statusCode}`);
      
      // Check if it's a valid HTML response
      if (frontendResponse.body.includes('<html') || frontendResponse.body.includes('<!DOCTYPE')) {
        recordTest('frontend', 'HTML Response', true, 'Valid HTML response detected');
      } else {
        recordTest('frontend', 'HTML Response', false, 'Response is not valid HTML');
      }
    } catch (error) {
      recordTest('frontend', 'Frontend Server', false, `Frontend server failed: ${error.message}`);
    }
    
    // Test 2: API Configuration
    const apiConfigPath = path.join(CONFIG.frontend.path, 'src', 'config', 'api.ts');
    if (fs.existsSync(apiConfigPath)) {
      const apiConfig = fs.readFileSync(apiConfigPath, 'utf8');
      const hasCorrectUrl = apiConfig.includes('localhost:8080');
      recordTest('frontend', 'API Configuration', 
        hasCorrectUrl, 
        hasCorrectUrl ? 'API config points to correct backend' : 'API config might be incorrect');
    } else {
      recordTest('frontend', 'API Configuration', false, 'API config file not found');
    }
    
    // Test 3: Environment Configuration
    const envPath = path.join(CONFIG.frontend.path, '.env.local');
    if (fs.existsSync(envPath)) {
      const envContent = fs.readFileSync(envPath, 'utf8');
      const hasBackendUrl = envContent.includes('http://localhost:8080');
      recordTest('frontend', 'Environment Config', 
        hasBackendUrl, 
        hasBackendUrl ? 'Environment points to correct backend' : 'Environment config needs updating');
    } else {
      recordTest('frontend', 'Environment Config', false, 'No .env.local file found');
    }
    
    // Test 4: Dependencies
    const packageJsonPath = path.join(CONFIG.frontend.path, 'package.json');
    if (fs.existsSync(packageJsonPath)) {
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
      const hasReact = packageJson.dependencies && packageJson.dependencies.react;
      const hasNext = packageJson.dependencies && packageJson.dependencies.next;
      const hasAxios = packageJson.dependencies && packageJson.dependencies.axios;
      
      recordTest('frontend', 'Core Dependencies', 
        hasReact && hasNext, 
        `React: ${!!hasReact}, Next.js: ${!!hasNext}`);
        
      recordTest('frontend', 'HTTP Client', 
        hasAxios, 
        hasAxios ? 'Axios configured' : 'No HTTP client found');
    }
    
  } catch (error) {
    recordTest('frontend', 'Frontend Testing', false, `Frontend tests failed: ${error.message}`);
  }
}

async function testIntegration() {
  logHeader('Testing End-to-End Integration');
  
  try {
    // Test 1: Backend-Database Integration
    try {
      const dbHealthResponse = await makeHttpRequest(`${CONFIG.backend.url}/actuator/health`);
      if (dbHealthResponse.statusCode === 200) {
        const healthData = JSON.parse(dbHealthResponse.body);
        const dbStatus = healthData.components && healthData.components.db;
        recordTest('integration', 'Backend-Database', 
          dbStatus && dbStatus.status === 'UP', 
          dbStatus ? `Database status: ${dbStatus.status}` : 'Database status unknown');
      }
    } catch (error) {
      recordTest('integration', 'Backend-Database', false, `Integration test failed: ${error.message}`);
    }
    
    // Test 2: Frontend-Backend Communication
    try {
      // This would be a more complex test in a real scenario
      // For now, we'll check if both are running
      const backendOk = await makeHttpRequest(`${CONFIG.backend.url}/health`);
      const frontendOk = await makeHttpRequest(CONFIG.frontend.url);
      
      recordTest('integration', 'Frontend-Backend', 
        backendOk.statusCode === 200 && frontendOk.statusCode === 200, 
        'Both frontend and backend are responding');
    } catch (error) {
      recordTest('integration', 'Frontend-Backend', false, `Communication test failed: ${error.message}`);
    }
    
    // Test 3: CORS Integration
    try {
      const corsTestResponse = await makeHttpRequest(`${CONFIG.backend.url}/health`, 'OPTIONS');
      recordTest('integration', 'CORS Integration', 
        corsTestResponse.statusCode === 200 || corsTestResponse.statusCode === 204, 
        `CORS preflight returned ${corsTestResponse.statusCode}`);
    } catch (error) {
      recordTest('integration', 'CORS Integration', false, `CORS test failed: ${error.message}`);
    }
    
    // Test 4: Port Availability
    const portsToCheck = [3000, 8080];
    for (const port of portsToCheck) {
      try {
        const testResponse = await makeHttpRequest(`http://localhost:${port}`);
        recordTest('integration', `Port ${port} Availability`, 
          true, 
          `Port ${port} is responding`);
      } catch (error) {
        recordTest('integration', `Port ${port} Availability`, false, `Port ${port} is not responding`);
      }
    }
    
  } catch (error) {
    recordTest('integration', 'Integration Testing', false, `Integration tests failed: ${error.message}`);
  }
}

function generateTestReport() {
  logHeader('Test Results Summary');
  
  const totalPassed = Object.values(testResults).reduce((sum, category) => sum + category.passed, 0);
  const totalFailed = Object.values(testResults).reduce((sum, category) => sum + category.failed, 0);
  const totalTests = totalPassed + totalFailed;
  
  log(`\n📊 Overall Test Results:`, '\x1b[36m');
  log(`   Total Tests: ${totalTests}`);
  log(`   Passed: ${totalPassed}`, '\x1b[32m');
  log(`   Failed: ${totalFailed}`, totalFailed > 0 ? '\x1b[31m' : '\x1b[32m');
  log(`   Success Rate: ${((totalPassed / totalTests) * 100).toFixed(1)}%`);
  
  log(`\n📋 Category Breakdown:`, '\x1b[36m');
  
  Object.entries(testResults).forEach(([category, results]) => {
    const successRate = results.passed + results.failed > 0 
      ? ((results.passed / (results.passed + results.failed)) * 100).toFixed(1)
      : 0;
    
    log(`   ${category.toUpperCase()}: ${results.passed}/${results.passed + results.failed} (${successRate}%)`);
    
    results.tests.forEach(test => {
      const icon = test.passed ? '✅' : '❌';
      const color = test.passed ? '\x1b[32m' : '\x1b[31m';
      log(`     ${icon} ${test.name}: ${test.message}`, color);
    });
    log('');
  });
  
  // Generate detailed report file
  const reportContent = `# iTech B2B Marketplace - Integration Test Report

## Test Summary
- **Total Tests**: ${totalTests}
- **Passed**: ${totalPassed}
- **Failed**: ${totalFailed}
- **Success Rate**: ${((totalPassed / totalTests) * 100).toFixed(1)}%
- **Test Date**: ${new Date().toISOString()}

## Category Results

${Object.entries(testResults).map(([category, results]) => {
  const successRate = results.passed + results.failed > 0 
    ? ((results.passed / (results.passed + results.failed)) * 100).toFixed(1)
    : 0;
  
  return `### ${category.toUpperCase()} (${results.passed}/${results.passed + results.failed} - ${successRate}%)

${results.tests.map(test => 
  `- ${test.passed ? '✅' : '❌'} **${test.name}**: ${test.message}`
).join('\n')}`;
}).join('\n\n')}

## Recommendations

${totalFailed > 0 ? `
### Issues Found
${Object.entries(testResults).map(([category, results]) => {
  const failedTests = results.tests.filter(test => !test.passed);
  if (failedTests.length === 0) return '';
  
  return `
**${category.toUpperCase()}**:
${failedTests.map(test => `- ${test.name}: ${test.message}`).join('\n')}`;
}).join('\n')}

### Next Steps
1. Address the failed tests listed above
2. Ensure all services are running properly
3. Check network connectivity and firewall settings
4. Verify configuration files are correct
` : `
### All Tests Passed! 🎉
Your iTech B2B Marketplace integration is working perfectly. You can proceed with:
1. Starting the application using the provided scripts
2. Testing the user interface
3. Exploring different user roles and features
`}

## Quick Start
1. Run \`start-itech-marketplace.bat\` to start both backend and frontend
2. Open http://localhost:3000 in your browser
3. Register a new account or login with existing credentials
4. Test different modules based on your user role
`;

  fs.writeFileSync('INTEGRATION_TEST_REPORT.md', reportContent);
  logSuccess('Detailed test report saved to: INTEGRATION_TEST_REPORT.md');
  
  return totalFailed === 0;
}

async function main() {
  logHeader('iTech B2B Marketplace - Integration Testing');
  
  logInfo('This script will test all aspects of your integration setup');
  logInfo('Make sure both backend and frontend servers are running');
  
  // Run all tests
  await testDatabase();
  await testBackend();
  await testFrontend();
  await testIntegration();
  
  // Generate report
  const allTestsPassed = generateTestReport();
  
  if (allTestsPassed) {
    logSuccess('🎉 All integration tests passed! Your setup is ready to use.');
  } else {
    logError('⚠️  Some tests failed. Check the report above for details.');
  }
  
  logInfo('Test report saved to: INTEGRATION_TEST_REPORT.md');
}

// Run the tests
if (require.main === module) {
  main().catch(console.error);
}

module.exports = { main, testResults };
