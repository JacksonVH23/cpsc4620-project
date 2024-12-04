package cpsc4620;

import java.io.IOException;
import java.sql.*;
import java.util.*;

/*
 * This file is where you will implement the methods needed to support this application.
 * You will write the code to retrieve and save information to the database and use that
 * information to build the various objects required by the applicaiton.
 * 
 * The class has several hard coded static variables used for the connection, you will need to
 * change those to your connection information
 * 
 * This class also has static string variables for pickup, delivery and dine-in. 
 * DO NOT change these constant values.
 * 
 * You can add any helper methods you need, but you must implement all the methods
 * in this class and use them to complete the project.  The autograder will rely on
 * these methods being implemented, so do not delete them or alter their method
 * signatures.
 * 
 * Make sure you properly open and close your DB connections in any method that
 * requires access to the DB.
 * Use the connect_to_db below to open your connection in DBConnector.
 * What is opened must be closed!
 */

/*
 * A utility class to help add and retrieve information from the database
 */

public final class DBNinja {
	private static Connection conn;

	// DO NOT change these variables!
	public final static String pickup = "pickup";
	public final static String delivery = "delivery";
	public final static String dine_in = "dinein";

	public final static String size_s = "Small";
	public final static String size_m = "Medium";
	public final static String size_l = "Large";
	public final static String size_xl = "XLarge";

	public final static String crust_thin = "Thin";
	public final static String crust_orig = "Original";
	public final static String crust_pan = "Pan";
	public final static String crust_gf = "Gluten-Free";

	private static int connectionRefCount = 0; // Keeps track of active connection users

	public enum order_state {
		PREPARED,
		DELIVERED,
		PICKEDUP
	}


	private static boolean connect_to_db() throws SQLException, IOException 
	{

		try {
			conn = DBConnector.make_connection();
			connectionRefCount++;
			return true;
		} catch (SQLException e) {
			return false;
		} catch (IOException e) {
			return false;
		}

	}

	// This function was added so that connections can be opened/closed in helper functions,
	//   allowing them to be run on their own (for testing), without causing an issue with
	//   the DB connection being closed prematurely when those helper functions are called
	//   within other functions
	private static void close_connection() throws SQLException {
		connectionRefCount--;
		if (connectionRefCount <= 0 && conn != null && !conn.isClosed()) {
			conn.close();
			conn = null; // Reset connection for safety
			connectionRefCount = 0;
		}
	}

	public static void addOrder(Order o) throws SQLException, IOException {
		connect_to_db();

		int orderID = -1;

		// Insert base order
		String orderQuery = "INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime, " +
				"ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete) " +
				"VALUES (?, ?, ?, ?, ?, ?)";

		try (PreparedStatement orderStmt = conn.prepareStatement(orderQuery, Statement.RETURN_GENERATED_KEYS)) {
			if (o.getCustID() == -1) {
				orderStmt.setNull(1, java.sql.Types.INTEGER); // Null for Dine-In orders
			} else {
				orderStmt.setInt(1, o.getCustID());
			}
			orderStmt.setString(2, o.getOrderType());
			orderStmt.setString(3, o.getDate());
			orderStmt.setDouble(4, o.getCustPrice());
			orderStmt.setDouble(5, o.getBusPrice());
			orderStmt.setBoolean(6, o.getIsComplete());

			int rowsInserted = orderStmt.executeUpdate();
			if (rowsInserted == 0) {
				throw new SQLException("Failed to insert the order into the database.");
			}

			// Retrieve generated order ID
			try (ResultSet generatedKeys = orderStmt.getGeneratedKeys()) {
				if (generatedKeys.next()) {
					orderID = generatedKeys.getInt(1);
				} else {
					throw new SQLException("Failed to retrieve the generated order ID.");
				}
			}
		}

		// Insert order-specific data based on subtype
		switch (o.getOrderType()) {
			case dine_in:
				if (o instanceof DineinOrder) {
					String dineinQuery = "INSERT INTO dinein (ordertable_OrderID, dinein_TableNum) " +
							"VALUES (?, ?)";
					try (PreparedStatement dineinStmt = conn.prepareStatement(dineinQuery)) {
						dineinStmt.setInt(1, orderID);
						dineinStmt.setInt(2, ((DineinOrder) o).getTableNum());
						dineinStmt.executeUpdate();
					}
				}
				break;

			case delivery:
				if (o instanceof DeliveryOrder) {
					String deliveryQuery = "INSERT INTO delivery (ordertable_OrderID, delivery_HouseNum, " +
							"delivery_Street, delivery_City, delivery_State, delivery_Zip, delivery_isDelivered) " +
							"VALUES (?, ?, ?, ?, ?, ?, ?)";
					try (PreparedStatement deliveryStmt = conn.prepareStatement(deliveryQuery)) {
						DeliveryOrder deliveryOrder = (DeliveryOrder) o;
						String[] addressParts = deliveryOrder.getAddress().split("\t");
						deliveryStmt.setInt(1, orderID);
						deliveryStmt.setInt(2, Integer.parseInt(addressParts[0]));
						deliveryStmt.setString(3, addressParts[1]);
						deliveryStmt.setString(4, addressParts[2]);
						deliveryStmt.setString(5, addressParts[3]);
						deliveryStmt.setInt(6, Integer.parseInt(addressParts[4]));
						deliveryStmt.setBoolean(7, deliveryOrder.getIsComplete());
						deliveryStmt.executeUpdate();
					}
				}
				break;

			case pickup:
				if (o instanceof PickupOrder) {
					String pickupQuery = "INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp) " +
							"VALUES (?, ?)";
					try (PreparedStatement pickupStmt = conn.prepareStatement(pickupQuery)) {
						pickupStmt.setInt(1, orderID);
						pickupStmt.setBoolean(2, ((PickupOrder) o).getIsPickedUp());
						pickupStmt.executeUpdate();
					}
				}
				break;
		}

		// Insert pizzas
		for (Pizza pizza : o.getPizzaList()) {
			pizza.setOrderID(orderID);
			addPizza(java.sql.Timestamp.valueOf(o.getDate()), orderID, pizza);
		}

		// Insert order discounts
		String discountQuery = "INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID) " +
				"VALUES (?, ?)";
		try (PreparedStatement discountStmt = conn.prepareStatement(discountQuery)) {
			for (Discount discount : o.getDiscountList()) {
				discountStmt.setInt(1, orderID);
				discountStmt.setInt(2, discount.getDiscountID());
				discountStmt.executeUpdate();
			}
		}

		close_connection();
	}

