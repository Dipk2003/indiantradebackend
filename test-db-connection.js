const { Client } = require('pg');

// Test PostgreSQL connection using your environment variables
const connectionString = 'postgresql://itech_user:uPCQxPFY1lO77ObOtR9MKDHUOXJGTQFC@dpg-disbevrulbrs3a87mhg-a.oregon-postgres.render.com:5432/itech_user';

const client = new Client({
  connectionString: connectionString,
  ssl: {
    rejectUnauthorized: false // Required for Render PostgreSQL
  }
});

async function testConnection() {
  try {
    console.log('Testing database connection...');
    await client.connect();
    console.log('✅ Connected to PostgreSQL database successfully!');
    
    // Test a simple query
    const result = await client.query('SELECT NOW() as current_time');
    console.log('✅ Database query successful:', result.rows[0]);
    
    // Test if we can create a simple table
    await client.query(`
      CREATE TABLE IF NOT EXISTS test_connection (
        id SERIAL PRIMARY KEY,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✅ Test table creation successful!');
    
    // Clean up test table
    await client.query('DROP TABLE IF EXISTS test_connection');
    console.log('✅ Test table cleanup successful!');
    
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    console.error('Connection details:', {
      host: 'dpg-disbevrulbrs3a87mhg-a.oregon-postgres.render.com',
      port: 5432,
      database: 'itech_user',
      user: 'itech_user'
    });
  } finally {
    await client.end();
  }
}

testConnection();
