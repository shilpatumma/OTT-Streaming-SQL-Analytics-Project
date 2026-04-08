CREATE DATABASE ott_streaming_analytics;
USE ott_streaming_analytics;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    monthly_price DECIMAL(10,2),
    max_devices INT
);

CREATE TABLE content (
    content_id INT PRIMARY KEY,
    title VARCHAR(150),
    genre VARCHAR(50),
    release_year INT,
    duration_mins INT,
    language VARCHAR(30),
    content_type VARCHAR(20)
);

CREATE TABLE devices (
    device_id INT PRIMARY KEY,
    device_type VARCHAR(30),
    os VARCHAR(30),
    app_version VARCHAR(20)
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    user_id INT,
    plan_id INT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20),
    auto_renew VARCHAR(10),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE TABLE watch_history (
    watch_id INT PRIMARY KEY,
    user_id INT,
    content_id INT,
    watch_date DATE,
    watch_duration_mins INT,
    completion_pct DECIMAL(5,2),
    device_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (content_id) REFERENCES content(content_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

CREATE TABLE ratings (
    rating_id INT PRIMARY KEY,
    user_id INT,
    content_id INT,
    rating DECIMAL(2,1),
    review_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (content_id) REFERENCES content(content_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    user_id INT,
    subscription_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);

SELECT * FROM users;

SELECT * FROM users LIMIT 10;

SELECT DISTINCT city from users;

SELECT * FROM users WHERE city = 'Surat';

SELECT * FROM users WHERE age between 20 AND 30;

SELECT * FROM users WHERE city IN ('Surat', 'Mumbai', 'Bangalore');

SELECT * FROM users WHERE Full_name LIKE 'A%';

SELECT * FROM users ORDER BY signup_date desc;

SELECT * FROM users ORDER BY age desc;



SELECT count(*) AS total_users FROM users;

SELECT avg(age) AS avg_age FROM users;

SELECT min(age) AS youngest, max(age) as oldest FROM users;

SELECT sum(amount) as total_revenue FROM payments WHERE payment_status = 'Success';

SELECT avg(amount) as avg_payment FROM payments WHERE payment_status = 'Success';


SELECT city, COUNT(*) AS total_users
FROM users
GROUP BY city
ORDER BY total_users DESC;

SELECT gender, COUNT(*) AS total_users
FROM users
GROUP BY gender;

SELECT city, AVG(age) AS avg_age
FROM users
GROUP BY city
ORDER BY avg_age DESC;

SELECT status, count(*) as total_subscriptions 
FROM subscriptions
GROUP BY status;

SELECT payment_method, sum(amount) as total_revenue
FROM payments
WHERE payment_status = 'Success'
GROUP BY payment_method
ORDER BY total_revenue DESC;

SELECT city, COUNT(*) AS total_users
FROM users
GROUP BY city
HAVING total_users > 10;


SELECT user_id, full_name, age, 
	CASE 
		WHEN age < 22 THEN '18-21'
		WHEN age BETWEEN 22 AND 30 THEN '22-30'
		WHEN age BETWEEN 31 AND 40 THEN '31-40'
		ELSE '40+' 
	END AS age_group
FROM users;

SELECT title, duration_mins,
	CASE 
		WHEN duration_mins < 45 THEN 'Short'
        WHEN duration_mins BETWEEN 45 AND 100 THEN 'Medium'
        ELSE 'Long'
	END AS duration_bucket
FROM content;

SELECT payment_id, payment_status,
	CASE 
		WHEN payment_status = 'Success' THEN 'Revenue counted'
		ELSE 'Not counted'
	END AS revenue_flag
FROM payments;


SELECT
    u.user_id,
    u.full_name,
    p.plan_name,
    p.monthly_price,
    s.status
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
JOIN plans p ON s.plan_id = p.plan_id;

SELECT
    w.watch_id,
    u.full_name,
    c.title,
    c.genre,
    w.watch_date,
    w.watch_duration_mins,
    w.completion_pct
FROM watch_history w
JOIN users u ON w.user_id = u.user_id
JOIN content c ON w.content_id = c.content_id;

SELECT
    r.rating_id,
    u.full_name,
    c.title,
    c.genre,
    r.rating,
    r.review_date
FROM ratings r
JOIN users u ON r.user_id = u.user_id
JOIN content c ON r.content_id = c.content_id;

SELECT
    pay.payment_id,
    u.full_name,
    p.plan_name,
    pay.amount,
    pay.payment_method,
    pay.payment_status,
    pay.payment_date
FROM payments pay
JOIN users u ON pay.user_id = u.user_id
JOIN subscriptions s ON pay.subscription_id = s.subscription_id
JOIN plans p ON s.plan_id = p.plan_id;


SELECT
    u.user_id,
    u.full_name
FROM users u
LEFT JOIN ratings r ON u.user_id = r.user_id
WHERE r.user_id IS NULL;

SELECT
    u.user_id,
    u.full_name
FROM users u
LEFT JOIN watch_history w ON u.user_id = w.user_id
WHERE w.user_id IS NULL;

SELECT
    c.content_id,
    c.title
FROM content c
LEFT JOIN ratings r ON c.content_id = r.content_id
WHERE r.content_id IS NULL;


SELECT *
FROM payments
WHERE amount > (
    SELECT AVG(amount)
    FROM payments
    WHERE payment_status = 'Success'
);

SELECT c.title
FROM content c
JOIN (
    SELECT content_id, AVG(rating) AS avg_rating
    FROM ratings
    GROUP BY content_id
) x ON c.content_id = x.content_id
WHERE x.avg_rating > (
    SELECT AVG(rating) FROM ratings
);

SELECT
    user_id,
    SUM(watch_duration_mins) AS total_watch_time
FROM watch_history
GROUP BY user_id
HAVING SUM(watch_duration_mins) > (
    SELECT AVG(user_watch_time)
    FROM (
        SELECT SUM(watch_duration_mins) AS user_watch_time
        FROM watch_history
        GROUP BY user_id
    ) t
);

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM payments
    WHERE payment_status = 'Success'
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT *
FROM monthly_revenue
ORDER BY month;

WITH genre_views AS (
    SELECT
        c.genre,
        COUNT(*) AS total_views
    FROM watch_history w
    JOIN content c ON w.content_id = c.content_id
    GROUP BY c.genre
)
SELECT *
FROM genre_views
ORDER BY total_views DESC;

WITH user_engagement AS (
    SELECT
        user_id,
        COUNT(*) AS total_sessions,
        SUM(watch_duration_mins) AS total_watch_minutes,
        AVG(completion_pct) AS avg_completion
    FROM watch_history
    GROUP BY user_id
)
SELECT *
FROM user_engagement
ORDER BY total_watch_minutes DESC;


SELECT
    c.title,
    AVG(r.rating) AS avg_rating,
    RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rating_rank
FROM ratings r
JOIN content c ON r.content_id = c.content_id
GROUP BY c.content_id, c.title;

WITH ranked_content AS (
    SELECT
        c.genre,
        c.title,
        AVG(r.rating) AS avg_rating,
        ROW_NUMBER() OVER (
            PARTITION BY c.genre
            ORDER BY AVG(r.rating) DESC
        ) AS rn
    FROM ratings r
    JOIN content c ON r.content_id = c.content_id
    GROUP BY c.genre, c.title
)
SELECT *
FROM ranked_content
WHERE rn <= 3;

SELECT
    payment_date,
    amount,
    SUM(amount) OVER (ORDER BY payment_date) AS running_total_revenue
FROM payments
WHERE payment_status = 'Success';

SELECT
    user_id,
    payment_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY user_id
        ORDER BY payment_date
    ) AS previous_payment
FROM payments
WHERE payment_status = 'Success';

SELECT
    user_id,
    payment_date,
    amount,
    LEAD(amount) OVER (
        PARTITION BY user_id
        ORDER BY payment_date
    ) AS next_payment
FROM payments
WHERE payment_status = 'Success';


SELECT
    DATE_FORMAT(signup_date, '%Y-%m') AS signup_month,
    COUNT(*) AS total_signups
FROM users
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY signup_month;

SELECT
    DATE_FORMAT(watch_date, '%Y-%m') AS watch_month,
    COUNT(*) AS total_sessions
FROM watch_history
GROUP BY DATE_FORMAT(watch_date, '%Y-%m')
ORDER BY watch_month;

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS pay_month,
    COUNT(DISTINCT user_id) AS active_payers
FROM payments
WHERE payment_status = 'Success'
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY pay_month;


SELECT
    u.user_id,
    u.full_name,
    COUNT(w.watch_id) AS total_sessions,
    SUM(w.watch_duration_mins) AS total_watch_minutes
FROM users u
JOIN watch_history w ON u.user_id = w.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_watch_minutes DESC
LIMIT 10;

SELECT
    c.title,
    COUNT(w.watch_id) AS total_views
FROM content c
JOIN watch_history w ON c.content_id = w.content_id
GROUP BY c.title
ORDER BY total_views DESC
LIMIT 10;

SELECT
    c.title,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.rating_id) AS total_ratings
FROM content c
JOIN ratings r ON c.content_id = r.content_id
GROUP BY c.content_id, c.title
HAVING COUNT(r.rating_id) >= 2
ORDER BY avg_rating DESC, total_ratings DESC
LIMIT 10;

SELECT
    p.plan_name,
    SUM(pay.amount) AS total_revenue
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.subscription_id
JOIN plans p ON s.plan_id = p.plan_id
WHERE pay.payment_status = 'Success'
GROUP BY p.plan_name
ORDER BY total_revenue DESC;

SELECT
    d.device_type,
    COUNT(*) AS total_sessions
FROM watch_history w
JOIN devices d ON w.device_id = d.device_id
GROUP BY d.device_type
ORDER BY total_sessions DESC;

SELECT
    c.genre,
    SUM(w.watch_duration_mins) AS total_watch_minutes
FROM watch_history w
JOIN content c ON w.content_id = c.content_id
GROUP BY c.genre
ORDER BY total_watch_minutes DESC;




CREATE VIEW user_watch_summary AS
SELECT
    u.user_id,
    u.full_name,
    COUNT(w.watch_id) AS total_sessions,
    COALESCE(SUM(w.watch_duration_mins), 0) AS total_watch_minutes,
    ROUND(COALESCE(AVG(w.completion_pct), 0), 2) AS avg_completion
FROM users u
LEFT JOIN watch_history w ON u.user_id = w.user_id
GROUP BY u.user_id, u.full_name;

SELECT * FROM user_watch_summary
ORDER BY total_watch_minutes DESC;



CREATE INDEX idx_watch_user ON watch_history(user_id);
CREATE INDEX idx_watch_content ON watch_history(content_id);
CREATE INDEX idx_payment_date ON payments(payment_date);
CREATE INDEX idx_sub_status ON subscriptions(status);



DELIMITER $$

CREATE PROCEDURE GetUserWatchStats(IN p_user_id INT)
BEGIN
    SELECT
        u.full_name,
        COUNT(w.watch_id) AS total_sessions,
        COALESCE(SUM(w.watch_duration_mins), 0) AS total_watch_minutes,
        ROUND(COALESCE(AVG(w.completion_pct), 0), 2) AS avg_completion
    FROM users u
    LEFT JOIN watch_history w ON u.user_id = w.user_id
    WHERE u.user_id = p_user_id
    GROUP BY u.full_name;
END $$

DELIMITER ;

CALL GetUserWatchStats(1);
