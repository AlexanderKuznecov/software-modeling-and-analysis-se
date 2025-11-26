USE SpotifyDB;
GO

------------------------------------------------
-- 0. Изчистване (по желание – ако тестваш наново)
------------------------------------------------
-- ВНИМАНИЕ: Това трие всички данни!
DELETE FROM Listening_History;
DELETE FROM Playlist_Track;
DELETE FROM User_Subscription;
DELETE FROM Playlist;
DELETE FROM Track;
DELETE FROM Album;
DELETE FROM Artist;
DELETE FROM Subscription_Plan;
DELETE FROM [User];
-- GO

------------------------------------------------
-- 1. Потребители
------------------------------------------------
INSERT INTO [User] (Email, PasswordHash, DisplayName, Country, BirthDate, Gender, IsPremium, Status)
VALUES
('alice@example.com', 'hash1', 'Alice',   'BG', '1999-05-10', 'F', 1, 'Active'),
('bob@example.com',   'hash2', 'Bob',     'BG', '1998-11-20', 'M', 0, 'Active'),
('carol@example.com', 'hash3', 'Carol',   'DE', '2000-03-15', 'F', 1, 'Active'),
('dave@example.com',  'hash4', 'Dave',    'US', '1995-01-01', 'M', 0, 'Active'),
('eva@example.com',   'hash5', 'Eva',     'FR', '2001-07-07', 'F', 0, 'Blocked');
GO

------------------------------------------------
-- 2. Абонаментни планове
------------------------------------------------
INSERT INTO Subscription_Plan (PlanName, MonthlyPrice, MaxDevices, MaxOfflineDownloads, IsStudentPlan)
VALUES
('Free',          0.00, 1,   0,   0),
('Premium',      11.99, 3, 1000,  0),
('Premium Student', 5.99, 2, 500, 1);
GO

------------------------------------------------
-- 3. Артисти
------------------------------------------------
INSERT INTO Artist (Name, Country, DebutYear, MonthlyListeners, FollowersCount)
VALUES
('Imagine Dragons', 'US', 2008, 45000000, 12000000),
('Dua Lipa',        'UK', 2015, 38000000,  9000000),
('Grafa',           'BG', 1999,  500000,   200000);
GO

------------------------------------------------
-- 4. Албуми
------------------------------------------------
-- Предполага се, че ArtistId са 1,2,3
INSERT INTO Album (ArtistId, Title, ReleaseDate, AlbumType, TotalTracks, Label)
VALUES
(1, 'Night Visions',     '2012-09-04', 'Album', 13, 'Interscope'),
(1, 'Evolve',            '2017-06-23', 'Album', 12, 'Interscope'),
(2, 'Future Nostalgia',  '2020-03-27', 'Album', 11, 'Warner'),
(3, 'Spomeni ot rana',    '2006-01-15', 'Album', 10, 'Virginia Records');
GO

------------------------------------------------
-- 5. Тракове
------------------------------------------------
-- Приемаме че AlbumId са 1..4
INSERT INTO Track (AlbumId, Title, DurationSec, ExplicitContent, PopularityScore,
                   DiscNumber, TrackNumber, ISRCCode, Language)
VALUES
(1, 'Radioactive',      186, 0, 95, 1, 1, 'USUM71201063', 'EN'),
(1, 'Demons',           177, 0, 92, 1, 4, 'USUM71301384', 'EN'),
(2, 'Believer',         204, 0, 97, 1, 1, 'USUM71700426', 'EN'),
(2, 'Thunder',          187, 0, 93, 1, 4, 'USUM71703875', 'EN'),
(3, 'Don''t Start Now', 183, 0, 96, 1, 1, 'GBAHT1901164', 'EN'),
(3, 'Physical',         193, 0, 90, 1, 2, 'GBAHT1901263', 'EN'),
(4, 'Nevidim',          215, 0, 75, 1, 1, NULL, 'BG'),
(4, 'Momenti',          230, 0, 70, 1, 2, NULL, 'BG');
GO

