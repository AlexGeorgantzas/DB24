import requests
from bs4 import BeautifulSoup
import re
import csv

# List of categories and their links
categories = [
    ("chicken recipes", "https://www.goodhousekeeping.com/food-recipes/g4409/summer-chicken-recipes/"),
    ("vegetarian recipes", "https://www.goodhousekeeping.com/food-recipes/easy/g2352/quick-summer-dinner-recipes/"),
    ("mediterranean recipes", "https://www.goodhousekeeping.com/food-recipes/healthy/g45792818/mediterranean-diet-recipes/"),
    ("brunch recipes", "https://www.goodhousekeeping.com/food-recipes/g4201/best-brunch-recipes/"),
    ("dinner recipes", "https://www.goodhousekeeping.com/food-recipes/g33298538/sunday-dinner-ideas/"),
    ("salads", "https://www.goodhousekeeping.com/food-recipes/healthy/g180/healthy-salads/")
]

# Regular expressions to find the relevant nutritional information
fat_pattern = re.compile(r"(\d+)\s*g\s*fat")
carb_pattern = re.compile(r"(\d+)\s*g\s*(carbohydrate|carbs)")
protein_pattern = re.compile(r"(\d+)\s*g\s*protein")

# Initialize CSV files with UTF-8 encoding
with open('chicken_recipes.csv', 'w', newline='', encoding='utf-8') as f_chicken, \
     open('descr.csv', 'w', newline='', encoding='utf-8') as f_descr, \
     open('portions_time_cal.csv', 'w', newline='', encoding='utf-8') as f_ptc, \
     open('ingredients.csv', 'w', newline='', encoding='utf-8') as f_ing, \
     open('steps.csv', 'w', newline='', encoding='utf-8') as f_steps, \
     open('info.csv', 'w', newline='', encoding='utf-8') as f_info:

    # CSV writers
    writer_chicken = csv.writer(f_chicken, delimiter='|')
    writer_descr = csv.writer(f_descr, delimiter='|')
    writer_ptc = csv.writer(f_ptc, delimiter='|')
    writer_ing = csv.writer(f_ing, delimiter='|')
    writer_steps = csv.writer(f_steps, delimiter='|')
    writer_info = csv.writer(f_info, delimiter='|')

    # Write headers
    writer_chicken.writerow(['Category', 'Link', 'Name', 'Label'])
    writer_descr.writerow(['Category', 'Description', 'URL'])
    writer_ptc.writerow(['Category', 'Portions', 'Time', 'Calories', 'URL'])
    writer_ing.writerow(['Category', 'Ingredient', 'URL'])
    writer_steps.writerow(['Category', 'Step', 'URL'])
    writer_info.writerow(['Category', 'Fat', 'Carbohydrates', 'Protein', 'URL'])

    for category, cat_url in categories:
        response = requests.get(cat_url)
        soup = BeautifulSoup(response.content, 'html.parser')

        # Lists to store the data
        links = []
        labels = []
        names = []

        # Finding the relevant divs that contain the recipes
        divs = soup.find_all('div', class_='listicle-slides css-13j5f4r e16kmapv7')
        for div in divs:
            newdiv = div.find('div', class_='css-18oiw2p e16kmapv3')

            # Extracting the label
            p = newdiv.find('p', class_='css-1nd4gv7 emevuu60')
            label = p.text if p else 'N/A'
            labels.append(label)

            # Extracting the name and link
            a = div.find('a', class_='body-link css-1lx1lhv emevuu60')
            name = a.text if a else 'N/A'
            href = a['href'] if a else 'N/A'
            names.append(name)
            links.append(href)

            # Write to chicken_recipes.csv
            writer_chicken.writerow([category, href, name, label])

        for url in links:
            response = requests.get(url)
            soup = BeautifulSoup(response.content, 'html.parser')

            # Description
            div = soup.find('section', class_='css-uqxf6 e11ghb4g4')
            descr = div.text if div else 'N/A'
            writer_descr.writerow([category, descr, url])

            # Portions, time, and calories
            portions_time_cal = []
            dd = soup.find_all(class_='css-8govpn eopo4zh3')
            for d in dd:
                portions_time_cal.append(d.text)

            # Assuming portions_time_cal contains three items: portions, time, calories
            if len(portions_time_cal) == 3:
                writer_ptc.writerow([category, portions_time_cal[0], portions_time_cal[1], portions_time_cal[2], url])

            # Ingredients
            ul = soup.find(class_='ingredient-lists css-xm7ys2 e12sb1172')
            if ul:
                lis = ul.find_all(class_='css-1al7o2 e12sb1171')
                for li in lis:
                    ingredient = li.text
                    writer_ing.writerow([category, ingredient, url])

            # Steps
            directions = soup.find('ul', class_='directions css-j01fd6 e1241r8m4')
            if directions:
                instructions = directions.text
                steps = instructions.split("Step")
                steps = [step.strip() for step in steps if step]
                steps = [f"Step {step}" for step in steps]
                for step in steps:
                    writer_steps.writerow([category, step, url])

            # Nutritional information
            nutr = soup.find_all('p', class_='css-1nd4gv7 emevuu60')
            if len(nutr) > 1:
                nutritional_info = nutr[1].text
                fat_match = fat_pattern.search(nutritional_info)
                carb_match = carb_pattern.search(nutritional_info)
                protein_match = protein_pattern.search(nutritional_info)

                fat = fat_match.group(1) if fat_match else 'N/A'
                carbohydrates = carb_match.group(1) if carb_match else 'N/A'
                protein = protein_match.group(1) if protein_match else 'N/A'

                writer_info.writerow([category, f"Fat: {fat} g", f"Carbohydrates: {carbohydrates} g", f"Protein: {protein} g", url])

print("Data has been written to CSV files.")
