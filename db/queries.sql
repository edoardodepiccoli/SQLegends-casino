-- Find the top 10 players by total win amount
SELECT player.email,
    SUM(bet.win_amount)
FROM player
    JOIN bet ON player.fiscal_code = bet.player_fiscal_code
GROUP BY player.email
ORDER BY SUM(bet.win_amount) DESC
LIMIT 10;