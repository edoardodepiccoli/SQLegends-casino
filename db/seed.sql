-- Clean existing data (order matters due to constraints)
DELETE FROM bet;
DELETE FROM player_match;
DELETE FROM match;
DELETE FROM dice_game;
DELETE FROM cards_game;
DELETE FROM game;
DELETE FROM casino;
DELETE FROM city;
DELETE FROM player;
-- Seed cities
INSERT INTO city (name)
VALUES ('Las Vegas'),
    ('Monte Carlo'),
    ('Macau'),
    ('Atlantic City'),
    ('Singapore');
-- Seed casinos (one per city, UNIQUE constraint on city_name)
INSERT INTO casino (name, opening_date, city_name)
VALUES ('The Mirage', '1989-11-22', 'Las Vegas'),
    (
        'Casino de Monte-Carlo',
        '1863-01-01',
        'Monte Carlo'
    ),
    ('Venetian Macau', '2007-08-28', 'Macau'),
    ('Borgata', '2003-07-02', 'Atlantic City'),
    ('Marina Bay Sands', '2010-04-27', 'Singapore');
-- Seed games
-- We'll use IDs 1 to 10
INSERT INTO game (
        id,
        name,
        description,
        casino_name,
        casino_city_name
    )
VALUES (
        1,
        'Blackjack',
        'Classic 21 game',
        'The Mirage',
        'Las Vegas'
    ),
    (
        2,
        'Roulette',
        'Spin the wheel',
        'The Mirage',
        'Las Vegas'
    ),
    (
        3,
        'Poker',
        'Texas Holdem',
        'Casino de Monte-Carlo',
        'Monte Carlo'
    ),
    (
        4,
        'Craps',
        'Dice game',
        'Casino de Monte-Carlo',
        'Monte Carlo'
    ),
    (
        5,
        'Sic Bo',
        'Chinese dice game',
        'Venetian Macau',
        'Macau'
    ),
    (
        6,
        'Baccarat',
        'Card game vs banker',
        'Venetian Macau',
        'Macau'
    ),
    (
        7,
        'Slots',
        'Slot machine game',
        'Borgata',
        'Atlantic City'
    ),
    (
        8,
        'Pai Gow',
        'Domino + Poker hybrid',
        'Borgata',
        'Atlantic City'
    ),
    (
        9,
        'Dragon Tiger',
        'Simple card game',
        'Marina Bay Sands',
        'Singapore'
    ),
    (
        10,
        'Fan Tan',
        'Beads and cups',
        'Marina Bay Sands',
        'Singapore'
    );
-- Seed games into cards_game
-- We'll treat games 1 (Blackjack), 3 (Poker), and 6 (Baccarat) as card games
INSERT INTO cards_game (max_players, min_players, decks_count, game_id)
VALUES (7, 1, 6, 1),
    (9, 2, 1, 3),
    (14, 1, 8, 6);
-- Seed games into dice_game
-- Games 4 (Craps), 5 (Sic Bo), and 9 (Dragon Tiger) as dice games (assume for demo)
INSERT INTO dice_game (
        min_players,
        max_players,
        dice_count,
        min_bet,
        max_bet,
        game_id
    )
VALUES (2, 12, 2, 10, 1000, 4),
    (1, 20, 3, 5, 500, 5),
    (1, 6, 2, 20, 200, 9);
-- Seed players
INSERT INTO player (fiscal_code, email, level)
VALUES ('ABCDEF12G34H567I', 'alice@example.com', 2),
    ('ZXCVBN98M76N543O', 'bob@example.com', 5),
    ('QWERTY45Y67U890P', 'charlie@example.com', 3),
    ('LKJHGF21D43S876F', 'diana@example.com', 4),
    ('MNPOIU65T43R210E', 'eve@example.com', 1);
-- Seed matches
-- Assume each match lasts 10-30 minutes, use game_ids 1-5
INSERT INTO match (start_timestamp, end_timestamp, game_id)
VALUES ('2024-06-15 14:00:00', '2024-06-15 14:20:00', 1),
    ('2024-06-15 15:00:00', '2024-06-15 15:25:00', 2),
    ('2024-06-16 16:00:00', '2024-06-16 16:30:00', 3),
    ('2024-06-16 17:00:00', '2024-06-16 17:15:00', 4),
    ('2024-06-17 18:00:00', '2024-06-17 18:20:00', 5);
-- Seed player_match: players play in random matches
INSERT INTO player_match (
        player_fiscal_code,
        match_game_id,
        match_start_timestamp
    )
VALUES ('ABCDEF12G34H567I', 1, '2024-06-15 14:00:00'),
    ('ZXCVBN98M76N543O', 1, '2024-06-15 14:00:00'),
    ('ABCDEF12G34H567I', 2, '2024-06-15 15:00:00'),
    ('QWERTY45Y67U890P', 2, '2024-06-15 15:00:00'),
    ('MNPOIU65T43R210E', 4, '2024-06-16 17:00:00'),
    ('ZXCVBN98M76N543O', 5, '2024-06-17 18:00:00'),
    ('QWERTY45Y67U890P', 4, '2024-06-16 17:00:00');
-- Seed bets
-- Random timestamps during matches and amounts between 25-500
INSERT INTO bet (
        amount,
        win_amount,
        timestamp,
        player_fiscal_code,
        match_game_id,
        match_start_timestamp
    )
VALUES (
        100,
        200,
        -- Won 2x bet
        '2024-06-15 14:05:00',
        'ABCDEF12G34H567I',
        1,
        '2024-06-15 14:00:00'
    ),
    (
        200,
        -200,
        -- Lost full bet
        '2024-06-15 14:10:00',
        'ZXCVBN98M76N543O',
        1,
        '2024-06-15 14:00:00'
    ),
    (
        50,
        75,
        -- Won 1.5x bet
        '2024-06-15 15:10:00',
        'ABCDEF12G34H567I',
        2,
        '2024-06-15 15:00:00'
    ),
    (
        300,
        -300,
        -- Lost full bet
        '2024-06-15 15:15:00',
        'QWERTY45Y67U890P',
        2,
        '2024-06-15 15:00:00'
    ),
    (
        75,
        150,
        -- Won 2x bet
        '2024-06-16 17:05:00',
        'MNPOIU65T43R210E',
        4,
        '2024-06-16 17:00:00'
    ),
    (
        150,
        -150,
        -- Lost full bet
        '2024-06-17 18:10:00',
        'ZXCVBN98M76N543O',
        5,
        '2024-06-17 18:00:00'
    ),
    (
        250,
        500,
        -- Won 2x bet
        '2024-06-15 14:15:00',
        'ABCDEF12G34H567I',
        1,
        '2024-06-15 14:00:00'
    ),
    (
        80,
        -80,
        -- Lost full bet
        '2024-06-15 15:20:00',
        'QWERTY45Y67U890P',
        2,
        '2024-06-15 15:00:00'
    ),
    (
        120,
        180,
        -- Won 1.5x bet
        '2024-06-16 17:10:00',
        'MNPOIU65T43R210E',
        4,
        '2024-06-16 17:00:00'
    ),
    (
        90,
        -90,
        -- Lost full bet
        '2024-06-17 18:15:00',
        'ZXCVBN98M76N543O',
        5,
        '2024-06-17 18:00:00'
    );