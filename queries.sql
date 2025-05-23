-- 1. Total transactions per player (Group By)
SELECT g.codice_fiscale,
  g.nome || ' ' || g.cognome AS player_name,
  SUM(t.quantita) AS total_transactions
FROM transazione t
  JOIN giocatore g ON t.giocatore = g.codice_fiscale
GROUP BY g.codice_fiscale,
  player_name;
-- 2. Average match duration per game type (Group By)
SELECT gc.nome AS game_name,
  AVG(p.durata_minuti) AS avg_duration
FROM partita p
  JOIN gioco gc ON p.gioco = gc.id
GROUP BY gc.nome;
-- 3. Players with more than 1 session (Group By + Having)
SELECT gs.giocatore,
  COUNT(*) AS session_count
FROM giocatore_sessione gs
GROUP BY gs.giocatore
HAVING COUNT(*) > 1;
-- 4. Dealers per room with experience (Group By)
SELECT s.nome_sala,
  s.livello,
  COUNT(d.codice_fiscale) AS dealers_count,
  AVG(d.anni_esperienza) AS avg_experience
FROM dealer d
  JOIN sala s ON d.sala = s.nome_sala
GROUP BY s.nome_sala,
  s.livello;
-- 5. High-stakes games (quantita > 1000) per session (Group By + Join)
SELECT s.timestamp_inizio,
  p.gioco,
  COUNT(t.*) AS high_stakes_transactions
FROM transazione t
  JOIN partita p ON t."timestamp" = p.timestamp_inizio
  JOIN sessione s ON t.transazione = s.timestamp_inizio
WHERE t.quantita > 1000
GROUP BY s.timestamp_inizio,
  p.gioco;