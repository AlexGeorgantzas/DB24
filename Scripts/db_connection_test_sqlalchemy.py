from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

# Database configuration
username = 'your_username'
password = 'your_password'
host = 'your_host'
database = 'RecipeDB'

# Connection string
connection_string = f'mysql+pymysql://{username}:{password}@{host}/{database}'

def test_db_connection():
    try:
        # Create an engine instance
        engine = create_engine(connection_string)

        # Connect to the database
        with engine.connect() as connection:
            # Execute a simple query
            result = connection.execute("SELECT DATABASE();")
            db_name = result.fetchone()

            # Print the result
            print(f"Connected to database: {db_name[0]}")

    except SQLAlchemyError as e:
        print(f"Error connecting to the database: {e}")

if __name__ == "__main__":
    test_db_connection()
