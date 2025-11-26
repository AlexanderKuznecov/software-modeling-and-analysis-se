USE SpotifyDB;
GO

IF OBJECT_ID('dbo.fn_GetTrackPlayCount', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetTrackPlayCount;
GO

CREATE FUNCTION dbo.fn_GetTrackPlayCount
(
    @TrackId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @PlayCount INT;

    SELECT @PlayCount = COUNT(*)
    FROM Listening_History
    WHERE TrackId = @TrackId;

    RETURN ISNULL(@PlayCount, 0);
END;
GO

SELECT TrackId, Title,
       dbo.fn_GetTrackPlayCount(TrackId) AS PlayCount
FROM Track;
GO

