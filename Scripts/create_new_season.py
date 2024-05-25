from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import random
import pyodbc
import pandas as pd

 
# Establish a connection to the database
engine = create_engine('mysql+pyodbc://root:2255@localhost/recipedb')
conn = engine.connect()
#Session = sessionmaker(bind=engine)
#session = Session()

# SQL queries
get_all_cuisines_query = "SELECT national_cuisine_ID FROM national_cuisine"
get_all_cooks_query = "SELECT cook_ID FROM cook"
get_all_recipes_query = "SELECT recipe_ID, national_cuisine_ID FROM recipe"
get_expertise_query = "SELECT cook_ID, national_cuisine_ID FROM expertise"

# Execute SQL queries
all_cuisines = [row[0] for row in session.execute(get_all_cuisines_query)]
all_cooks = [row[0] for row in session.execute(get_all_cooks_query)]
all_recipes = [(row[0], row[1]) for row in session.execute(get_all_recipes_query)]
expertise = [(row[0], row[1]) for row in session.execute(get_expertise_query)]


def is_valid_selection(selection, history):
    return history.count(selection) < 3

def update_history(history, selection):
    history.append(selection)
    if len(history) > 3:
        history.pop(0)


def create_new_season(year, num_episodes=10):
    new_season_number = session.execute("SELECT IFNULL(MAX(season), 0) + 1 FROM episode").scalar()
    cuisine_history, recipe_history, cook_history = [], [], []

    for episode_num in range(1, num_episodes + 1):
        selected_cuisines = []
        selected_recipes = []
        selected_cooks = []

        # Select 10 random cuisines
        while len(selected_cuisines) < 10:
            cuisine = random.choice(all_cuisines)
            if is_valid_selection(cuisine, cuisine_history):
                selected_cuisines.append(cuisine)
                update_history(cuisine_history, cuisine)

        # Select 1 recipe from each selected cuisine
        for cuisine in selected_cuisines:
            valid_recipes = [recipe for recipe in all_recipes if recipe[1] == cuisine]
            recipe = random.choice(valid_recipes)[0]
            if is_valid_selection(recipe, recipe_history):
                selected_recipes.append(recipe)
                update_history(recipe_history, recipe)

        # Select 10 cooks based on their expertise
        for cuisine in selected_cuisines:
            valid_cooks = [cook for cook in expertise if cook[1] == cuisine]
            cook = random.choice(valid_cooks)[0]
            if is_valid_selection(cook, cook_history):
                selected_cooks.append(cook)
                update_history(cook_history, cook)

        # Insert new episode
        judges = random.sample(all_cooks, 3)
        insert_episode_query = """
        INSERT INTO episode (image_ID, judge_1, judge_2, judge_3, season, episode)
        VALUES (1, :judge1, :judge2, :judge3, :season, :episode)
        """
        session.execute(insert_episode_query, {
            'judge1': judges[0],
            'judge2': judges[1],
            'judge3': judges[2],
            'season': new_season_number,
            'episode': episode_num
        })
        session.commit()
        new_episode_id = session.execute("SELECT LAST_INSERT_ID()").scalar()

        # Assign recipes to cooks and insert ep_info
        for cook, recipe in zip(selected_cooks, selected_recipes):
            insert_ep_info_query = """
            INSERT INTO ep_info (ep_ID, cook_ID, recipe_ID, rating_1, rating_2, rating_3, avg_rating)
            VALUES (:ep_id, :cook_id, :recipe_id, :rating1, :rating2, :rating3, :avg_rating)
            """
            ratings = [random.randint(1, 5) for _ in range(3)]
            avg_rating = sum(ratings) / 3
            session.execute(insert_ep_info_query, {
                'ep_id': new_episode_id,
                'cook_id': cook,
                'recipe_id': recipe,
                'rating1': ratings[0],
                'rating2': ratings[1],
                'rating3': ratings[2],
                'avg_rating': avg_rating
            })
        session.commit()

if __name__ == "__main__":
    create_new_season(2024)

