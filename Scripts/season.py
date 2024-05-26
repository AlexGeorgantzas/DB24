import mysql.connector
from mysql.connector import Error
import random
import logging

logging.basicConfig(
    level=logging.DEBUG,  # Set to DEBUG to capture all levels of logs
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("recipe_db.log"),  # Specify the log file name
        logging.StreamHandler()  # Also output to console
    ]
)

# MySQL connection using mysql.connector
try:
    userName = "root"
    pswd = "2255"

    conn = mysql.connector.connect(
        host="localhost",
        port=3306,
        user=userName,
        password=pswd,
        database="recipeDB"
    )

    if conn.is_connected():
        logging.info("Successfully connected to the database with mysql.connector")

        cursor = conn.cursor()

        # SQL queries
        get_all_cuisines_query = "SELECT national_cuisine_ID FROM national_cuisine"
        get_all_cooks_query = "SELECT cook_ID FROM cook"
        get_all_recipes_query = "SELECT recipe_ID, national_cuisine_ID FROM recipe"
        get_expertise_query = "SELECT cook_ID, national_cuisine_ID FROM expertise"

        # Execute SQL queries and fetch results
        cursor.execute(get_all_cuisines_query)
        all_cuisines = [row[0] for row in cursor.fetchall()]

        cursor.execute(get_all_cooks_query)
        all_cooks = [row[0] for row in cursor.fetchall()]

        cursor.execute(get_all_recipes_query)
        all_recipes = [(row[0], row[1]) for row in cursor.fetchall()]

        cursor.execute(get_expertise_query)
        expertise = [(row[0], row[1]) for row in cursor.fetchall()]

        def is_valid_selection(selection, history):
            return history.count(selection) < 3

        def update_history(history, selection):
            history.append(selection)
            if len(history) > 3:
                history.pop(0)

        def create_new_season(year, num_episodes=10):
            cursor.execute("SELECT IFNULL(MAX(season), 0) + 1 FROM episode")
            new_season_number = cursor.fetchone()[0]
            cuisine_history, recipe_history, cook_history = [], [], []

            for episode_num in range(1, num_episodes + 1):
                try:
                    selected_cuisines = []
                    selected_recipes = []
                    selected_cooks = []

                    # Select 10 random cuisines
                    while len(selected_cuisines) < 10:
                        cuisine = random.choice(all_cuisines)
                        if is_valid_selection(cuisine, cuisine_history):
                            selected_cuisines.append(cuisine)
                            update_history(cuisine_history, cuisine)

                    logging.debug(f"Episode {episode_num}: Selected cuisines: {selected_cuisines}")

                    # Select 1 recipe from each selected cuisine
                    for cuisine in selected_cuisines:
                        valid_recipes = [recipe for recipe in all_recipes if recipe[1] == cuisine]
                        logging.debug(f"Episode {episode_num}: Valid recipes for cuisine {cuisine}: {valid_recipes}")
                        if valid_recipes:  # Check if valid_recipes is not empty
                            recipe = random.choice(valid_recipes)[0]
                            if is_valid_selection(recipe, recipe_history):
                                selected_recipes.append(recipe)
                                update_history(recipe_history, recipe)
                        else:
                            logging.warning(f"No recipes found for cuisine ID: {cuisine}")
                            continue  # Skip to the next episode

                    logging.debug(f"Episode {episode_num}: Selected recipes: {selected_recipes}")

                    # Select 10 cooks based on their expertise
                    for cuisine in selected_cuisines:
                        valid_cooks = [cook for cook in expertise if cook[1] == cuisine]
                        logging.debug(f"Episode {episode_num}: Valid cooks for cuisine {cuisine}: {valid_cooks}")
                        if valid_cooks:  # Check if valid_cooks is not empty
                            cook = random.choice(valid_cooks)[0]
                            if is_valid_selection(cook, cook_history):
                                selected_cooks.append(cook)
                                update_history(cook_history, cook)
                        else:
                            logging.warning(f"No cooks found with expertise in cuisine ID: {cuisine}")
                            continue  # Skip to the next episode

                    logging.debug(f"Episode {episode_num}: Selected cooks: {selected_cooks}")

                    # Insert new episode
                    judges = random.sample(all_cooks, 3)
                    insert_episode_query = """
                    INSERT INTO episode (image_ID, judge_1, judge_2, judge_3, season, episode)
                    VALUES (1, %s, %s, %s, %s, %s)
                    """
                    cursor.execute(insert_episode_query, (
                        judges[0], judges[1], judges[2], new_season_number, episode_num
                    ))
                    conn.commit()
                    new_episode_id = cursor.lastrowid

                    # Assign recipes to cooks and insert ep_info
                    for cook, recipe in zip(selected_cooks, selected_recipes):
                        insert_ep_info_query = """
                        INSERT INTO ep_info (ep_ID, cook_ID, recipe_ID, rating_1, rating_2, rating_3, avg_rating)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """
                        ratings = [random.randint(1, 5) for _ in range(3)]
                        avg_rating = sum(ratings) / 3
                        cursor.execute(insert_ep_info_query, (
                            new_episode_id, cook, recipe, ratings[0], ratings[1], ratings[2], avg_rating
                        ))
                    conn.commit()
                    logging.info(f"Episode {episode_num} for season {new_season_number} created successfully.")
                except Exception as e:
                    logging.error(f"Error while creating episode {episode_num} for season {new_season_number}: {e}")
                    continue  # Skip to the next episode

        if __name__ == "__main__":
            create_new_season(2025)

except Error as e:
    logging.error(f"Error while connecting to MariaDB with mysql.connector: {e}")
finally:
    if conn.is_connected():
        cursor.close()
        conn.close()
