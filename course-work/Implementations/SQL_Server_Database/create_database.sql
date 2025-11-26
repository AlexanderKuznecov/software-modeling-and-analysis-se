CREATE DATABASE SpotifyDB;
GO
USE SpotifyDB;
GO

CREATE TABLE [User] (
    UserId         INT IDENTITY(1,1)    NOT NULL,
    Email          NVARCHAR(255)       NOT NULL,
    PasswordHash   NVARCHAR(255)       NOT NULL,
    DisplayName    NVARCHAR(100)       NOT NULL,
    Country        NVARCHAR(50)        NULL,
    BirthDate      DATE                NULL,
    Gender         CHAR(1)             NULL
        CHECK (Gender IN ('M','F')),
    CreatedAt      DATETIME2           NOT NULL DEFAULT SYSUTCDATETIME(),
    IsPremium      BIT                 NOT NULL DEFAULT 0,
    Status         NVARCHAR(20)        NOT NULL DEFAULT 'Active'
        CHECK (Status IN ('Active','Blocked','Deleted')),
    CONSTRAINT PK_User PRIMARY KEY (UserId),
    CONSTRAINT UQ_User_Email UNIQUE (Email)
);
GO

CREATE TABLE Subscription_Plan (
    PlanId              INT IDENTITY(1,1) NOT NULL,
    PlanName            NVARCHAR(100)     NOT NULL,
    MonthlyPrice        DECIMAL(10,2)     NOT NULL CHECK (MonthlyPrice >= 0),
    MaxDevices          INT               NOT NULL CHECK (MaxDevices > 0),
    MaxOfflineDownloads INT               NOT NULL CHECK (MaxOfflineDownloads >= 0),
    IsStudentPlan       BIT               NOT NULL DEFAULT 0,
    CONSTRAINT PK_Subscription_Plan PRIMARY KEY (PlanId)
);
GO

CREATE TABLE Artist (
    ArtistId        INT IDENTITY(1,1) NOT NULL,
    Name            NVARCHAR(150)     NOT NULL,
    Country         NVARCHAR(50)      NULL,
    DebutYear       SMALLINT          NULL,
    MonthlyListeners INT              NULL,
    FollowersCount   INT              NULL,
    CONSTRAINT PK_Artist PRIMARY KEY (ArtistId)
);
GO

CREATE TABLE Album (
    AlbumId     INT IDENTITY(1,1) NOT NULL,
    ArtistId    INT               NOT NULL,
    Title       NVARCHAR(200)     NOT NULL,
    ReleaseDate DATE              NULL,
    AlbumType   NVARCHAR(50)      NULL,
    TotalTracks INT               NULL CHECK (TotalTracks IS NULL OR TotalTracks >= 0),
    Label       NVARCHAR(100)     NULL,
    CONSTRAINT PK_Album PRIMARY KEY (AlbumId),
    CONSTRAINT FK_Album_Artist
        FOREIGN KEY (ArtistId) REFERENCES Artist(ArtistId)
);
GO

CREATE TABLE Track (
    TrackId         INT IDENTITY(1,1) NOT NULL,
    AlbumId         INT               NOT NULL,
    Title           NVARCHAR(200)     NOT NULL,
    DurationSec     INT               NOT NULL CHECK (DurationSec > 0),
    ExplicitContent BIT               NOT NULL DEFAULT 0,
    PopularityScore INT               NULL CHECK (PopularityScore BETWEEN 0 AND 100),
    DiscNumber      INT               NULL CHECK (DiscNumber IS NULL OR DiscNumber >= 1),
    TrackNumber     INT               NULL CHECK (TrackNumber IS NULL OR TrackNumber >= 1),
    ISRCCode        CHAR(12)          NULL,
    Language        NVARCHAR(30)      NULL,
    CONSTRAINT PK_Track PRIMARY KEY (TrackId),
    CONSTRAINT FK_Track_Album
        FOREIGN KEY (AlbumId) REFERENCES Album(AlbumId)
);
GO