	public static int addPizza(java.util.Date d, int orderID, Pizza p) throws SQLException, IOException {
		connect_to_db();

		int pizzaID = -1;

		// Insert pizza
		String pizzaQuery = "INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, " +
				"pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice) " +
				"VALUES (?, ?, ?, ?, ?, ?, ?)";

		try (PreparedStatement pizzaStmt = conn.prepareStatement(pizzaQuery, Statement.RETURN_GENERATED_KEYS)) {
			pizzaStmt.setString(1, p.getSize());
			pizzaStmt.setString(2, p.getCrustType());
			pizzaStmt.setInt(3, orderID);
			pizzaStmt.setString(4, p.getPizzaState());
			pizzaStmt.setTimestamp(5, new java.sql.Timestamp(d.getTime()));
			pizzaStmt.setDouble(6, p.getCustPrice());
			pizzaStmt.setDouble(7, p.getBusPrice());

			int rowsInserted = pizzaStmt.executeUpdate();
			if (rowsInserted == 0) {
				throw new SQLException("Failed to insert pizza into the database.");
			}

			// Retrieve generated pizza ID
			try (ResultSet generatedKeys = pizzaStmt.getGeneratedKeys()) {
				if (generatedKeys.next()) {
					pizzaID = generatedKeys.getInt(1);
				} else {
					throw new SQLException("Failed to retrieve the generated pizza ID.");
				}
			}
		}

		// Insert toppings on pizza
		String toppingQuery = "INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_isDouble) " +
				"VALUES (?, ?, ?)";
		try (PreparedStatement toppingStmt = conn.prepareStatement(toppingQuery)) {
			for (Topping t : p.getToppings()) {
				toppingStmt.setInt(1, pizzaID);
				toppingStmt.setInt(2, t.getTopID());
				toppingStmt.setBoolean(3, t.getDoubled());

				toppingStmt.executeUpdate();
			}
		}

		// Insert discounts for pizza
		String discountQuery = "INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID) " +
				"VALUES (?, ?)";
		try (PreparedStatement discountStmt = conn.prepareStatement(discountQuery)) {
			for (Discount di : p.getDiscounts()) {
				discountStmt.setInt(1, pizzaID);
				discountStmt.setInt(2, di.getDiscountID());

				discountStmt.executeUpdate();
			}
		}

		close_connection();
		return pizzaID;
	}

