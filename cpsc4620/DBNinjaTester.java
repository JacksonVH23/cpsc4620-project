package cpsc4620;

import java.io.IOException;
import java.sql.SQLException;

public class DBNinjaTester {

    public static void main(String[] args) {
        try {
            // Test case 1: Valid topping name
            System.out.println("Testing with a valid topping name: 'Pepperoni'");
            Topping topping = DBNinja.findToppingByName("Pepperoni");
            if (topping != null) {
                System.out.println("Topping found: " + topping.toString());
            } else {
                System.out.println("No topping found with the name 'Pepperoni'.");
            }

            // Test case 2: Invalid topping name
            System.out.println("\nTesting with an invalid topping name: 'Unicorn Cheese'");
            Topping invalidTopping = DBNinja.findToppingByName("Unicorn Cheese");
            if (invalidTopping != null) {
                System.out.println("Topping found: " + invalidTopping.toString());
            } else {
                System.out.println("No topping found with the name 'Unicorn Cheese'.");
            }

            // Test case 3: Case sensitivity test
            System.out.println("\nTesting with a case-sensitive topping name: 'pepperoni'");
            Topping caseSensitiveTopping = DBNinja.findToppingByName("pepperoni");
            if (caseSensitiveTopping != null) {
                System.out.println("Topping found: " + caseSensitiveTopping.toString());
            } else {
                System.out.println("No topping found with the name 'pepperoni'.");
            }

            // Test case 4: Empty string
            System.out.println("\nTesting with an empty string.");
            Topping emptyTopping = DBNinja.findToppingByName("");
            if (emptyTopping != null) {
                System.out.println("Topping found: " + emptyTopping.toString());
            } else {
                System.out.println("No topping found with an empty name.");
            }

        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }
}
