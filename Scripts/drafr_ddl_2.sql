-- Drop tables if they exist to avoid errors
-- SET FOREIGN_KEY_CHECKS = 0;

-- -- Drop tables in § order of dependency (least dependent first)
-- DROP TABLE IF EXISTS recipe_img, label_recipe, meal_recipe, steps, episode, ep_info;
-- DROP TABLE IF EXISTS recipe, user, label, meal_type;
-- DROP TABLE IF EXISTS ingredient, equipment;
-- DROP TABLE IF EXISTS images, food_group, user_group, cook, national_cuisine, thematic_section, expertise;

-- -- Re-enable foreign key checks after operations
-- SET FOREIGN_KEY_CHECKS = 1;


-- Images table
CREATE TABLE images (
    image_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_desc TEXT ,
    image_url TEXT NOT NULL
) ENGINE=InnoDB;

-- Food Group table
CREATE TABLE food_group (
    food_group_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT NOT NULL,
    food_group_name VARCHAR(255) NOT NULL,
    food_group_desc TEXT NOT NULL,
    category VARCHAR(255) NOT NULL,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- Ingredients table
CREATE TABLE ingredient (
    ingredient_ID INT AUTO_INCREMENT PRIMARY KEY,
    food_group_ID INT NOT NULL,
    image_ID INT NOT NULL,
    ingr_name VARCHAR(255) NOT NULL,
    calories DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID),
    FOREIGN KEY (food_group_ID) REFERENCES food_group(food_group_ID)
) ENGINE=InnoDB;

-- Equipment table
CREATE TABLE equipment (
    eq_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT NOT NULL,
    eq_name VARCHAR(255) NOT NULL,
    instructions TEXT NOT NULL,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- Meal Type table
CREATE TABLE meal_type (
    meal_type_ID INT AUTO_INCREMENT PRIMARY KEY,
    meal_type_name VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- Cook table
CREATE TABLE cook (
    cook_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    age INT NOT NULL,
    experience INT NOT NULL,
    rank INT NOT NULL,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- Recipes table
CREATE TABLE recipe (
    recipe_ID INT AUTO_INCREMENT PRIMARY KEY,
    national_cuisine_ID INT NOT NULL,
    main_ingredient_ID INT NOT NULL,
    recipe_name VARCHAR(255) NOT NULL,
    difficulty_level INT NOT NULL,
    recipe_description TEXT NOT NULL,
    prep_time INT NOT NULL,
    cook_time INT NOT NULL,
    portions INT NOT NULL,
    tip_1 TEXT ,
    tip_2 TEXT ,
    tip_3 TEXT ,
    fat DECIMAL(10, 1) NOT NULL,
    carbs DECIMAL(10, 1) NOT NULL,
    proteins DECIMAL(10, 1) NOT NULL,
    calories DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (national_cuisine_ID) REFERENCES national_cuisine(national_cuisine_ID),
    FOREIGN KEY (main_ingredient_ID) REFERENCES ingredient(ingredient_ID)
) ENGINE=InnoDB;

-- Meal Type Recipes table
CREATE TABLE meal_recipe (
    meal_type_ID INT NOT NULL,
    recipe_ID INT NOT NULL,
    PRIMARY KEY (meal_type_ID, recipe_ID),
    FOREIGN KEY (meal_type_ID) REFERENCES meal_type(meal_type_ID),
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
) ENGINE=InnoDB;

-- Labels table
CREATE TABLE label (
    label_ID INT AUTO_INCREMENT PRIMARY KEY,
    label_description TEXT NOT NULL
) ENGINE=InnoDB;

-- Label Recipes table
CREATE TABLE label_recipe (
    label_ID INT NOT NULL,
    recipe_ID INT NOT NULL,
    PRIMARY KEY (label_ID, recipe_ID),
    FOREIGN KEY (label_ID) REFERENCES label(label_ID),
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
) ENGINE=InnoDB;

-- Steps table
CREATE TABLE steps (
    step_ID INT AUTO_INCREMENT PRIMARY KEY,
    recipe_ID INT NOT NULL,
    step_description TEXT NOT NULL,
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
) ENGINE=InnoDB;

-- User table OK
CREATE TABLE user_table (
    username INT AUTO_INCREMENT PRIMARY KEY,
    user_group_ID INT NOT NULL,
    image_ID INT NOT NULL,
    user_password CHAR(64) NOT NULL,
    FOREIGN KEY (user_group_ID) REFERENCES user_group(user_group_ID),
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- User Group table
CREATE TABLE user_group (
    user_group_ID INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- Episodes table
CREATE TABLE episode (
    ep_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT NOT NULL,
    judge_1 INT NOT NULL,
    judge_2 INT NOT NULL,
    judge_3 INT NOT NULL,
    season INT NOT NULL,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- Theme table
CREATE TABLE theme (
    theme_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT NOT NULL,
    theme_name TEXT NOT NULL,
    theme_desc TEXT NOT NULL,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- Theme Recipes table
CREATE TABLE theme_recipe (
    theme_ID INT NOT NULL,
    recipe_ID INT NOT NULL,
    FOREIGN KEY (theme_ID) REFERENCES theme(theme_ID),
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
) ENGINE=InnoDB;
