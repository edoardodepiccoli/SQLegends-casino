-- At least 3 queries with GROUP BY, at least 1 with GROUP BY and HAVING
-- Find the top 10 players by total win amount (negative casino_earning means player won)
SELECT player.email,
    SUM(- bet.casino_earning) AS total_win_amount
FROM player
    JOIN bet ON player.fiscal_code = bet.player_fiscal_code
GROUP BY player.email
ORDER BY total_win_amount DESC
LIMIT 10;
-- Find the average profit per player for each casino (positive casino_earning means casino won)
SELECT casino.name AS casino_name,
    AVG(bet.casino_earning) AS average_profit_per_player
FROM casino
    JOIN game ON casino.name = game.casino_name
    AND casino.city_name = game.casino_city_name
    JOIN match ON game.id = match.game_id
    JOIN bet ON match.game_id = bet.match_game_id
GROUP BY casino.name
ORDER BY AVG(bet.casino_earning) DESC;
-- Find the casino with the most players and the total earnings (positive casino_earning means casino won)
SELECT casino.name AS casino_name,
    COUNT(DISTINCT bet.player_fiscal_code) AS total_players,
    SUM(bet.casino_earning) AS total_earnings
FROM casino
    JOIN game ON casino.name = game.casino_name
    JOIN match ON game.id = match.game_id
    JOIN bet ON match.game_id = bet.match_game_id
GROUP BY casino.name
ORDER BY COUNT(DISTINCT bet.player_fiscal_code) DESC;
-- Find the most popular game for each casino
SELECT casino.name AS casino_name,
    game.name AS game_name,
    COUNT(DISTINCT bet.player_fiscal_code) AS total_players
FROM casino
    JOIN game ON casino.name = game.casino_name
    JOIN match ON game.id = match.game_id
    JOIN bet ON match.game_id = bet.match_game_id
GROUP BY casino.name,
    game.name
ORDER BY COUNT(DISTINCT bet.player_fiscal_code) DESC;
-- Find the most profitable game for each casino
SELECT casino.name AS casino_name,
    game.name AS game_name,
    SUM(bet.casino_earning) AS total_earnings
FROM casino
    JOIN game ON casino.name = game.casino_name
    JOIN match ON game.id = match.game_id
    JOIN bet ON match.game_id = bet.match_game_id
GROUP BY casino.name,
    game.name
ORDER BY SUM(bet.casino_earning) DESC;