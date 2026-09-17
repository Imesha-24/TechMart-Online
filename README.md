🛒 TechMart Online
Java Jakarta EE PostgreSQL Maven Payara Server

TechMart Online is a multi-tier, enterprise-grade E-Commerce web application developed using Jakarta EE 10 (Java 17) and PostgreSQL. The platform features complete customer-facing storefront capabilities, asynchronous background processing using Jakarta Messaging (JMS) and Message-Driven Beans (MDBs), Enterprise JavaBeans (EJBs), and a full-featured administrator back-office dashboard.

📑 Table of Contents
Features
Customer Storefront
Admin Portal
Enterprise & Asynchronous Processing
Architecture & Tech Stack
Database Schema
Getting Started
Prerequisites
Database Setup
Configuration
Build and Package
Deployment
Default Credentials
Project Directory Structure
Testing & Quality Assurance
License
✨ Features
Customer Storefront
Product Catalog & Discovery: Browse technology products filtered by category, brand, and color with real-time search and sorting.
Product Details: Comprehensive product pages showcasing specifications, stock status, pricing, and images.
Shopping Cart: Real-time cart management (add, remove, update quantities, dynamic subtotal calculations) with AJAX and session persistence.
Checkout & Orders: Multi-step checkout with payment simulation, shipping calculation, and instant order generation.
Order Tracking & History: Track order lifecycle (Pending → Processing → Shipped → Delivered → Cancelled).
User Authentication & Profile: Secure registration, login/logout, and account management with SHA-256 hashed credentials.
In-App Notifications: Real-time notifications for order status updates, stock changes, and account alerts.
Admin Portal
Executive Dashboard: KPI summary cards (Total Revenue, Orders, Products, Registered Users), sales breakdown charts, and recent activity logs.
Product Management: Full CRUD operations for product catalog management, category/brand/color assignment, pricing, and image URLs.
Inventory Control: Real-time stock adjustments, automated inventory audit logs (inventory_logs), and low-stock warning indicators.
Order Management: Review incoming orders, inspect line items, update delivery statuses, and audit customer payments.
User Management: Monitor registered customers and administrators with role-based access controls.
Analytics & Reporting: Sales performance analysis and inventory turnover metrics.
Enterprise & Asynchronous Processing
Enterprise JavaBeans (EJB): Stateless session beans separating business logic from presentation servlets.
Jakarta Messaging (JMS) & MDBs:
OrderProcessingMDB: Asynchronously handles background order verification and processing without blocking user requests.
InventoryAlertMDB: Triggers automated alerts and logs when stock drops below threshold levels.
Security & Filters: AuthFilter and AdminAuthFilter securing private customer and admin endpoints.
🛠 Architecture & Tech Stack
+---------------------------------------------------------+
|              Presentation Tier (JSP, JSTL, JS, CSS)     |
+----------------------------+----------------------------+
                             | HTTP Requests
+----------------------------v----------------------------+
|      Controller Layer (Jakarta Servlets & Filters)      |
+----------------------------+----------------------------+
                             | EJB Lookup / CDI
+----------------------------v----------------------------+
|   Business Layer (Stateless EJBs & JMS Message Producers)|
+----------------------------+----------------------------+
|     JMS Queues & MDBs      |      Data Access (DAOs)    |
+----------------------------+-------------+--------------+
                                           | JDBC / JNDI Pool
                              +------------v--------------+
                              | PostgreSQL 14+ Database   |
                              +---------------------------+
Backend Platform: Jakarta EE 10 / Java 17
Application Server: Payara Server 6.x / GlassFish 7.x
Dependency Management & Build: Apache Maven
Database: PostgreSQL 14+ (Connection Pooling via JNDI DataSource / DriverManager fallback)
Messaging: Jakarta JMS 3.1 & Message-Driven Beans (MDB)
View Layer: Jakarta Server Pages (JSP 3.1), JSTL 3.0, Vanilla JavaScript, Responsive CSS3
Serialization / APIs: Google Gson 2.10
Testing Frameworks: JUnit 5, Mockito, Arquillian (Managed Payara Container), JUnitPerf
🗄 Database Schema
The application uses a relational schema designed for e-commerce workflows:

users: User profiles, authentication credentials, roles (CUSTOMER, ADMIN).
brands, categories, colors: Product classification and attributes.
products: Product inventory details, pricing, descriptions, and stock counts.
carts, cart_items: User shopping carts and persistent line items.
orders, order_items, order_status: Order records and itemized order breakdowns.
payments: Transaction history, payment methods, and statuses.
notifications: User alert feeds.
inventory_logs: Historical audit trail of stock modifications.
The SQL initialization script is located at: src/main/resources/schema.sql

