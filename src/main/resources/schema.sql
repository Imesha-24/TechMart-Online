-- ============================================
-- TechMart Online - Database Schema (ERD Version)
-- PostgreSQL Database Setup
-- ============================================

-- Drop tables if they exist (for fresh setup)
DROP TABLE IF EXISTS inventory_logs CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS order_status CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS colors CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS brands CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================
-- Users Table
-- ============================================
CREATE TABLE users (
    user_id    SERIAL PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    password   VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    role       VARCHAR(20) DEFAULT 'CUSTOMER'
);

-- ============================================
-- Brands Table
-- ============================================
CREATE TABLE brands (
    brand_id   SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL
);

-- ============================================
-- Categories Table
-- ============================================
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- ============================================
-- Colors Table
-- ============================================
CREATE TABLE colors (
    color_id   SERIAL PRIMARY KEY,
    color_name VARCHAR(50) NOT NULL
);

-- ============================================
-- Products Table
-- ============================================
CREATE TABLE products (
    product_id     SERIAL PRIMARY KEY,
    product_name   VARCHAR(200) NOT NULL,
    description    TEXT,
    price          NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    image_url      TEXT,
    product_url    TEXT,
    category_id    INTEGER REFERENCES categories(category_id),
    created_at     TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    brand_id       INTEGER REFERENCES brands(brand_id),
    color_id       INTEGER REFERENCES colors(color_id)
);

-- ============================================
-- Carts Table
-- ============================================
CREATE TABLE carts (
    cart_id    SERIAL PRIMARY KEY,
    user_id    INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Cart Items Table
-- ============================================
CREATE TABLE cart_items (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id      INTEGER REFERENCES carts(cart_id) ON DELETE CASCADE,
    product_id   INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
    quantity     INTEGER NOT NULL DEFAULT 1,
    UNIQUE(cart_id, product_id)
);

-- ============================================
-- Notifications Table
-- ============================================
CREATE TABLE notifications (
    notification_id   SERIAL PRIMARY KEY,
    user_id           INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    title             VARCHAR(255) NOT NULL,
    message           TEXT NOT NULL,
    notification_type VARCHAR(50),
    created_at        TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Order Status Table
-- ============================================
CREATE TABLE order_status (
    status_id   SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);

-- ============================================
-- Orders Table
-- ============================================
CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    user_id      INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    total_amount NUMERIC(12,2) NOT NULL,
    order_date   TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status_id    INTEGER REFERENCES order_status(status_id)
);

-- ============================================
-- Order Items Table
-- ============================================
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    INTEGER REFERENCES products(product_id),
    quantity      INTEGER NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL
);

-- ============================================
-- Payments Table
-- ============================================
CREATE TABLE payments (
    payment_id     SERIAL PRIMARY KEY,
    order_id       INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    amount         NUMERIC(10,2) NOT NULL,
    transaction_id VARCHAR(255),
    payment_date   TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Inventory Logs Table
-- ============================================
CREATE TABLE inventory_logs (
    log_id         SERIAL PRIMARY KEY,
    product_id     INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
    previous_stock INTEGER NOT NULL,
    new_stock      INTEGER NOT NULL,
    updated_by     VARCHAR(100),
    updated_at     TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Seed Data
-- ============================================
INSERT INTO users (full_name, email, password, phone, role) VALUES
('Admin User', 'admin@techmart.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '1234567890', 'ADMIN');

INSERT INTO brands (brand_name) VALUES ('Apple'), ('Samsung'), ('Sony'), ('Dell'), ('Logitech'), ('LG'), ('Bose'), ('Keychron');
INSERT INTO categories (category_name) VALUES ('Laptops'), ('Smartphones'), ('Audio'), ('Tablets'), ('Accessories'), ('Monitors'), ('Wearables');
INSERT INTO colors (color_name) VALUES ('Silver'), ('Black'), ('Space Gray'), ('White'), ('Titanium');
INSERT INTO order_status (status_name) VALUES ('Pending'), ('Processing'), ('Shipped'), ('Delivered'), ('Cancelled');

-- Example Product insertions linking to brands, categories, colors (using IDs generated above)
INSERT INTO products (product_name, description, price, stock_quantity, image_url, category_id, brand_id, color_id) VALUES
('MacBook Pro 16" M3', 'Apple MacBook Pro with M3 chip, 16GB RAM, 512GB SSD. Stunning Liquid Retina XDR display.', 2499.99, 45, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&h=400&fit=crop', 1, 1, 1),
('iPhone 15 Pro Max', 'Titanium design, A17 Pro chip, 48MP camera system with 5x optical zoom.', 1199.99, 120, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400&h=400&fit=crop', 2, 1, 5),
('Sony WH-1000XM5', 'Industry-leading noise cancellation with exceptional sound quality and 30-hour battery.', 349.99, 78, 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400&h=400&fit=crop', 3, 3, 2),
('Samsung Galaxy S24 Ultra', 'Galaxy AI features, 200MP camera, S Pen included, titanium frame.', 1299.99, 8, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&h=400&fit=crop', 2, 2, 5),
('Dell XPS 15 OLED', '15.6" 3.5K OLED display, Intel Core i7, 16GB RAM, NVIDIA RTX 4050.', 1899.99, 32, 'https://images.unsplash.com/photo-1593642632823-8f785ba67dcc?w=400&h=400&fit=crop', 1, 4, 1),
('iPad Pro 12.9"', 'M2 chip, Liquid Retina XDR display, supports Apple Pencil and Magic Keyboard.', 1099.99, 55, 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&h=400&fit=crop', 4, 1, 3);
