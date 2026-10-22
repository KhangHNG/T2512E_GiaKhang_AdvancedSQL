CREATE DATABASE IF NOT EXISTS EcommerceDB;
USE EcommerceDB;

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Pending', 'Completed', 'Cancelled')),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE OrderDetails(
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


INSERT INTO Categories (category_name) VALUES 
('Electronics'), ('Clothing'), ('Home & Kitchen');

INSERT INTO Products (product_name, price, category_id) VALUES 
('Laptop Dell XPS', 1500.00, 1),
('iPhone 15', 1000.00, 1),
('Wireless Mouse', 25.00, 1),
('T-Shirt Cotton', 20.00, 2),
('Jeans Slim Fit', 50.00, 2),
('Coffee Maker', 80.00, 3),
('Air Fryer', 120.00, 3);

INSERT INTO Customers (customer_name, city) VALUES 
('Nguyen Van A', 'Ha Noi'),
('Tran Thi B', 'HCM'),
('Le Van C', 'Da Nang'),
('Pham Thi D', 'Ha Noi'),
('Hoang Van E', 'HCM');

INSERT INTO Orders (customer_id, order_date, status) VALUES 
(1, '2026-09-01', 'Completed'),
(2, '2026-09-02', 'Completed'),
(3, '2026-09-03', 'Cancelled'),
(1, '2026-09-05', 'Completed'),
(4, '2026-09-10', 'Completed'),
(5, '2026-09-12', 'Pending'),
(2, '2026-09-15', 'Completed');

INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES 
(1, 1, 1, 1500.00),
(1, 3, 2, 25.00),
(2, 2, 1, 1000.00),
(2, 4, 3, 20.00),
(3, 5, 2, 50.00),
(4, 3, 5, 25.00),
(4, 6, 1, 80.00),
(5, 7, 2, 120.00),
(6, 1, 1, 1500.00),
(7, 2, 2, 1000.00),
(7, 5, 1, 50.00);

-- Câu 1: Thống kê tổng số lượng sản phẩm đang có trong từng danh mục (category_name).
SELECT c.category_name, COUNT(p.product_id) AS total_products
FROM Categories c
LEFT JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;

-- Câu 2: Tính giá bán trung bình (AVG), giá lớn nhất (MAX) và giá nhỏ nhất (MIN) của các sản phẩm thuộc từng danh mục.
SELECT c.category_name, AVG(p.price) as average_price, MAX(p.price) as max_price, MIN(p.price) as min_price
FROM Categories c
LEFT JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;

-- Câu 3: Cho biết tổng số đơn hàng đã đặt của mỗi trạng thái (status).
SELECT status, COUNT(order_id) as total_orders
FROM Orders
GROUP BY status;

-- Câu 4: Thống kê số lượng đơn hàng đã hoàn tất (status = 'Completed') của từng khách hàng. Hển thị customer_name và tổng số đơn tương ứng.
SELECT c.customer_name as name, COUNT(o.order_id) as total_orders, status
FROM Orders o
LEFT JOIN Customers c ON c.customer_id = o.customer_id
GROUP BY customer_name;

-- Câu 5: Tính tổng doanh thu thu được từ mỗi đơn hàng (chỉ tính các đơn hàng có trạng thái 'Completed'). Danh sách gồm: order_id, order_date, total_revenue.
SELECT o.order_id, o.order_date, SUM(od.quantity * od.unit_price) AS total_revenue
FROM Orders o
JOIN OrderDetails od ON o.order_id = od.order_id
WHERE o.status = 'Completed'
GROUP BY o.order_id, o.order_date;

-- Câu 6: Thống kê tổng số lượng sản phẩm (total_quantity) đã bán ra của từng mặt hàng (product_name).
SELECT p.product_name, SUM(od.quantity) AS total_quantity
FROM Products p
JOIN OrderDetails od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name;

-- Câu 7: Lọc ra danh sách các khách hàng đã chi tiêu tổng cộng trên 1,000 USD cho các đơn hàng đã hoàn tất. Hiển thị customer_name và total_spent.
SELECT cu.customer_name, SUM(od.quantity * od.unit_price) AS total_spent
FROM Customers cu
JOIN Orders o ON cu.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
WHERE o.status = 'Completed'
GROUP BY cu.customer_id, cu.customer_name
HAVING total_spent > 1000.00;

-- Câu 8: Tìm các danh mục sản phẩm (category_name) có tổng số lượng mặt hàng đã bán ra lớn hơn 3 sản phẩm.
SELECT c.category_name
FROM Categories c
JOIN Products p on c.category_id = p.category_id
GROUP BY c.category_id
HAVING COUNT(product_name) > 3

-- Câu 9: Thống kê tổng doanh thu theo từng thành phố (city). Chỉ lấy các thành phố có tổng doanh thu vượt quá 1,500 USD.
SELECT cu.city AS city, SUM(od.quantity * od.unit_price) AS total_spent
FROM Customers cu
JOIN Orders o ON cu.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
WHERE o.status = 'Completed'
GROUP BY cu.city
HAVING total_spent > 1500.00;