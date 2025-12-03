IF OBJECT_ID('dbo.trg_UserSubscription_OnlyOneActive', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_UserSubscription_OnlyOneActive;
GO

CREATE TRIGGER dbo.trg_UserSubscription_OnlyOneActive
ON dbo.User_Subscription
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Потребителите, за които в inserted има активен абонамент
    ;WITH ActiveUsers AS (
        SELECT DISTINCT UserId
        FROM inserted
        WHERE IsActive = 1
    )
    -- За тези потребители деактивираме всички други абонаменти
    UPDATE us
    SET IsActive = 0
    FROM User_Subscription us
    JOIN ActiveUsers au
        ON us.UserId = au.UserId
    WHERE us.UserSubscriptionId NOT IN (
        SELECT UserSubscriptionId
        FROM inserted
        WHERE IsActive = 1
    );
END;
GO

-- Пример: правим нов активен абонамент за UserId = 1
INSERT INTO User_Subscription (UserId, PlanId, StartDate, EndDate, IsActive, PaymentMethod, AutoRenew)
VALUES (1, 1, GETDATE(), NULL, 1, 'Card', 1);

-- Проверка: за UserId = 1 трябва да има само един ред с IsActive = 1
SELECT *
FROM User_Subscription
WHERE UserId = 1;
GO

SELECT 
    UserId,
    COUNT(*) AS TotalSubscriptions,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS ActiveSubscriptions
FROM User_Subscription
GROUP BY UserId;
