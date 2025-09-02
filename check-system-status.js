#!/usr/bin/env node
/**
 * iTech B2B Marketplace - System Status Check
 * This script provides a comprehensive status check of all system components
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('\n' + '='.repeat(80));
console.log('🔍 iTech B2B Marketplace - System Status Check');
console.log('='.repeat(80));

// Status tracking
let statusResults = {
    database: [],
    backend: [],
    frontend: [],
    integration: []
};

// Helper functions
function testEndpoint(url, description) {
    try {
        const result = execSync(`curl -s -o /dev/null -w "%{http_code}" "${url}"`, {
            encoding: 'utf8',
            timeout: 10000
        }).trim();
        return { url, description, status: result, success: result.startsWith('2') };
    } catch (error) {
        return { url, description, status: 'TIMEOUT', success: false };
    }
}

function testCORS(url) {
    try {
        const result = execSync(`curl -s -H "Origin: http://localhost:3000" -H "Access-Control-Request-Method: GET" -o /dev/null -w "%{http_code}" -X OPTIONS "${url}"`, {
            encoding: 'utf8',
            timeout: 10000
        }).trim();
        return { status: result, success: result === '200' };
    } catch (error) {
        return { status: 'ERROR', success: false };
    }
}

function checkPort(port) {
    try {
        const result = execSync(`netstat -an | findstr "${port}"`, { encoding: 'utf8' });
        return result.includes('LISTENING');
    } catch (error) {
        return false;
    }
}

function checkService(serviceName, port) {
    const isListening = checkPort(port);
    const endpoint = port === 3000 ? 'http://localhost:3000' : 'http://localhost:8080/health';
    const response = testEndpoint(endpoint, `${serviceName} Health Check`);
    
    return {
        service: serviceName,
        port,
        listening: isListening,
        responding: response.success,
        status: response.status
    };
}

// Test Database Connectivity
console.log('\n' + '='.repeat(80));
console.log('🗄️  Testing Database Status');
console.log('='.repeat(80));

try {
    // Test MySQL connection
    const mysqlTest = execSync('mysql -h localhost -P 3306 -u root -proot -e "SELECT 1 as test;" 2>/dev/null', {
        encoding: 'utf8',
        timeout: 10000
    });
    
    statusResults.database.push({
        test: 'MySQL Connection',
        result: 'SUCCESS',
        details: 'Connected to MySQL server'
    });
    console.log('✅ MySQL Connection: Connected successfully');
    
    // Test database existence
    const dbTest = execSync('mysql -h localhost -P 3306 -u root -proot -e "USE itech_db; SELECT COUNT(*) as tables FROM information_schema.tables WHERE table_schema = \'itech_db\';" 2>/dev/null', {
        encoding: 'utf8',
        timeout: 10000
    });
    
    const tableCount = dbTest.match(/\d+/);
    statusResults.database.push({
        test: 'Database Schema',
        result: 'SUCCESS',
        details: `Found ${tableCount ? tableCount[0] : 'unknown'} tables in itech_db`
    });
    console.log(`✅ Database Schema: Found ${tableCount ? tableCount[0] : 'unknown'} tables in itech_db`);
    
} catch (error) {
    statusResults.database.push({
        test: 'Database Connection',
        result: 'FAILED',
        details: 'Cannot connect to MySQL database'
    });
    console.log('❌ Database Connection: Failed to connect to MySQL');
}

// Test Backend Service
console.log('\n' + '='.repeat(80));
console.log('🖥️  Testing Backend Service');
console.log('='.repeat(80));

const backendService = checkService('Backend', 8080);
console.log(`${backendService.listening ? '✅' : '❌'} Backend Port 8080: ${backendService.listening ? 'Listening' : 'Not listening'}`);
console.log(`${backendService.responding ? '✅' : '❌'} Backend Health: ${backendService.responding ? 'Responding' : 'Not responding'} (${backendService.status})`);

statusResults.backend.push({
    test: 'Service Status',
    result: backendService.listening && backendService.responding ? 'SUCCESS' : 'FAILED',
    details: `Port ${backendService.port} ${backendService.listening ? 'listening' : 'not listening'}, health check ${backendService.status}`
});

// Test key backend endpoints
const backendEndpoints = [
    { url: 'http://localhost:8080/actuator/health', desc: 'Actuator Health' },
    { url: 'http://localhost:8080/api/categories', desc: 'Categories API' },
    { url: 'http://localhost:8080/api/auth/login', desc: 'Auth Login' },
    { url: 'http://localhost:8080/api/vendors', desc: 'Vendors API' },
    { url: 'http://localhost:8080/api/admin/analytics', desc: 'Admin Analytics' }
];

backendEndpoints.forEach(endpoint => {
    const result = testEndpoint(endpoint.url, endpoint.desc);
    console.log(`${result.success ? '✅' : '❌'} ${endpoint.desc}: ${result.status}`);
    statusResults.backend.push({
        test: endpoint.desc,
        result: result.success ? 'SUCCESS' : 'WARNING',
        details: `HTTP ${result.status}`
    });
});

// Test CORS Configuration
const corsTest = testCORS('http://localhost:8080/api/categories');
console.log(`${corsTest.success ? '✅' : '❌'} CORS Configuration: ${corsTest.success ? 'Properly configured' : 'Issues detected'} (${corsTest.status})`);
statusResults.backend.push({
    test: 'CORS Configuration',
    result: corsTest.success ? 'SUCCESS' : 'WARNING',
    details: `OPTIONS request returned ${corsTest.status}`
});

// Test Frontend Service
console.log('\n' + '='.repeat(80));
console.log('🌐 Testing Frontend Service');
console.log('='.repeat(80));

const frontendService = checkService('Frontend', 3000);
console.log(`${frontendService.listening ? '✅' : '❌'} Frontend Port 3000: ${frontendService.listening ? 'Listening' : 'Not listening'}`);
console.log(`${frontendService.responding ? '✅' : '❌'} Frontend Health: ${frontendService.responding ? 'Responding' : 'Not responding'} (${frontendService.status})`);

statusResults.frontend.push({
    test: 'Service Status',
    result: frontendService.listening && frontendService.responding ? 'SUCCESS' : 'FAILED',
    details: `Port ${frontendService.port} ${frontendService.listening ? 'listening' : 'not listening'}, response ${frontendService.status}`
});

// Check frontend build and configuration
try {
    const frontendPath = "C:\\Users\\Dipanshu pandey\\OneDrive\\Desktop\\itm-main-fronted-main";
    
    // Check package.json
    if (fs.existsSync(path.join(frontendPath, 'package.json'))) {
        console.log('✅ Package Configuration: package.json exists');
        statusResults.frontend.push({
            test: 'Package Configuration',
            result: 'SUCCESS',
            details: 'package.json found'
        });
    } else {
        console.log('❌ Package Configuration: package.json missing');
        statusResults.frontend.push({
            test: 'Package Configuration',
            result: 'FAILED',
            details: 'package.json not found'
        });
    }
    
    // Check environment configuration
    if (fs.existsSync(path.join(frontendPath, '.env.local'))) {
        console.log('✅ Environment Configuration: .env.local exists');
        statusResults.frontend.push({
            test: 'Environment Configuration',
            result: 'SUCCESS',
            details: '.env.local found'
        });
    } else {
        console.log('❌ Environment Configuration: .env.local missing');
        statusResults.frontend.push({
            test: 'Environment Configuration',
            result: 'WARNING',
            details: '.env.local not found'
        });
    }
    
} catch (error) {
    console.log('❌ Frontend Configuration: Cannot access frontend directory');
    statusResults.frontend.push({
        test: 'Frontend Configuration',
        result: 'FAILED',
        details: 'Cannot access frontend directory'
    });
}

// Test Integration
console.log('\n' + '='.repeat(80));
console.log('🔗 Testing Integration Status');
console.log('='.repeat(80));

const bothServicesRunning = backendService.listening && backendService.responding && 
                          frontendService.listening && frontendService.responding;

console.log(`${bothServicesRunning ? '✅' : '❌'} Service Integration: ${bothServicesRunning ? 'Both services running' : 'Service issues detected'}`);
statusResults.integration.push({
    test: 'Service Integration',
    result: bothServicesRunning ? 'SUCCESS' : 'FAILED',
    details: `Backend: ${backendService.responding}, Frontend: ${frontendService.responding}`
});

// Test API communication
try {
    const apiTest = testEndpoint('http://localhost:3000/_next/static', 'Frontend Static Assets');
    console.log(`${apiTest.success ? '✅' : '❌'} Frontend Assets: ${apiTest.success ? 'Loading properly' : 'Issues detected'}`);
    statusResults.integration.push({
        test: 'Frontend Assets',
        result: apiTest.success ? 'SUCCESS' : 'WARNING',
        details: `Static assets ${apiTest.status}`
    });
} catch (error) {
    console.log('❌ Frontend Assets: Cannot test static assets');
    statusResults.integration.push({
        test: 'Frontend Assets',
        result: 'WARNING',
        details: 'Cannot test static assets'
    });
}

// Generate Summary Report
console.log('\n' + '='.repeat(80));
console.log('📊 System Status Summary');
console.log('='.repeat(80));

let totalTests = 0;
let successfulTests = 0;
let warnings = 0;

Object.keys(statusResults).forEach(category => {
    const categoryTests = statusResults[category];
    const successful = categoryTests.filter(t => t.result === 'SUCCESS').length;
    const failed = categoryTests.filter(t => t.result === 'FAILED').length;
    const warning = categoryTests.filter(t => t.result === 'WARNING').length;
    
    totalTests += categoryTests.length;
    successfulTests += successful;
    warnings += warning;
    
    console.log(`\n${category.toUpperCase()}: ${successful}/${categoryTests.length} tests passed`);
    categoryTests.forEach(test => {
        const icon = test.result === 'SUCCESS' ? '✅' : test.result === 'WARNING' ? '⚠️' : '❌';
        console.log(`  ${icon} ${test.test}: ${test.details}`);
    });
});

const successRate = ((successfulTests / totalTests) * 100).toFixed(1);

console.log(`\n📈 Overall Status:`);
console.log(`   Total Tests: ${totalTests}`);
console.log(`   Successful: ${successfulTests}`);
console.log(`   Warnings: ${warnings}`);
console.log(`   Failed: ${totalTests - successfulTests - warnings}`);
console.log(`   Success Rate: ${successRate}%`);

// Generate recommendations
console.log('\n' + '='.repeat(80));
console.log('💡 Recommendations');
console.log('='.repeat(80));

if (successRate >= 90) {
    console.log('🎉 Excellent! Your system is running optimally.');
    console.log('✨ All major components are functioning correctly.');
    console.log('🚀 You can start using the application at http://localhost:3000');
} else if (successRate >= 75) {
    console.log('👍 Good! Most components are working, but there are some issues to address.');
    console.log('🔧 Review the failed tests above and fix any configuration issues.');
    console.log('📝 The application should be functional for basic testing.');
} else {
    console.log('⚠️  System has significant issues that need attention.');
    console.log('🚨 Please address the failed tests before proceeding.');
    console.log('📋 Check service logs and configuration files.');
}

console.log('\n🎯 Next Steps:');
if (!bothServicesRunning) {
    console.log('1. Ensure both backend and frontend services are running');
    console.log('   - Backend: mvn spring-boot:run (should be on port 8080)');
    console.log('   - Frontend: npm run dev (should be on port 3000)');
}

if (warnings > 0) {
    console.log('2. Address warning items for optimal performance');
}

console.log('3. Open http://localhost:3000 in your browser to access the application');
console.log('4. Test different user roles and features');
console.log('5. Monitor application logs for any runtime issues');

console.log('\n📋 Documentation:');
console.log('   - Integration Guide: INTEGRATION_GUIDE.md');
console.log('   - Test Reports: INTEGRATION_TEST_REPORT.md');
console.log('   - Startup Scripts: start-*.bat files');

// Save detailed status report
const statusReport = {
    timestamp: new Date().toISOString(),
    totalTests,
    successfulTests,
    warnings,
    failed: totalTests - successfulTests - warnings,
    successRate: parseFloat(successRate),
    results: statusResults,
    recommendation: successRate >= 90 ? 'EXCELLENT' : successRate >= 75 ? 'GOOD' : 'NEEDS_ATTENTION'
};

try {
    fs.writeFileSync('SYSTEM_STATUS_REPORT.json', JSON.stringify(statusReport, null, 2));
    console.log('\n💾 Detailed status report saved to: SYSTEM_STATUS_REPORT.json');
} catch (error) {
    console.log('\n❌ Could not save detailed status report');
}

process.exit(successRate >= 75 ? 0 : 1);
