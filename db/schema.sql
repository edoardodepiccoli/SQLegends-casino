CREATE TABLE city (name VARCHAR(255), PRIMARY KEY (name));
CREATE TABLE casino (
    name VARCHAR(255),
    opening_date DATE,
    city_name VARCHAR(255),
    PRIMARY KEY (name, city_name),
    UNIQUE (city_name),
    FOREIGN KEY (city_name) REFERENCES city(name)
);
CREATE TABLE game (
    id INTEGER,
    name VARCHAR(255),
    description TEXT,
    casino_name VARCHAR(255),
    casino_city_name VARCHAR(255),
    PRIMARY KEY (id),
    FOREIGN KEY (casino_name, casino_city_name) REFERENCES casino(name, city_name)
);
CREATE TABLE cards_game (
    max_players INTEGER,
    min_players INTEGER,
    decks_count INTEGER,
    game_id INTEGER,
    PRIMARY KEY (game_id),
    FOREIGN KEY (game_id) REFERENCES game(id)
);
CREATE TABLE dice_game (
    min_players INTEGER,
    max_players INTEGER,
    dice_count INTEGER,
    min_bet INTEGER,
    max_bet INTEGER,
    game_id INTEGER,
    PRIMARY KEY (game_id),
    FOREIGN KEY (game_id) REFERENCES game(id)
);
CREATE TABLE match(
    start_timestamp TIMESTAMP,
    end_timestamp TIMESTAMP,
    game_id INTEGER,
    PRIMARY KEY (game_id, start_timestamp),
    FOREIGN KEY (game_id) REFERENCES game(id)
);
CREATE TABLE player (
    fiscal_code VARCHAR(255),
    email VARCHAR(255),
    level INTEGER,
    PRIMARY KEY (fiscal_code)
);
CREATE TABLE player_match (
    player_fiscal_code VARCHAR(255),
    match_game_id INTEGER,
    match_start_timestamp TIMESTAMP,
    PRIMARY KEY (
        player_fiscal_code,
        match_game_id,
        match_start_timestamp
    ),
    FOREIGN KEY (player_fiscal_code) REFERENCES player(fiscal_code),
    FOREIGN KEY (match_game_id, match_start_timestamp) REFERENCES match(game_id, start_timestamp)
);
CREATE TABLE bet (
    amount INTEGER,
    win_amount INTEGER,
    timestamp TIMESTAMP,
    player_fiscal_code VARCHAR(255),
    match_game_id INTEGER,
    match_start_timestamp TIMESTAMP,
    PRIMARY KEY (match_game_id, match_start_timestamp, timestamp),
    FOREIGN KEY (player_fiscal_code) REFERENCES player(fiscal_code),
    FOREIGN KEY (match_game_id, match_start_timestamp) REFERENCES match(game_id, start_timestamp)
);