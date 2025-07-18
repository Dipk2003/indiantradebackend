import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DatabaseConnectionTest {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://dpg-disbevrulbrs3a87mhg-a.oregon-postgres.render.com:5432/itech_user?sslmode=require";
        String username = "itech_user";
        String password = "uPCQxPFY1lO77ObOtR9MKDHUOXJGTQFC";
        
        System.out.println("Testing database connection...");
        System.out.println("URL: " + url);
        System.out.println("Username: " + username);
        
        try {
            // Load PostgreSQL driver
            Class.forName("org.postgresql.Driver");
            
            // Establish connection
            Connection connection = DriverManager.getConnection(url, username, password);
            
            System.out.println("✅ Connection successful!");
            
            // Test query
            PreparedStatement stmt = connection.prepareStatement("SELECT 1 AS test");
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                System.out.println("✅ Query test successful! Result: " + rs.getInt("test"));
            }
            
            rs.close();
            stmt.close();
            connection.close();
            
            System.out.println("✅ All tests passed!");
            
        } catch (ClassNotFoundException e) {
            System.err.println("❌ PostgreSQL driver not found: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
