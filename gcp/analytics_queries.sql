-- Most popular events
SELECT event_name,
       COUNTIF(action='register') AS registrations,
       COUNTIF(action='view') AS views
FROM `PROJECT_ID.unievnet_analytics.user_activity`
GROUP BY event_name ORDER BY registrations DESC;

-- Activity by region
SELECT region, COUNT(*) AS total_actions
FROM `PROJECT_ID.unievnet_analytics.user_activity`
GROUP BY region ORDER BY total_actions DESC;

-- Device breakdown
SELECT device, COUNT(*) AS actions
FROM `PROJECT_ID.unievnet_analytics.user_activity`
GROUP BY device ORDER BY actions DESC;
