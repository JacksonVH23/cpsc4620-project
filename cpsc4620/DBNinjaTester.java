package cpsc4620;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

public class DBNinjaTester {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        boolean running = true;

        while (running) {
            // Display menu
            System.out.println("\n--- DBNinja Tester Menu ---");
            System.out.println("1. Test findToppingByName");
            System.out.println("2. Test getLastOrder");
            System.out.println("3. Test getPizzas");
            System.out.println("4. Test getDiscounts (Order)");
            System.out.println("5. Test getBaseCustPrice");
            System.out.println("6. Test getBaseBusPrice");
            System.out.println("7. Test printToppingPopReport");
            System.out.println("8. Test printProfitByPizzaReport");
            System.out.println("9. Test printProfitByOrderType");
            System.out.println("10. Exit");

            System.out.print("Enter your choice: ");

            String choice = scanner.nextLine();

            switch (choice) {
                case "1":
                    testFindToppingByName();
                    break;
                case "2":
                    testGetLastOrder();
                    break;
                case "3":
                    testGetPizzas();
                    break;
                case "4":
                    testGetDiscountsOnOrder();
                    break;
                case "5":
                    testGetBaseCustPrice();
                    break;
                case "6":
                    testGetBaseBusPrice();
                    break;
                case "7":
                    testPrintToppingPopReport();
                    break;
                case "8":
                    testPrintProfitByPizzaReport();
                    break;
                case "9":
                    testPrintProfitByOrderType();
                    break;
                case "10":
                    System.out.println("Exiting...");
                    running = false;
                    break;

                default:
                    System.out.println("Invalid choice. Please try again.");
            }
        }

