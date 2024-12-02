package cpsc4620;

public class DBConnectorTest {
    public static void main(String[] args) {
        try {
            // Call the method to get a connection
            java.sql.Connection connection = DBConnector.make_connection();

            // Check if the connection is valid
            if (connection != null && !connection.isClosed()) {
                System.out.println("Database connection established successfully!");
                // Close the connection when done
                connection.close();
            } else {
                System.out.println("Failed to establish a database connection.");
            }
        } catch (Exception e) {
            // Print any errors that occur
            System.out.println("An error occurred while connecting to the database:");
            e.printStackTrace();
        }
    }
}