🚀 Getting Started
Prerequisites
Ensure you have installed:

Java Development Kit (JDK) 17 or higher
Apache Maven 3.8+
PostgreSQL 14+
Payara Server 6 Community Edition (or GlassFish 7)
1. Database Setup
Open PostgreSQL CLI or pgAdmin and create a database:
CREATE DATABASE techmartonline;
Execute the schema creation and seed script:
psql -U postgres -d techmartonline -f src/main/resources/schema.sql
2. Configuration
Configure your PostgreSQL database connection in either:

Application fallback (DBConnectionUtil.java): Edit src/main/java/lk/iu/util/DBConnectionUtil.java with your database credentials:
private static final String DB_URL      = "jdbc:postgresql://localhost:5432/techmartonline";
private static final String DB_USER     = "postgres";
private static final String DB_PASSWORD = "your_password";
Payara / GlassFish JNDI Connection Pool (Recommended for Production): Configure a JDBC Resource with JNDI name jdbc/techmart mapped to techmartonline.
3. Build and Package
Build the deployable WAR archive using Maven:

mvn clean package
The resulting artifact TechMartOnline.war will be located inside the target/ directory.

4. Deployment
Option A: Payara Server Web Admin Console
Start Payara Server:
asadmin start-domain
Open the Admin Console at http://localhost:4848.
Navigate to Applications → Deploy...
Select target/TechMartOnline.war and click OK.
Option B: Autodeploy Directory
Copy TechMartOnline.war directly into:

<PAYARA_HOME>/glassfish/domains/domain1/autodeploy/
Access the application at:

Storefront: http://localhost:8080/TechMartOnline/
Admin Portal: http://localhost:8080/TechMartOnline/admin/login
🔑 Default Credentials
The initial seed script provides a pre-configured administrator account:

Role	Email	Password
Administrator	admin@techmart.com	admin123
Customer	(Register via the storefront UI)	(Set upon registration)
📁 Project Directory Structure
TechMart-Online/
├── pom.xml                               # Maven project dependencies & plugins
├── src/
│   ├── main/
│   │   ├── java/lk/iu/
│   │   │   ├── dao/                      # Data Access Objects (Cart, Product, Order, User, etc.)
│   │   │   ├── filter/                   # HTTP Request Filters (AuthFilter, AdminAuthFilter)
│   │   │   ├── listener/                 # Context and Application Lifecycle Listeners
│   │   │   ├── messaging/                # JMS Producers, MDBs (OrderProcessing, InventoryAlert)
│   │   │   ├── model/                    # Domain Entities & Models
│   │   │   ├── service/                  # Business Service Interfaces & EJB Implementations
│   │   │   ├── servlet/                  # HTTP Controllers & REST/JSON API Servlets
│   │   │   └── util/                     # Database Connection & JNDI/EJB Lookup Helpers
│   │   ├── resources/
│   │   │   └── schema.sql                # PostgreSQL DDL Schema and Initial Seed Data
│   │   └── webapp/
│   │       ├── admin/                    # Admin Dashboard, Products, Orders, Inventory JSPs
│   │       ├── assets/                   # CSS stylesheets, JavaScript files, and Images
│   │       ├── components/               # Reusable JSP Components (Header, Footer, Navbar)
│   │       ├── WEB-INF/                  # web.xml, beans.xml, GlassFish resources
│   │       ├── index.jsp                 # Storefront Homepage
│   │       ├── products.jsp              # Product Catalog View
│   │       ├── product-details.jsp       # Single Product View
│   │       ├── cart.jsp                  # Shopping Cart View
│   │       ├── checkout.jsp              # Checkout & Order Placement
│   │       └── orders.jsp                # Customer Order Tracking
│   └── test/
│       ├── java/lk/iu/
│       │   ├── integration/              # Arquillian Integration Tests
│       │   ├── performance/              # JUnitPerf Load & Performance Tests
│       │   └── service/                  # Unit Tests (JUnit 5 + Mockito)
│       └── resources/
│           └── arquillian.xml            # Arquillian Container Configuration
└── README.md
🧪 Testing & Quality Assurance
Run the test suite via Maven:

# Run all unit tests
mvn test

# Run performance and integration tests
mvn test -Dtest=ServicePerformanceTest,CartIntegrationTest

Unit Tests: Mocked service isolation via Mockito.
Integration Tests: In-container execution using Arquillian and Payara Managed Server.
Performance Tests: Throughput and latency benchmarking powered by JUnitPerf.
📄 License
This project is licensed under the MIT License.
