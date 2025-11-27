# 🎵 SpotifyDB – Аналитична база данни и Power BI отчет

**Автор:** Александър Кузнецов  
**Факултетен номер:** 2301321059  
**Курс:** 3 курс, Софтуерно инженерство  
**Дисциплина:** Software Modeling and Analysis SE  
**Университет:** ПУ „Паисий Хилендарски“

---

## 1. Описание на проекта

SpotifyDB е проект за анализ на музикални данни, базиран на релационна база данни и Power BI отчет.  
Проектът има за цел да моделира и анализира следните обекти:

- Изпълнители (Artists)
- Албуми (Albums)
- Песни (Tracks)
- Слушания (Listening activity)
- Потребители (Users)
- Популярност и класации

Проектът включва следните основни части:

- Концептуално моделиране (Chen)
- Логически модел (Crow’s Foot)
- Data Warehouse модел (DW)
- MS SQL Server база данни
- Power BI визуализации и анализ

---

## 2. Структура на проекта

Всички файлове се намират в директория:

course-work/Implementations/


### 2.1 Chen_Notation/

Концептуален модел на Spotify, изграден по Chen notation.

Файлове:
- Spotify Chen notation.drawio  
- Spotify Chen notation.png  

Основни обекти:
- Artist
- Album
- Track
- User
- Subscription_Plan
- Genre
- Playlist

Основни връзки:
- Artist → Album
- Album → Track
- User → Listens → Track

---

### 2.2 Crow's_Foot/

Логически модел на базата данни по Crow's Foot notation.

Файлове:
- Spotify Crow's foot.drawio.xml  
- Spotify Crow's foot.drawio.png  

Съдържащи се таблици:
- Artist
- Album
- Track
- User
- User_Subscription
- Subscription_Plan
- Playlist
- Playlist_Track
- Listening_History

---

### 2.3 Data_Warehouse/

Data Warehouse модел, изграден с UML Database notation.

Файлове:
- Spotify Data Warehouse.drawio.xml  
- Spotify Data Warehouse.drawio.png  

#### Измерения (Dimensions):
- DimDate
- DimUser
- DimArtist
- DimAlbum
- DimTrack
- DimGenre
- DimDevice

#### Факт таблици (Facts):
- FactListenDaily
- FactUserSubscriptionDaily
- FactPlaylistDaily

DW моделът позволява анализ по:
- време
- потребители
- изпълнители
- жанрове
- популярност на песни
- абонати по дни
- плейлисти по дни

---

### 2.4 SQL_Server_Database/

Основната папка с реалната релационна база в MS SQL Server.

Файлове:
- create_database.sql  
- schema.png  
- seed.sql  
- queries.sql  
- trigger.sql  
- procedure.sql  
- function.sql  

---

### 2.5 Power_BI/

Папка за аналитичния Power BI доклад.

Файлове:
- SpotifyDB.pbix  
- visualization.png  

Докладът използва директна връзка към базата:

SpotifyDB

---

## 3. Инсталация и стартиране на базата данни

### 3.1 Необходими инструменти

- MS SQL Server  
- SQL Server Management Studio (SSMS)  
- Power BI Desktop  
- Browser + draw.io  

---

### 3.2 Стъпки за създаване на базата

```sql
CREATE DATABASE SpotifyDB;
GO
USE SpotifyDB;
```

- Отвори create_database.sql и изпълни целия файл

- Отвори seed.sql и го изпълни

- По желание изпълни заявките от queries.sql

## 4. Power BI доклад – визуализации и SQL заявки

## 4.1 Брой слушания по изпълнители

Power BI визуализация: Column Chart

X-Axis: Artist.Name

Y-Axis: Count of Listen.ListenId

```
SELECT 
    a.Name AS ArtistName,
    COUNT(l.ListenId) AS TotalListens
FROM Artist a
JOIN Album al ON al.ArtistId = a.ArtistId
JOIN Track t ON t.AlbumId = al.AlbumId
JOIN Listen l ON l.TrackId = t.TrackId
GROUP BY a.Name;
```
---

### 4.2 Брой слушания по време

Power BI визуализация: Line Chart

X-Axis: ListenDate

Y-Axis: Count of ListenId

```
SELECT 
    CAST(l.ListenDate AS DATE) AS ListenDate,
    COUNT(l.ListenId) AS TotalListens
FROM Listen l
GROUP BY CAST(l.ListenDate AS DATE)
ORDER BY ListenDate;
```

---

### 4.3 Най-слушани песни (Top Tracks)

Power BI визуализация: Bar Chart

Y-Axis: Track.Title

X-Axis: Track Listen Count

```
SELECT 
    t.Title,
    COUNT(l.ListenId) AS TrackListenCount
FROM Track t
LEFT JOIN Listen l ON l.TrackId = t.TrackId
GROUP BY t.Title
ORDER BY TrackListenCount DESC;
```

## 5. Стартиране на Power BI доклада

Стартирай SQL Server

Увери се, че SpotifyDB е създадена и заредена

Отвори Power_BI/SpotifyDB.pbix

Натисни Refresh

Визуализациите се обновяват автоматично.

## 6. Обобщение на моделите

Концептуален модел (Chen) – бизнес логика

Логически модел (Crow’s Foot) – реална структура

Data Warehouse модел (UML) – аналитичен модел за отчетност

## 7. Използвани технологии

MS SQL Server

SQL Server Management Studio

Power BI Desktop

draw.io

GitHub
