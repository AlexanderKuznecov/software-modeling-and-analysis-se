USE SpotifyDB;
GO

------------------------------------------------
-- 1. Всички таблици в базата
------------------------------------------------
SELECT name AS TableName
FROM sys.tables
ORDER BY name;
GO

------------------------------------------------
-- 2. Брой редове във всяка таблица
------------------------------------------------
SELECT COUNT(*) AS UserCount             FROM [User];
SELECT COUNT(*) AS SubscriptionPlanCount FROM Subscription_Plan;
SELECT COUNT(*) AS UserSubscriptionCount FROM User_Subscription;
SELECT COUNT(*) AS ArtistCount           FROM Artist;
SELECT COUNT(*) AS AlbumCount            FROM Album;
SELECT COUNT(*) AS TrackCount            FROM Track;
SELECT COUNT(*) AS PlaylistCount         FROM Playlist;
SELECT COUNT(*) AS PlaylistTrackCount    FROM Playlist_Track;
SELECT COUNT(*) AS ListeningHistoryCount FROM Listening_History;
GO

------------------------------------------------
-- 3. Всички потребители
------------------------------------------------
SELECT
    UserId,
    DisplayName,
    Email,
    Country,
    BirthDate,
    IsPremium,
    Status,
    CreatedAt
FROM [User]
ORDER BY UserId;
GO

------------------------------------------------
-- 4. Абонаментни планове + колко активни абонамента имат
------------------------------------------------
SELECT
    sp.PlanId,
    sp.PlanName,
    sp.MonthlyPrice,
    sp.MaxDevices,
    sp.IsStudentPlan,
    COUNT(us.UserSubscriptionId) AS ActiveSubscriptions
FROM Subscription_Plan sp
LEFT JOIN User_Subscription us
       ON us.PlanId = sp.PlanId
      AND us.IsActive = 1
GROUP BY
    sp.PlanId,
    sp.PlanName,
    sp.MonthlyPrice,
    sp.MaxDevices,
    sp.IsStudentPlan
ORDER BY sp.PlanId;
GO

------------------------------------------------
-- 5. Активни абонаменти по потребители
------------------------------------------------
SELECT
    u.UserId,
    u.DisplayName,
    sp.PlanName,
    us.StartDate,
    us.EndDate,
    us.IsActive,
    us.PaymentMethod,
    us.AutoRenew
FROM User_Subscription us
JOIN [User] u          ON us.UserId = u.UserId
JOIN Subscription_Plan sp ON us.PlanId = sp.PlanId
ORDER BY u.UserId, us.StartDate DESC;
GO

------------------------------------------------
-- 6. Плейлисти и техните собственици
------------------------------------------------
SELECT
    p.PlaylistId,
    p.Name           AS PlaylistName,
    p.Description,
    p.IsPublic,
    p.CreatedAt,
    p.UpdatedAt,
    p.FollowersCount,
    u.UserId         AS OwnerUserId,
    u.DisplayName    AS OwnerName
FROM Playlist p
JOIN [User] u ON p.OwnerUserId = u.UserId
ORDER BY p.PlaylistId;
GO

------------------------------------------------
-- 7. Съдържание на плейлистите (Playlist -> Tracks)
------------------------------------------------
SELECT
    p.PlaylistId,
    p.Name          AS PlaylistName,
    pt.Position,
    t.TrackId,
    t.Title         AS TrackTitle,
    a.Title         AS AlbumTitle,
    ar.Name         AS ArtistName,
    u.DisplayName   AS AddedBy,
    pt.AddedAt
FROM Playlist_Track pt
JOIN Playlist p ON pt.PlaylistId   = p.PlaylistId
JOIN Track   t  ON pt.TrackId      = t.TrackId
JOIN Album   a  ON t.AlbumId       = a.AlbumId
JOIN Artist  ar ON a.ArtistId      = ar.ArtistId
JOIN [User]  u  ON pt.AddedByUserId = u.UserId
ORDER BY p.PlaylistId, pt.Position;
GO

------------------------------------------------
-- 8. Всички тракове с албум и артист
------------------------------------------------
SELECT
    t.TrackId,
    t.Title        AS TrackTitle,
    t.DurationSec,
    t.ExplicitContent,
    t.PopularityScore,
    a.AlbumId,
    a.Title        AS AlbumTitle,
    ar.ArtistId,
    ar.Name        AS ArtistName
FROM Track t
JOIN Album a  ON t.AlbumId  = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
ORDER BY ar.Name, a.Title, t.TrackNumber;
GO

------------------------------------------------
-- 9. История на слушане (Listening_History) с детайли
------------------------------------------------
SELECT
    lh.ListenId,
    lh.PlayedAt,
    lh.DeviceType,
    lh.AppVersion,
    lh.SourceType,
    lh.Skipped,
    u.UserId,
    u.DisplayName  AS Listener,
    t.TrackId,
    t.Title        AS TrackTitle,
    a.Title        AS AlbumTitle,
    ar.Name        AS ArtistName
FROM Listening_History lh
JOIN [User] u  ON lh.UserId  = u.UserId
JOIN Track t   ON lh.TrackId = t.TrackId
JOIN Album a   ON t.AlbumId  = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
ORDER BY lh.PlayedAt DESC;
GO

------------------------------------------------
-- 10. Топ тракове по брой прослушвания
------------------------------------------------
SELECT
    t.TrackId,
    t.Title          AS TrackTitle,
    ar.Name          AS ArtistName,
    COUNT(*)         AS PlayCount
FROM Listening_History lh
JOIN Track  t  ON lh.TrackId = t.TrackId
JOIN Album  a  ON t.AlbumId  = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
GROUP BY t.TrackId, t.Title, ar.Name
ORDER BY PlayCount DESC, t.TrackId;
GO

------------------------------------------------
-- 11. Топ артисти по брой различни слушатели
------------------------------------------------
SELECT
    ar.ArtistId,
    ar.Name          AS ArtistName,
    COUNT(DISTINCT lh.UserId) AS UniqueListeners
FROM Listening_History lh
JOIN Track  t  ON lh.TrackId = t.TrackId
JOIN Album  a  ON t.AlbumId  = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY UniqueListeners DESC;
GO

------------------------------------------------
-- 12. Плейлисти – брой тракове и брой различни слушатели
-- (по историята на слушане)
------------------------------------------------
SELECT
    p.PlaylistId,
    p.Name              AS PlaylistName,
    COUNT(DISTINCT pt.TrackId) AS TrackCount,
    COUNT(DISTINCT lh.UserId)  AS UniqueListeners
FROM Playlist p
LEFT JOIN Playlist_Track pt
       ON p.PlaylistId = pt.PlaylistId
LEFT JOIN Listening_History lh
       ON lh.TrackId = pt.TrackId
GROUP BY p.PlaylistId, p.Name
ORDER BY UniqueListeners DESC, TrackCount DESC;
GO
