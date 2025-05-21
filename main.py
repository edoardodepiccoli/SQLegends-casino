import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
from tqdm import tqdm
import os

# Initialize Faker
fake = Faker()

# Database connection parameters
DB_PARAMS = {
    'dbname': 'sqlegends',
    'user': 'edoardo',
    'password': '0100',
    'host': 'localhost',
    'port': '5432'
}

def connect_to_db():
    return psycopg2.connect(**DB_PARAMS)

def clear_existing_data(cursor):
    # Delete data in reverse order of dependencies
    cursor.execute("DELETE FROM bet")
    cursor.execute("DELETE FROM player_match")
    cursor.execute("DELETE FROM match")
    cursor.execute("DELETE FROM cards_game")
    cursor.execute("DELETE FROM dice_game")
    cursor.execute("DELETE FROM game")
    cursor.execute("DELETE FROM casino")
    cursor.execute("DELETE FROM city")
    cursor.execute("DELETE FROM player")
    print("Existing data cleared successfully!")

def generate_cities_and_casinos(cursor, num_cities=5):
    cities = []
    casinos = []
    
    # Generate cities
    for _ in tqdm(range(num_cities), desc="Generating cities", leave=False):
        city_name = fake.city()
        cities.append((city_name,))
        cursor.execute("INSERT INTO city (name) VALUES (%s)", (city_name,))
    
    # Generate casinos (one per city)
    for city in tqdm(cities, desc="Generating casinos", leave=False):
        casino_name = fake.company()
        opening_date = fake.date_between(start_date='-10y', end_date='today')
        casinos.append((casino_name, opening_date, city[0]))
        cursor.execute(
            "INSERT INTO casino (name, opening_date, city_name) VALUES (%s, %s, %s)",
            (casino_name, opening_date, city[0])
        )
    
    return cities, casinos

def generate_games(cursor, casinos, num_games=10):
    games = []
    cards_games = []
    dice_games = []
    
    for i in tqdm(range(num_games), desc="Generating games", leave=False):
        game_id = i + 1
        casino = random.choice(casinos)
        game_name = fake.word()
        description = fake.text(max_nb_chars=200)
        
        games.append((game_id, game_name, description, casino[0], casino[2]))
        cursor.execute(
            "INSERT INTO game (id, name, description, casino_name, casino_city_name) VALUES (%s, %s, %s, %s, %s)",
            (game_id, game_name, description, casino[0], casino[2])
        )
        
        # Randomly decide if it's a cards game or dice game
        if random.choice([True, False]):
            cards_games.append((
                random.randint(2, 8),  # max_players
                random.randint(2, 4),  # min_players
                random.randint(1, 6),  # decks_count
                game_id
            ))
            cursor.execute(
                "INSERT INTO cards_game (max_players, min_players, decks_count, game_id) VALUES (%s, %s, %s, %s)",
                cards_games[-1]
            )
        else:
            dice_games.append((
                random.randint(2, 4),  # min_players
                random.randint(4, 8),  # max_players
                random.randint(1, 3),  # dice_count
                random.randint(5, 50),  # min_bet
                random.randint(100, 1000),  # max_bet
                game_id
            ))
            cursor.execute(
                "INSERT INTO dice_game (min_players, max_players, dice_count, min_bet, max_bet, game_id) VALUES (%s, %s, %s, %s, %s, %s)",
                dice_games[-1]
            )
    
    return games

def generate_players(cursor, num_players=20):
    players = []
    
    for _ in tqdm(range(num_players), desc="Generating players", leave=False):
        fiscal_code = fake.unique.ssn()
        email = fake.email()
        level = random.randint(1, 10)
        
        players.append((fiscal_code, email, level))
        cursor.execute(
            "INSERT INTO player (fiscal_code, email, level) VALUES (%s, %s, %s)",
            (fiscal_code, email, level)
        )
    
    return players

def generate_matches_and_bets(cursor, games, players, num_matches=30):
    # Calculate total operations for progress bar
    total_operations = num_matches
    with tqdm(total=total_operations, desc="Generating matches and bets") as pbar:
        for _ in range(num_matches):
            game = random.choice(games)
            start_time = fake.date_time_between(start_date='-1y', end_date='now')
            end_time = start_time + timedelta(hours=random.randint(1, 4))
            
            # Insert match
            cursor.execute(
                "INSERT INTO match (start_timestamp, end_timestamp, game_id) VALUES (%s, %s, %s)",
                (start_time, end_time, game[0])
            )
            
            # Add random number of players to the match
            num_players = random.randint(2, 8)
            match_players = random.sample(players, num_players)
            
            # Track used bet times for the entire match
            used_bet_times = set()
            for player in match_players:
                # Add player to match
                cursor.execute(
                    "INSERT INTO player_match (player_fiscal_code, match_game_id, match_start_timestamp) VALUES (%s, %s, %s)",
                    (player[0], game[0], start_time)
                )
                
                # Add random number of bets for each player, ensuring unique timestamps per match
                num_bets = random.randint(1, 5)
                for _ in range(num_bets):
                    # Ensure unique timestamp for each bet in the match
                    while True:
                        bet_time = start_time + timedelta(minutes=random.randint(1, 180))
                        if bet_time not in used_bet_times:
                            used_bet_times.add(bet_time)
                            break
                    
                    bet_amount = random.randint(10, 1000)
                    
                    # Determine if the bet wins or loses (house edge of ~5%)
                    if random.random() < 0.2:  # 47.5% chance to win
                        # If win, determine the payout multiplier based on game type
                        if game[1].lower() in ['blackjack', 'poker']:
                            # Blackjack pays 3:2 or 1:1, poker has variable payouts
                            multiplier = random.choice([1.0, 1.5, 2.0, 2.5, 3.0])
                        elif game[1].lower() in ['roulette']:
                            # Roulette has specific payouts (35:1 for single number, 2:1 for dozens, etc.)
                            multiplier = random.choice([1.0, 2.0, 3.0, 11.0, 17.0, 35.0])
                        elif game[1].lower() in ['craps']:
                            # Craps has specific payouts
                            multiplier = random.choice([1.0, 2.0, 3.0, 7.0, 9.0])
                        else:
                            # Default for other games
                            multiplier = random.choice([1.0, 1.5, 2.0])
                        
                        # Player wins: casino_earning is negative (casino loses)
                        casino_earning = -int(bet_amount * multiplier)
                    else:
                        # Player loses: casino_earning is positive (casino wins)
                        casino_earning = bet_amount
                    
                    cursor.execute(
                        "INSERT INTO bet (bet_amount, casino_earning, timestamp, player_fiscal_code, match_game_id, match_start_timestamp) VALUES (%s, %s, %s, %s, %s, %s)",
                        (bet_amount, casino_earning, bet_time, player[0], game[0], start_time)
                    )
            pbar.update(1)

def main():
    try:
        conn = connect_to_db()
        cursor = conn.cursor()
        
        # Clear existing data first
        clear_existing_data(cursor)
        
        # Generate data in the correct order to respect constraints
        cities, casinos = generate_cities_and_casinos(cursor, 10)
        games = generate_games(cursor, casinos, 10)
        players = generate_players(cursor, 1000)
        generate_matches_and_bets(cursor, games, players, 10000)
        
        # Commit the changes
        conn.commit()
        print("\nDatabase populated successfully!")
        
    except Exception as e:
        print(f"\nAn error occurred: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()