        scanner.close();
    }

    // Test method for findToppingByName
    private static void testFindToppingByName() {
        System.out.println("\n--- Testing findToppingByName ---");
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

    // Test method for getLastOrder
    private static void testGetLastOrder() {
        System.out.println("\n--- Testing getLastOrder ---");
        try {
            Order lastOrder = DBNinja.getLastOrder();
            if (lastOrder != null) {
                System.out.println("Last order details:");
                System.out.println(lastOrder.toFullPrint()); // Assuming toFullPrint() gives detailed order info
            } else {
                System.out.println("No orders found.");
            }
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    // Test method for getPizzas
    private static void testGetPizzas() {
        System.out.println("\n--- Testing getPizzas ---");
        try {
            // Obtain the last order
            Order lastOrder = DBNinja.getLastOrder();
            if (lastOrder != null) {
                System.out.println("Last order details:");
                System.out.println(lastOrder.toFullPrint()); // Assuming toFullPrint() gives detailed order info

                // Retrieve pizzas for the last order
                System.out.println("\nRetrieving pizzas for the last order...");
                ArrayList<Pizza> pizzas = DBNinja.getPizzas(lastOrder);
                if (!pizzas.isEmpty()) {
                    for (Pizza pizza : pizzas) {
                        System.out.println("\nPizza details:");
                        System.out.println(pizza.toString()); // Assuming toString() gives pizza details

                        // Test and print toppings for each pizza
                        System.out.println("\nTesting getToppingsOnPizza...");
                        ArrayList<Topping> toppings = pizza.getToppings(); // Assuming getToppings is called within getPizzas
                        if (!toppings.isEmpty()) {
                            System.out.println("Toppings:");
                            for (Topping topping : toppings) {
                                System.out.println(topping.toString());
                            }
                        } else {
                            System.out.println("No toppings found for this pizza.");
                        }

                        // Test and print discounts for each pizza
                        System.out.println("\nTesting getDiscounts...");
                        ArrayList<Discount> discounts = pizza.getDiscounts(); // Assuming getDiscounts is called within getPizzas
                        if (!discounts.isEmpty()) {
                            System.out.println("Discounts:");
                            for (Discount discount : discounts) {
                                System.out.println(discount.toString());
                            }
                        } else {
                            System.out.println("No discounts found for this pizza.");
                        }
                    }
                } else {
                    System.out.println("No pizzas found for the last order.");
                }
            } else {
                System.out.println("No orders found to retrieve pizzas from.");
            }
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    // Test method for getDiscounts with Order
    private static void testGetDiscountsOnOrder() {
        System.out.println("\n--- Testing getDiscounts (Order) ---");
        try {
            // Obtain the last order
            Order lastOrder = DBNinja.getLastOrder();
            if (lastOrder != null) {
                System.out.println("Last order details:");
                System.out.println(lastOrder.toFullPrint()); // Assuming toFullPrint() gives detailed order info

                // Retrieve discounts for the last order
                System.out.println("\nRetrieving discounts for the last order...");
                ArrayList<Discount> orderDiscounts = DBNinja.getDiscounts(lastOrder); // Call the getDiscounts method
                if (!orderDiscounts.isEmpty()) {
                    System.out.println("Order Discounts:");
                    for (Discount discount : orderDiscounts) {
                        System.out.println(discount.toString()); // Assuming toString() provides discount details
                    }
                } else {
                    System.out.println("No discounts found for the last order.");
                }
            } else {
                System.out.println("No orders found to retrieve discounts from.");
            }
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    // Test method for getBaseCustPrice
    private static void testGetBaseCustPrice() {
        System.out.println("\n--- Testing getBaseCustPrice ---");
        try {
            // Test valid combinations
            String[][] validCases = {
                    {"Small", "Thin"},
                    {"Medium", "Pan"},
                    {"Large", "Gluten-Free"},
                    {"XLarge", "Original"}
            };
            for (String[] testCase : validCases) {
                String size = testCase[0];
                String crust = testCase[1];
                System.out.println("Testing size: " + size + ", crust: " + crust);
                double custPrice = DBNinja.getBaseCustPrice(size, crust);
                System.out.println("Customer Price: $" + custPrice);
            }

            // Test invalid combination
            System.out.println("\nTesting invalid combination: size: 'Mega', crust: 'Stuffed'");
            double invalidCustPrice = DBNinja.getBaseCustPrice("Mega", "Stuffed");
            System.out.println("Customer Price: $" + invalidCustPrice);
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    // Test method for getBaseBusPrice
    private static void testGetBaseBusPrice() {
        System.out.println("\n--- Testing getBaseBusPrice ---");
        try {
            // Test valid combinations
            String[][] validCases = {
                    {"Small", "Original"},
                    {"Medium", "Gluten-Free"},
                    {"Large", "Pan"},
                    {"XLarge", "Thin"}
            };
            for (String[] testCase : validCases) {
                String size = testCase[0];
                String crust = testCase[1];
                System.out.println("Testing size: " + size + ", crust: " + crust);
                double busPrice = DBNinja.getBaseBusPrice(size, crust);
                System.out.println("Business Price: $" + busPrice);
            }

            // Test invalid combination
            System.out.println("\nTesting invalid combination: size: 'Tiny', crust: 'Cheese-Stuffed'");
            double invalidBusPrice = DBNinja.getBaseBusPrice("Tiny", "Cheese-Stuffed");
            System.out.println("Business Price: $" + invalidBusPrice);
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    // Test method for printToppingPopReport
    private static void testPrintToppingPopReport() {
        System.out.println("\n--- Testing printToppingPopReport ---");
        try {
            DBNinja.printToppingPopReport(); // Call the method to print the report
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }
    // Test method for printProfitByPizzaReport
    private static void testPrintProfitByPizzaReport() {
        System.out.println("\n--- Testing printProfitByPizzaReport ---");
        try {
            DBNinja.printProfitByPizzaReport(); // Call the method to print the report
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    // Test method for printProfitByOrderType
    private static void testPrintProfitByOrderType() {
        System.out.println("\n--- Testing printProfitByOrderType ---");
        try {
            DBNinja.printProfitByOrderType(); // Call the method to print the report
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

}