CREATE TABLE Playlist (
    PlaylistId     INT IDENTITY(1,1) NOT NULL,
    OwnerUserId    INT               NOT NULL,
    Name           NVARCHAR(150)     NOT NULL,
    Description    NVARCHAR(500)     NULL,
    IsPublic       BIT               NOT NULL DEFAULT 1,
    CreatedAt      DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt      DATETIME2         NULL,
    FollowersCount INT               NOT NULL DEFAULT 0,
    CONSTRAINT PK_Playlist PRIMARY KEY (PlaylistId),
    CONSTRAINT FK_Playlist_Owner_User
        FOREIGN KEY (OwnerUserId) REFERENCES [User](UserId)
);
GO

CREATE TABLE User_Subscription (
    UserSubscriptionId INT IDENTITY(1,1) NOT NULL,
    UserId             INT               NOT NULL,
    PlanId             INT               NOT NULL,
    StartDate          DATE              NOT NULL,
    EndDate            DATE              NULL,
    IsActive           BIT               NOT NULL DEFAULT 1,
    PaymentMethod      NVARCHAR(50)      NULL,
    AutoRenew          BIT               NOT NULL DEFAULT 1,
    CONSTRAINT PK_User_Subscription PRIMARY KEY (UserSubscriptionId),
    CONSTRAINT FK_User_Subscription_User
        FOREIGN KEY (UserId) REFERENCES [User](UserId),
    CONSTRAINT FK_User_Subscription_Plan
        FOREIGN KEY (PlanId) REFERENCES Subscription_Plan(PlanId)
);
GO

CREATE TABLE Playlist_Track (
    PlaylistTrackId INT IDENTITY(1,1) NOT NULL,
    PlaylistId      INT               NOT NULL,
    TrackId         INT               NOT NULL,
    AddedByUserId   INT               NOT NULL,
    AddedAt         DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    Position        INT               NULL CHECK (Position IS NULL OR Position >= 1),
    CONSTRAINT PK_Playlist_Track PRIMARY KEY (PlaylistTrackId),
    CONSTRAINT FK_Playlist_Track_Playlist
        FOREIGN KEY (PlaylistId) REFERENCES Playlist(PlaylistId)
        ON DELETE CASCADE,
    CONSTRAINT FK_Playlist_Track_Track
        FOREIGN KEY (TrackId) REFERENCES Track(TrackId)
        ON DELETE CASCADE,
    CONSTRAINT FK_Playlist_Track_User
        FOREIGN KEY (AddedByUserId) REFERENCES [User](UserId),
    -- за да няма една и съща песен два пъти в един плейлист:
    CONSTRAINT UQ_Playlist_Track UNIQUE (PlaylistId, TrackId)
);
GO

CREATE TABLE Listening_History (
    ListenId   BIGINT IDENTITY(1,1) NOT NULL,
    UserId     INT                  NOT NULL,
    TrackId    INT                  NOT NULL,
    PlayedAt   DATETIME2            NOT NULL,
    DeviceType NVARCHAR(50)         NULL,
    AppVersion NVARCHAR(20)         NULL,
    SourceType NVARCHAR(50)         NULL,
    Skipped    BIT                  NOT NULL DEFAULT 0,
    CONSTRAINT PK_Listening_History PRIMARY KEY (ListenId),
    CONSTRAINT FK_Listening_User
        FOREIGN KEY (UserId) REFERENCES [User](UserId),
    CONSTRAINT FK_Listening_Track
        FOREIGN KEY (TrackId) REFERENCES Track(TrackId)
);
GO

CREATE INDEX IX_Listening_User_PlayedAt
    ON Listening_History(UserId, PlayedAt);

CREATE INDEX IX_Listening_Track_PlayedAt
    ON Listening_History(TrackId, PlayedAt);

	CREATE INDEX IX_PlaylistTrack_Playlist_Position
    ON Playlist_Track(PlaylistId, Position);