------------------------------------------------
-- 6. Плейлисти
------------------------------------------------
-- OwnerUserId: 1=Alice, 2=Bob, 3=Carol...
INSERT INTO Playlist (OwnerUserId, Name, Description, IsPublic, FollowersCount)
VALUES
(1, 'Gym Bangers',   'Energy music for training', 1, 120),
(2, 'Chill Evening', 'Chill beats for night time',   1, 45),
(3, 'Bulgarian Mix', 'BG music',                     0, 5);
GO

------------------------------------------------
-- 7. Абонаменти на потребители
------------------------------------------------
-- UserId 1 и 3 са Premium, 2 е Free, 4 е бил Premium, 5 няма
INSERT INTO User_Subscription (UserId, PlanId, StartDate, EndDate, IsActive, PaymentMethod, AutoRenew)
VALUES
(1, 2, '2024-01-01', NULL, 1, 'Card', 1),
(2, 1, '2024-05-01', NULL, 1, 'None', 0),
(3, 3, '2024-02-15', NULL, 1, 'Card', 1),
(4, 2, '2023-01-01', '2023-12-31', 0, 'Card', 0);
GO

------------------------------------------------
-- 8. Връзка Playlist_Track (много към много)
------------------------------------------------
-- Приемаме че TrackId са 1..8, PlaylistId са 1..3
INSERT INTO Playlist_Track (PlaylistId, TrackId, AddedByUserId, AddedAt, Position)
VALUES
(1, 3, 1, DATEADD(DAY,-10, SYSUTCDATETIME()), 1), -- Believer
(1, 1, 1, DATEADD(DAY,-9,  SYSUTCDATETIME()), 2), -- Radioactive
(1, 5, 2, DATEADD(DAY,-8,  SYSUTCDATETIME()), 3), -- Don't Start Now

(2, 2, 2, DATEADD(DAY,-7,  SYSUTCDATETIME()), 1), -- Demons
(2, 4, 2, DATEADD(DAY,-6,  SYSUTCDATETIME()), 2), -- Thunder
(2, 6, 3, DATEADD(DAY,-5,  SYSUTCDATETIME()), 3), -- Physical

(3, 7, 3, DATEADD(DAY,-4,  SYSUTCDATETIME()), 1), -- Nevidim
(3, 8, 3, DATEADD(DAY,-3,  SYSUTCDATETIME()), 2), -- Momenti
(3, 3, 3, DATEADD(DAY,-2,  SYSUTCDATETIME()), 3); -- Believer (смесен плейлист)
GO

------------------------------------------------
-- 9. Listening_History
------------------------------------------------
INSERT INTO Listening_History (UserId, TrackId, PlayedAt, DeviceType, AppVersion, SourceType, Skipped)
VALUES
(1, 3, DATEADD(HOUR,-5,  SYSUTCDATETIME()), 'Mobile', '1.0.0', 'Playlist', 0),
(1, 3, DATEADD(HOUR,-4,  SYSUTCDATETIME()), 'Mobile', '1.0.0', 'Playlist', 0),
(1, 5, DATEADD(HOUR,-3,  SYSUTCDATETIME()), 'Desktop','1.1.0', 'Playlist', 0),
(2, 2, DATEADD(HOUR,-2,  SYSUTCDATETIME()), 'Mobile', '1.0.1', 'Search',   0),
(2, 4, DATEADD(HOUR,-1,  SYSUTCDATETIME()), 'Mobile', '1.0.1', 'Playlist', 1),
(3, 7, DATEADD(DAY,-1,   SYSUTCDATETIME()), 'Desktop','1.1.0', 'Playlist', 0),
(3, 8, DATEADD(DAY,-1,   SYSUTCDATETIME()), 'Desktop','1.1.0', 'Playlist', 0),
(3, 3, DATEADD(DAY,-2,   SYSUTCDATETIME()), 'Mobile', '1.0.2', 'Radio',    0),
(4, 1, DATEADD(DAY,-3,   SYSUTCDATETIME()), 'Mobile', '1.0.0', 'Search',   1),
(4, 3, DATEADD(DAY,-3,   SYSUTCDATETIME()), 'Mobile', '1.0.0', 'Search',   0);
GO
