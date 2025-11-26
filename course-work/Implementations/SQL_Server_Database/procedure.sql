IF OBJECT_ID('dbo.sp_GetPlaylistSummary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetPlaylistSummary;
GO

CREATE PROCEDURE dbo.sp_GetPlaylistSummary
    @PlaylistId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PlaylistId,
        p.Name           AS PlaylistName,
        p.Description,
        p.IsPublic,
        p.CreatedAt,
        p.UpdatedAt,
        p.FollowersCount,
        u.DisplayName    AS OwnerName,
        COUNT(DISTINCT pt.TrackId)                  AS TrackCount,
        ISNULL(SUM(t.DurationSec), 0)              AS TotalDurationSec
    FROM Playlist p
    JOIN [User] u
        ON p.OwnerUserId = u.UserId
    LEFT JOIN Playlist_Track pt
        ON p.PlaylistId = pt.PlaylistId
    LEFT JOIN Track t
        ON pt.TrackId = t.TrackId
    WHERE p.PlaylistId = @PlaylistId
    GROUP BY
        p.PlaylistId, p.Name, p.Description,
        p.IsPublic, p.CreatedAt, p.UpdatedAt,
        p.FollowersCount, u.DisplayName;
END;
GO

EXEC dbo.sp_GetPlaylistSummary @PlaylistId = 1;
GO