	public static int addCustomer(Customer c) throws SQLException, IOException {
		connect_to_db();

		String query = "INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum) " +
				"VALUES (?, ?, ?)";

		try (PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
			stmt.setString(1, c.getFName());
			stmt.setString(2, c.getLName());
			stmt.setString(3, c.getPhone());

			int rowsInserted = stmt.executeUpdate();
			if (rowsInserted == 0) {
				throw new SQLException("Failed to add the customer.");
			}

			// Retrieve generated customer ID
			try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
				if (generatedKeys.next()) {
					return generatedKeys.getInt(1);
				} else {
					throw new SQLException("Failed to retrieve the customer ID.");
				}
			}
		} finally {
			close_connection();
		}
	}

	public static void completeOrder(int OrderID, order_state newState) throws SQLException, IOException {
		connect_to_db();

		try {
			if (newState == order_state.PREPARED) {
				// Mark order as complete
				String orderQuery = "UPDATE ordertable " +
						"SET ordertable_isComplete = 1 " +
						"WHERE ordertable_OrderID = ?";
				try (PreparedStatement orderStmt = conn.prepareStatement(orderQuery)) {
					orderStmt.setInt(1, OrderID);
					orderStmt.executeUpdate();
				}

				// Mark all pizzas in order as completed
				String pizzaQuery = "UPDATE pizza SET " +
						"pizza_PizzaState = 'Prepared' " +
						"WHERE ordertable_OrderID = ?";
				try (PreparedStatement pizzaStmt = conn.prepareStatement(pizzaQuery)) {
					pizzaStmt.setInt(1, OrderID);
					pizzaStmt.executeUpdate();
				}

			} else if (newState == order_state.DELIVERED) {
				// Mark delivery status as delivered
				String deliveryQuery = "UPDATE delivery " +
						"SET delivery_isDelivered = 1 " +
						"WHERE ordertable_OrderID = ?";
				try (PreparedStatement deliveryStmt = conn.prepareStatement(deliveryQuery)) {
					deliveryStmt.setInt(1, OrderID);
					deliveryStmt.executeUpdate();
				}

			} else if (newState == order_state.PICKEDUP) {
				// Mark pickup status as picked up
				String pickupQuery = "UPDATE pickup " +
						"SET pickup_IsPickedUp = 1 " +
						"WHERE ordertable_OrderID = ?";
				try (PreparedStatement pickupStmt = conn.prepareStatement(pickupQuery)) {
					pickupStmt.setInt(1, OrderID);
					pickupStmt.executeUpdate();
				}
			} else {
				throw new IllegalArgumentException("Invalid order state provided.");
			}
		} finally {
			close_connection();
		}
	}

	public static ArrayList<Order> getOrders(int status) throws SQLException, IOException {
		ArrayList<Order> orders = new ArrayList<>();

		connect_to_db();

		String query = "SELECT o.ordertable_OrderID, o.customer_CustID, o.ordertable_OrderType, " +
				"o.ordertable_OrderDateTime, o.ordertable_CustPrice, o.ordertable_BusPrice, o.ordertable_isComplete " +
				"FROM ordertable o ";
		switch (status) {
			case 1: // Open orders
				query += "WHERE o.ordertable_isComplete = 0 ";
				break;
			case 2: // Completed orders
				query += "WHERE o.ordertable_isComplete = 1 ";
				break;
			case 3: // All orders
				break;
			default:
				throw new IllegalArgumentException("Invalid status value.");
		}
		query += "ORDER BY o.ordertable_OrderDateTime ASC";

		try (PreparedStatement stmt = conn.prepareStatement(query); ResultSet rs = stmt.executeQuery()) {
			while (rs.next()) {
				int orderID = rs.getInt("ordertable_OrderID");
				int custID = rs.getInt("customer_CustID");
				String orderType = rs.getString("ordertable_OrderType");
				String date = rs.getString("ordertable_OrderDateTime");
				double custPrice = rs.getDouble("ordertable_CustPrice");
				double busPrice = rs.getDouble("ordertable_BusPrice");
				boolean isComplete = rs.getBoolean("ordertable_isComplete");

				Order order = switch (orderType) {
                    case pickup -> getPickupOrder(orderID, custID, date, custPrice, busPrice, isComplete);
                    case delivery -> getDeliveryOrder(orderID, custID, date, custPrice, busPrice, isComplete);
                    case dine_in -> getDineinOrder(orderID, custID, date, custPrice, busPrice, isComplete);
                    default -> null;
                };

                if (order != null) {
					// Fetch and add pizzas and order discounts
					ArrayList<Pizza> pizzas = getPizzas(order);
					order.setPizzaList(pizzas);

					ArrayList<Discount> discounts = getDiscounts(order);
					order.setDiscountList(discounts);

					orders.add(order);
				}
			}
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return orders;
	}

	// Helper function for getting data specific to pickup orders
	private static PickupOrder getPickupOrder(int orderID, int custID, String date, double custPrice, double busPrice, boolean isComplete) throws SQLException {
		String queryPickup = "SELECT pickup_IsPickedUp " +
				"FROM pickup " +
				"WHERE ordertable_OrderID = ?";
		try (PreparedStatement stmtPickup = conn.prepareStatement(queryPickup)) {
			stmtPickup.setInt(1, orderID);
			try (ResultSet rsPickup = stmtPickup.executeQuery()) {
				if (rsPickup.next()) {
					boolean isPickedUp = rsPickup.getBoolean("pickup_IsPickedUp");
					return new PickupOrder(orderID, custID, date, custPrice, busPrice, isComplete, isPickedUp);
				}
			}
		}
		return null;
	}

	// Helper function for getting data specific to delivery orders
	private static DeliveryOrder getDeliveryOrder(int orderID, int custID, String date, double custPrice, double busPrice, boolean isComplete) throws SQLException {
		String queryDelivery = "SELECT delivery_HouseNum, delivery_Street, delivery_City, " +
				"delivery_State, delivery_Zip, delivery_isDelivered " +
				"FROM delivery " +
				"WHERE ordertable_OrderID = ?";
		try (PreparedStatement stmtDelivery = conn.prepareStatement(queryDelivery)) {
			stmtDelivery.setInt(1, orderID);
			try (ResultSet rsDelivery = stmtDelivery.executeQuery()) {
				if (rsDelivery.next()) {
					String address = rsDelivery.getInt("delivery_HouseNum") + " " +
							rsDelivery.getString("delivery_Street") + ", " +
							rsDelivery.getString("delivery_City") + ", " +
							rsDelivery.getString("delivery_State") + " " +
							rsDelivery.getInt("delivery_Zip");
					boolean isDelivered = rsDelivery.getBoolean("delivery_isDelivered");
					return new DeliveryOrder(orderID, custID, date, custPrice, busPrice, isComplete, address, isDelivered);
				}
			}
		}
		return null;
	}

	// Helper function for getting data dine-in to pickup orders
	private static DineinOrder getDineinOrder(int orderID, int custID, String date, double custPrice, double busPrice, boolean isComplete) throws SQLException {
		String queryDinein = "SELECT dinein_TableNum FROM dinein WHERE ordertable_OrderID = ?";
		try (PreparedStatement stmtDinein = conn.prepareStatement(queryDinein)) {
			stmtDinein.setInt(1, orderID);
			try (ResultSet rsDinein = stmtDinein.executeQuery()) {
				if (rsDinein.next()) {
					int tableNum = rsDinein.getInt("dinein_TableNum");
					return new DineinOrder(orderID, custID, date, custPrice, busPrice, isComplete, tableNum);
				}
			}
		}
		return null;
	}

	public static Order getLastOrder() throws SQLException, IOException {
		Order lastOrder = null;

		connect_to_db();

		String queryOrder = "SELECT o.ordertable_OrderID, o.customer_CustID, o.ordertable_OrderType, " +
				"o.ordertable_OrderDateTime, o.ordertable_CustPrice, o.ordertable_BusPrice, o.ordertable_isComplete " +
				"FROM ordertable o " +
				"ORDER BY o.ordertable_OrderID DESC LIMIT 1";

		try (PreparedStatement stmtOrder = conn.prepareStatement(queryOrder); ResultSet rsOrder = stmtOrder.executeQuery()) {
			if (rsOrder.next()) {
				int orderID = rsOrder.getInt("ordertable_OrderID");
				int custID = rsOrder.getInt("customer_CustID");
				String orderType = rsOrder.getString("ordertable_OrderType");
				String date = rsOrder.getString("ordertable_OrderDateTime");
				double custPrice = rsOrder.getDouble("ordertable_CustPrice");
				double busPrice = rsOrder.getDouble("ordertable_BusPrice");
				boolean isComplete = rsOrder.getBoolean("ordertable_isComplete");

				// Get additional details based on order subtype
                lastOrder = switch (orderType) {
                    case "pickup" -> getPickupOrder(orderID, custID, date, custPrice, busPrice, isComplete);
                    case "delivery" -> getDeliveryOrder(orderID, custID, date, custPrice, busPrice, isComplete);
                    case "dinein" -> getDineinOrder(orderID, custID, date, custPrice, busPrice, isComplete);
                    default -> lastOrder;
                };
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving the last order", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return lastOrder;
	}

	public static ArrayList<Order> getOrdersByDate(String date) throws SQLException, IOException {
		ArrayList<Order> orders = new ArrayList<>();

		connect_to_db();

		String query = "SELECT o.ordertable_OrderID, o.customer_CustID, o.ordertable_OrderType, " +
				"o.ordertable_OrderDateTime, o.ordertable_CustPrice, o.ordertable_BusPrice, o.ordertable_isComplete " +
				"FROM ordertable o " +
				"WHERE DATE(o.ordertable_OrderDateTime) = ? " +
				"ORDER BY o.ordertable_OrderDateTime ASC";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setString(1, date); // Use provided date as a parameter
			try (ResultSet rs = stmt.executeQuery()) {
				while (rs.next()) {
					int orderID = rs.getInt("ordertable_OrderID");
					int custID = rs.getInt("customer_CustID");
					String orderType = rs.getString("ordertable_OrderType");
					String orderDate = rs.getString("ordertable_OrderDateTime");
					double custPrice = rs.getDouble("ordertable_CustPrice");
					double busPrice = rs.getDouble("ordertable_BusPrice");
					boolean isComplete = rs.getBoolean("ordertable_isComplete");

					Order order = switch (orderType) {
                        case pickup -> getPickupOrder(orderID, custID, orderDate, custPrice, busPrice, isComplete);
                        case delivery -> getDeliveryOrder(orderID, custID, orderDate, custPrice, busPrice, isComplete);
                        case dine_in -> getDineinOrder(orderID, custID, orderDate, custPrice, busPrice, isComplete);
                        default -> null;
                    };

                    if (order != null) {
						// Populate pizzas and discounts for the order
						ArrayList<Pizza> pizzas = getPizzas(order);
						order.setPizzaList(pizzas);

						ArrayList<Discount> discounts = getDiscounts(order);
						order.setDiscountList(discounts);

						orders.add(order);
					}
				}
			}
		} finally {
			close_connection();
		}

		return orders;
	}

	public static ArrayList<Discount> getDiscountList() throws SQLException, IOException {
		ArrayList<Discount> discountList = new ArrayList<>();

		connect_to_db();

		String query = "SELECT discount_DiscountID, discount_DiscountName, discount_Amount, discount_IsPercent " +
				"FROM discount " +
				"ORDER BY discount_DiscountName;";

		try (PreparedStatement stmt = conn.prepareStatement(query); ResultSet rs = stmt.executeQuery()) {
			while (rs.next()) {
				int discountID = rs.getInt("discount_DiscountID");
				String discountName = rs.getString("discount_DiscountName");
				double amount = rs.getDouble("discount_Amount");
				boolean isPercent = rs.getBoolean("discount_IsPercent");

				Discount discount = new Discount(discountID, discountName, amount, isPercent);
				discountList.add(discount);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving discount list", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return discountList;
	}

	public static Discount findDiscountByName(String name) throws SQLException, IOException {
		connect_to_db();

		String query = "SELECT discount_DiscountID, discount_DiscountName, discount_Amount, discount_IsPercent " +
				"FROM discount " +
				"WHERE discount_DiscountName = ?;";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setString(1, name); // Set name parameter in the query
			try (ResultSet rs = stmt.executeQuery()) {
				if (rs.next()) {
					int discountID = rs.getInt("discount_DiscountID");
					String discountName = rs.getString("discount_DiscountName");
					double amount = rs.getDouble("discount_Amount");
					boolean isPercent = rs.getBoolean("discount_IsPercent");

					return new Discount(discountID, discountName, amount, isPercent);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving discount by name", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return null;
	}

	public static ArrayList<Customer> getCustomerList() throws SQLException, IOException {
		ArrayList<Customer> customerList = new ArrayList<>();

		connect_to_db();

		String query = "SELECT customer_CustID, customer_FName, customer_LName,customer_PhoneNum " +
				"FROM customer " +
				"ORDER BY customer_LName, customer_FName, customer_PhoneNum;";

		try (PreparedStatement stmt = conn.prepareStatement(query); ResultSet rs = stmt.executeQuery()) {
			while (rs.next()) {
				int custID = rs.getInt("customer_CustID");
				String fName = rs.getString("customer_FName");
				String lName = rs.getString("customer_LName");
				String phone = rs.getString("customer_PhoneNum");

				Customer customer = new Customer(custID, fName, lName, phone);
				customerList.add(customer);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving customer list", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return customerList;
	}

	public static Customer findCustomerByPhone(String phoneNumber) throws SQLException, IOException {
		connect_to_db();

		String query = "SELECT customer_CustID, customer_FName, customer_LName, customer_PhoneNum " +
				"FROM customer " +
				"WHERE customer_PhoneNum = ?;";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setString(1, phoneNumber); // Set phone number parameter in the query
			try (ResultSet rs = stmt.executeQuery()) {
				if (rs.next()) {
					int custID = rs.getInt("customer_CustID");
					String firstName = rs.getString("customer_FName");
					String lastName = rs.getString("customer_LName");
					String phone = rs.getString("customer_PhoneNum");

					return new Customer(custID, firstName, lastName, phone);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving customer by phone number", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return null;
	}


	public static String getCustomerName(int CustID) throws SQLException, IOException 
	{
		/*
		 * COMPLETED...WORKING Example!
		 * 
		 * This is a helper method to fetch and format the name of a customer
		 * based on a customer ID. This is an example of how to interact with
		 * your database from Java.  
		 * 
		 * Notice how the connection to the DB made at the start of the 
		 *
		 */

		 connect_to_db();

		/* 
		 * an example query using a constructed string...
		 * remember, this style of query construction could be subject to sql injection attacks!
		 * 
		 */
		String cname1 = "";
		String cname2 = "";
		String query = "Select customer_FName, customer_LName From customer WHERE customer_CustID=" + CustID + ";";
		Statement stmt = conn.createStatement();
		ResultSet rset = stmt.executeQuery(query);
		
		while(rset.next())
		{
			cname1 = rset.getString(1) + " " + rset.getString(2); 
		}

		/* 
		* an BETTER example of the same query using a prepared statement...
		* with exception handling
		* 
		*/
		try {
			PreparedStatement os;
			ResultSet rset2;
			String query2;
			query2 = "Select customer_FName, customer_LName From customer WHERE customer_CustID=?;";
			os = conn.prepareStatement(query2);
			os.setInt(1, CustID);
			rset2 = os.executeQuery();
			while(rset2.next())
			{
				cname2 = rset2.getString("customer_FName") + " " + rset2.getString("customer_LName"); // note the use of field names in the getSting methods
			}
		} catch (SQLException e) {
			e.printStackTrace();
			// process the error or re-raise the exception to a higher level
		}

		close_connection();

		return cname1;
		// OR
		// return cname2;

	}


	public static ArrayList<Topping> getToppingList() throws SQLException, IOException {
		ArrayList<Topping> toppingList = new ArrayList<>();

		connect_to_db();

		String query = "SELECT topping_TopID, topping_TopName, topping_SmallAMT, topping_MedAMT, topping_LgAMT, " +
				"topping_XLAMT, topping_CustPrice, topping_BusPrice, topping_MinINVT, topping_CurINVT " +
				"FROM topping " +
				"ORDER BY topping_TopName;";

		try (PreparedStatement stmt = conn.prepareStatement(query); ResultSet rs = stmt.executeQuery()) {
			while (rs.next()) {
				int topID = rs.getInt("topping_TopID");
				String topName = rs.getString("topping_TopName");
				double smallAMT = rs.getDouble("topping_SmallAMT");
				double medAMT = rs.getDouble("topping_MedAMT");
				double lgAMT = rs.getDouble("topping_LgAMT");
				double xlAMT = rs.getDouble("topping_XLAMT");
				double custPrice = rs.getDouble("topping_CustPrice");
				double busPrice = rs.getDouble("topping_BusPrice");
				int minINVT = rs.getInt("topping_MinINVT");
				int curINVT = rs.getInt("topping_CurINVT");

				Topping topping = new Topping(topID, topName, smallAMT, medAMT, lgAMT, xlAMT, custPrice, busPrice, minINVT, curINVT);
				toppingList.add(topping);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving topping list", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return toppingList;
	}


	public static Topping findToppingByName(String toppingName) throws SQLException, IOException {
		connect_to_db();

		String query = "SELECT topping_TopID, topping_TopName, topping_SmallAMT, topping_MedAMT, topping_LgAMT, " +
				"topping_XLAMT, topping_CustPrice, topping_BusPrice, topping_MinINVT, topping_CurINVT " +
				"FROM topping " +
				"WHERE topping_TopName = ?;";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setString(1, toppingName); // Set topping name parameter in the query
			try (ResultSet rs = stmt.executeQuery()) {
				if (rs.next()) {
					int topID = rs.getInt("topping_TopID");
					String name = rs.getString("topping_TopName");
					double smallAMT = rs.getDouble("topping_SmallAMT");
					double medAMT = rs.getDouble("topping_MedAMT");
					double lgAMT = rs.getDouble("topping_LgAMT");
					double xlAMT = rs.getDouble("topping_XLAMT");
					double custPrice = rs.getDouble("topping_CustPrice");
					double busPrice = rs.getDouble("topping_BusPrice");
					int minINVT = rs.getInt("topping_MinINVT");
					int curINVT = rs.getInt("topping_CurINVT");

					return new Topping(topID, name, smallAMT, medAMT, lgAMT, xlAMT, custPrice, busPrice, minINVT, curINVT);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving topping by name", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return null;
	}


	public static ArrayList<Topping> getToppingsOnPizza(Pizza p) throws SQLException, IOException {
		ArrayList<Topping> toppings = new ArrayList<>();
		connect_to_db();

		String query = "SELECT t.topping_TopID, t.topping_TopName, t.topping_SmallAMT, t.topping_MedAMT, " +
				"t.topping_LgAMT, t.topping_XLAMT, t.topping_CustPrice, t.topping_BusPrice, " +
				"t.topping_MinINVT, t.topping_CurINVT, pt.pizza_topping_IsDouble " +
				"FROM pizza_topping pt " +
				"JOIN topping t ON pt.topping_TopID = t.topping_TopID " +
				"WHERE pt.pizza_PizzaID = ?";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setInt(1, p.getPizzaID()); // Set Pizza ID in the query
			try (ResultSet rs = stmt.executeQuery()) {
				while (rs.next()) {
					int topID = rs.getInt("topping_TopID");
					String topName = rs.getString("topping_TopName");
					double smallAMT = rs.getDouble("topping_SmallAMT");
					double medAMT = rs.getDouble("topping_MedAMT");
					double lgAMT = rs.getDouble("topping_LgAMT");
					double xlAMT = rs.getDouble("topping_XLAMT");
					double custPrice = rs.getDouble("topping_CustPrice");
					double busPrice = rs.getDouble("topping_BusPrice");
					int minINVT = rs.getInt("topping_MinINVT");
					int curINVT = rs.getInt("topping_CurINVT");
					boolean isDouble = rs.getBoolean("pizza_topping_isDouble");

					Topping topping = new Topping(topID, topName, smallAMT, medAMT, lgAMT, xlAMT, custPrice, busPrice, minINVT, curINVT);
					topping.setDoubled(isDouble);
					toppings.add(topping);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving toppings for the pizza", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return toppings;
	}

	public static void addToInventory(int toppingID, double quantity) throws SQLException, IOException {
		connect_to_db();

		String query = "UPDATE topping " +
				"SET topping_CurINVT = topping_CurINVT + ? " +
				"WHERE topping_TopID = ?";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setDouble(1, quantity);
			stmt.setInt(2, toppingID);

			int rowsUpdated = stmt.executeUpdate();
			if (rowsUpdated == 0) {
				throw new SQLException("Topping with ID " + toppingID + " does not exist.");
			}
		} finally {
			close_connection();
		}
	}

	public static ArrayList<Pizza> getPizzas(Order o) throws SQLException, IOException {
		ArrayList<Pizza> pizzas = new ArrayList<>();

		connect_to_db();

		String query = "SELECT p.pizza_PizzaID, p.pizza_CrustType, p.pizza_Size, p.ordertable_OrderID, " +
				"p.pizza_PizzaState, p.pizza_PizzaDate, p.pizza_CustPrice, p.pizza_BusPrice " +
				"FROM pizza p " +
				"WHERE p.ordertable_OrderID = ?";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setInt(1, o.getOrderID()); // Set Order ID in the query
			try (ResultSet rs = stmt.executeQuery()) {
				while (rs.next()) {
					int pizzaID = rs.getInt("pizza_PizzaID");
					String crustType = rs.getString("pizza_CrustType");
					String size = rs.getString("pizza_Size");
					int orderID = rs.getInt("ordertable_OrderID");
					String state = rs.getString("pizza_PizzaState");
					String date = rs.getString("pizza_PizzaDate");
					double custPrice = rs.getDouble("pizza_CustPrice");
					double busPrice = rs.getDouble("pizza_BusPrice");

					// Create a Pizza object
					Pizza pizza = new Pizza(pizzaID, size, crustType, orderID, state, date, custPrice, busPrice);

					// Populate toppings and discounts for the pizza
					ArrayList<Topping> toppings = getToppingsOnPizza(pizza);
					pizza.setToppings(toppings);

					ArrayList<Discount> discounts = getDiscounts(pizza);
					pizza.setDiscounts(discounts);

					// Add pizza to the list
					pizzas.add(pizza);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving pizzas for the order", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return pizzas;
	}

	public static ArrayList<Discount> getDiscounts(Order o) throws SQLException, IOException {
		ArrayList<Discount> discounts = new ArrayList<>();

		connect_to_db();

		String query = "SELECT d.discount_DiscountID, d.discount_DiscountName, d.discount_Amount, d.discount_IsPercent " +
				"FROM order_discount od " +
				"JOIN discount d ON od.discount_DiscountID = d.discount_DiscountID " +
				"WHERE od.ordertable_OrderID = ?";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setInt(1, o.getOrderID()); // Set Order ID in the query
			try (ResultSet rs = stmt.executeQuery()) {
				while (rs.next()) {
					int discountID = rs.getInt("discount_DiscountID");
					String discountName = rs.getString("discount_DiscountName");
					double amount = rs.getDouble("discount_Amount");
					boolean isPercent = rs.getBoolean("discount_IsPercent");

					Discount discount = new Discount(discountID, discountName, amount, isPercent);
					discounts.add(discount);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving discounts for the order", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return discounts;
	}

	public static ArrayList<Discount> getDiscounts(Pizza p) throws SQLException, IOException {
		ArrayList<Discount> discounts = new ArrayList<>();

		connect_to_db();

		String query = "SELECT d.discount_DiscountID, d.discount_DiscountName, d.discount_Amount, d.discount_IsPercent " +
				"FROM pizza_discount pd " +
				"JOIN discount d ON pd.discount_DiscountID = d.discount_DiscountID " +
				"WHERE pd.pizza_PizzaID = ?";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setInt(1, p.getPizzaID()); // Set Pizza ID in the query
			try (ResultSet rs = stmt.executeQuery()) {
				while (rs.next()) {
					int discountID = rs.getInt("discount_DiscountID");
					String discountName = rs.getString("discount_DiscountName");
					double amount = rs.getDouble("discount_Amount");
					boolean isPercent = rs.getBoolean("discount_IsPercent");

					Discount discount = new Discount(discountID, discountName, amount, isPercent);
					discounts.add(discount);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving discounts for the pizza", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return discounts;
	}

	public static double getBaseCustPrice(String size, String crust) throws SQLException, IOException {
		double baseCustPrice = 0.0;

		connect_to_db();

		String query = "SELECT baseprice_CustPrice " +
				"FROM baseprice " +
				"WHERE baseprice_Size = ? AND baseprice_CrustType = ?";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setString(1, size);
			stmt.setString(2, crust);
			try (ResultSet rs = stmt.executeQuery()) {
				if (rs.next()) {
					baseCustPrice = rs.getDouble("baseprice_CustPrice");
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving base customer price for size: " + size + " and crust: " + crust, e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return baseCustPrice;
	}

	public static double getBaseBusPrice(String size, String crust) throws SQLException, IOException {
		double baseBusPrice = 0.0;

		connect_to_db();

		String query = "SELECT baseprice_BusPrice " +
				"FROM baseprice " +
				"WHERE baseprice_Size = ? AND baseprice_CrustType = ?";

		try (PreparedStatement stmt = conn.prepareStatement(query)) {
			stmt.setString(1, size);
			stmt.setString(2, crust);
			try (ResultSet rs = stmt.executeQuery()) {
				if (rs.next()) {
					baseBusPrice = rs.getDouble("baseprice_BusPrice");
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving base business price for size: " + size + " and crust: " + crust, e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}

		return baseBusPrice;
	}

	public static void printToppingPopReport() throws SQLException, IOException {
		connect_to_db();

		String query = "SELECT Topping, ToppingCount " +
				"FROM ToppingPopularity";

		try (Statement stmt = conn.createStatement();
			 ResultSet rs = stmt.executeQuery(query)) {

			// Print header
			System.out.printf("%-20s %-15s%n", "Topping", "Topping Count");
			System.out.printf("%-20s %-15s%n", "-------", "-------------");

			// Print each row
			while (rs.next()) {
				String toppingName = rs.getString("Topping");
				int toppingCount = rs.getInt("ToppingCount");
				System.out.printf("%-20s %-15d%n", toppingName, toppingCount);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving the ToppingPopularity report", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}
	}

	public static void printProfitByPizzaReport() throws SQLException, IOException {
		connect_to_db();

		String query = "SELECT Size, Crust, Profit, OrderMonth " +
				"FROM ProfitByPizza";

		try (Statement stmt = conn.createStatement();
			 ResultSet rs = stmt.executeQuery(query)) {

			// Print header
			System.out.printf("%-12s %-12s %-10s %-15s%n", "Pizza Size", "Pizza Crust", "Profit", "Last Order Date");
			System.out.printf("%-12s %-12s %-10s %-15s%n", "----------", "-----------", "------", "---------------");

			// Print each row
			while (rs.next()) {
				String pizzaSize = rs.getString("Size");
				String pizzaCrust = rs.getString("Crust");
				double profit = rs.getDouble("Profit");
				String lastOrderDate = rs.getString("OrderMonth");
				System.out.printf("%-12s %-12s $%-9.2f %-15s%n", pizzaSize, pizzaCrust, profit, lastOrderDate);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving the ProfitByPizza report", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection();
			}
		}
	}

	public static void printProfitByOrderType() throws SQLException, IOException {
		connect_to_db();

		String query = "SELECT customerType, OrderMonth, TotalOrderPrice, TotalOrderCost, Profit " +
				"FROM ProfitByOrderType";

		try (Statement stmt = conn.createStatement();
			 ResultSet rs = stmt.executeQuery(query)) {

			// Print header
			System.out.printf("%-15s %-12s %-20s %-20s %-10s%n", "Customer Type", "Order Month", "Total Order Price", "Total Order Cost", "Profit");
			System.out.printf("%-15s %-12s %-20s %-20s %-10s%n", "-------------", "-----------", "-----------------", "-----------------", "------");

			// Print each row
			while (rs.next()) {
				String customerType = rs.getString("customerType");
				String orderMonth = rs.getString("OrderMonth");
				double totalOrderPrice = rs.getDouble("TotalOrderPrice");
				double totalOrderCost = rs.getDouble("TotalOrderCost");
				double profit = rs.getDouble("Profit");

				// Print row
				System.out.printf("%-15s %-12s $%-19.2f $%-19.2f $%-9.2f%n",
						customerType != null ? customerType : "", // Handle NULL customerType
						orderMonth,
						totalOrderPrice,
						totalOrderCost,
						profit);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException("Error retrieving the ProfitByOrderType report", e);
		} finally {
			if (conn != null && !conn.isClosed()) {
				close_connection(); // Close the database connection
			}
		}
	}


	/*
	 * These private methods help get the individual components of an SQL datetime object. 
	 * You're welcome to keep them or remove them....but they are usefull!
	 */
	private static int getYear(String date)// assumes date format 'YYYY-MM-DD HH:mm:ss'
	{
		return Integer.parseInt(date.substring(0,4));
	}
	private static int getMonth(String date)// assumes date format 'YYYY-MM-DD HH:mm:ss'
	{
		return Integer.parseInt(date.substring(5, 7));
	}
	private static int getDay(String date)// assumes date format 'YYYY-MM-DD HH:mm:ss'
	{
		return Integer.parseInt(date.substring(8, 10));
	}

	public static boolean checkDate(int year, int month, int day, String dateOfOrder)
	{
		if(getYear(dateOfOrder) > year)
			return true;
		else if(getYear(dateOfOrder) < year)
			return false;
		else
		{
			if(getMonth(dateOfOrder) > month)
				return true;
			else if(getMonth(dateOfOrder) < month)
				return false;
			else
			{
				if(getDay(dateOfOrder) >= day)
					return true;
				else
					return false;
			}
		}
	}
	
}