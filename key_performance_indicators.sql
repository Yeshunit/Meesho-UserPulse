-- Meesho SQL Project: Key Performance Indicators (KPIs)

-- 1. Calculating Voice Search Adoption Rate
WITH SearchMethodUsage AS (
    SELECT 
        search_method,
        COUNT(*) AS method_count
    FROM 
        SearchInteractions
    WHERE 
        search_date >= DATE_SUB(NOW(), INTERVAL 1 DAY)
    GROUP BY 
        search_method
)
SELECT 
    ROUND(SUM(CASE WHEN search_method = 'voice' THEN method_count ELSE 0 END) 
    / SUM(method_count) * 100, 2) AS voice_search_adoption_rate
FROM 
    SearchMethodUsage;

-- 2. Trending Products
SELECT 
    p.product_id,
    p.product_name,
    pv.view_count
FROM 
    Products p
JOIN 
    ProductViews pv ON p.product_id = pv.product_id
WHERE 
    pv.view_count > 10  -- Arbitrary threshold
ORDER BY 
    pv.view_count DESC;

-- 3. Personalized User Feed
WITH UserRecentInteractions AS (
    SELECT 
        user_id, 
        product_id, 
        COUNT(*) AS interaction_count
    FROM 
        UserInteractions
    WHERE 
        interaction_date >= DATE_SUB(NOW(), INTERVAL 1 DAY)
    GROUP BY 
        user_id, product_id
),
TrendingProducts AS (
    SELECT 
        product_id,
        view_count
    FROM 
        ProductViews
    WHERE 
        view_count > 10
    ORDER BY 
        view_count DESC
    LIMIT 10
)
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COALESCE(ur.interaction_count, 0) AS user_interest_count,
    COALESCE(tp.view_count, 0) AS trending_score
FROM 
    Products p
LEFT JOIN 
    UserRecentInteractions ur ON p.product_id = ur.product_id
LEFT JOIN 
    TrendingProducts tp ON p.product_id = tp.product_id
ORDER BY 
    COALESCE(tp.view_count, 0) DESC, ur.interaction_count DESC;

-- 4. Identify Most Engaged Users
SELECT 
    u.user_id,
    u.username,
    COUNT(ui.interaction_id) AS total_interactions
FROM 
    Users u
JOIN 
    UserInteractions ui ON u.user_id = ui.user_id
GROUP BY 
    u.user_id, u.username
ORDER BY 
    total_interactions DESC
LIMIT 5;

-- 5. Find the Most Popular Product Category
SELECT 
    p.category,
    COUNT(ui.interaction_id) AS category_interactions
FROM 
    Products p
JOIN 
    UserInteractions ui ON p.product_id = ui.product_id
GROUP BY 
    p.category
ORDER BY 
    category_interactions DESC
LIMIT 1;

-- 6. Explore Voice vs. Text Search Trends
SELECT 
    search_method,
    COUNT(*) AS method_count
FROM 
    SearchInteractions
WHERE 
    search_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY 
    search_method;

-- 7. Total Interactions per User with Types
SELECT 
    u.user_id,
    u.username,
    COUNT(ui.interaction_id) AS total_interactions,
    GROUP_CONCAT(DISTINCT ui.interaction_type) AS interaction_types
FROM 
    Users u
LEFT JOIN 
    UserInteractions ui ON u.user_id = ui.user_id
GROUP BY 
    u.user_id, u.username
ORDER BY 
    u.user_id;

-- 8. Products with Highest View Counts
SELECT 
    p.product_id,
    p.product_name,
    pv.view_count
FROM 
    Products p
JOIN 
    ProductViews pv ON p.product_id = pv.product_id
ORDER BY 
    pv.view_count DESC
LIMIT 5;

-- 9. Notifications Sent to Each User by Type
SELECT 
    u.user_id,
    u.username,
    n.notification_type,
    COUNT(n.notification_id) AS notification_count
FROM 
    Users u
LEFT JOIN 
    Notifications n ON u.user_id = n.user_id
GROUP BY 
    u.user_id, u.username, n.notification_type
ORDER BY 
    u.user_id, n.notification_type;
