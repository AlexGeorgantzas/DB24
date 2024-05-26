import mysql.connector
from mysql.connector import Error

try:
    #userName = input("Enter DB Username: ").strip()
    userName = "root"
    #pswd = input("Enter DB Password: ").strip()
    pswd = "2255"

    conn = mysql.connector.connect(
        host="localhost",
        port="3306",  # Port as a string
        user=userName,
        password=pswd,
        database="recipeDB"
    )

    if conn.is_connected():
        print("Successfully connected to the database")

    cursor = conn.cursor()

    # Example query
    cursor.execute("SELECT * FROM label")  # Replace 'your_table' with your actual table name

    # Fetch results
    results = cursor.fetchall()
    for row in results:
        print(row)

    # Close the cursor and connection
    cursor.close()
    conn.close()

except Error as e:
    print("Error while connecting to MariaDB:", e)
