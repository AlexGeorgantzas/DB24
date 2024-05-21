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
    image_desc TEXT
    image_url TEXT
) ENGINE=InnoDB;

-- Food Group table
CREATE TABLE food_group (
    food_group_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT,
    food_group_name VARCHAR(255) NOT NULL,
    food_group_desc TEXT,
    category VARCHAR(255),
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- Ingredients table
CREATE TABLE ingredient (
    ingredient_ID INT AUTO_INCREMENT PRIMARY KEY,
    food_group_ID INT,
    image_ID INT,
    ingr_name VARCHAR(255) NOT NULL,
    calories DECIMAL(10, 2),
    unit VARCHAR(50),
    FOREIGN KEY (image_ID) REFERENCES images(image_ID),
    FOREIGN KEY (food_group_ID) REFERENCES food_group(food_group_ID)
) ENGINE=InnoDB;

-- Equipment table
CREATE TABLE equipment (
    eq_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT,
    eq_name VARCHAR(255) NOT NULL,
    instructions TEXT,
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
    image_ID INT,
    firstname VARCHAR(255),
    lastname VARCHAR(255),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    age INT,
    experience INT
    rank INT
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- Recipes table
CREATE TABLE recipe (
    recipe_ID INT AUTO_INCREMENT PRIMARY KEY,
    national_cuisine_ID INT,
    main_ingredient_ID INT,
    recipe_name VARCHAR(255) NOT NULL,
    difficulty_level INT,
    recipe_description TEXT,
    prep_time INT,
    cook_time INT,
    portions INT,
    tip_1 TEXT,
    tip_2 TEXT,
    tip_3 TEXT,
    fat DECIMAL(10, 1),
    carbs DECIMAL(10, 1),
    proteins DECIMAL(10, 1),
    calories DECIMAL(10, 2),
    FOREIGN KEY (national_cuisine_ID) REFERENCES national_cuisine(national_cuisine_ID)
    FOREIGN KEY (main_ingredient_ID) REFERENCES ingredient(ingredient_ID)
) ENGINE=InnoDB;

-- Meal Type Recipes table
CREATE TABLE meal_recipe (
    meal_type_ID INT.
    recipe_ID INT,
    PRIMARY KEY (meal_type_ID, recipe_ID),
    FOREIGN KEY (meal_type_ID) REFERENCES meal_type(meal_type_ID),
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
) ENGINE=InnoDB;

-- Labels table
CREATE TABLE label (
    label_ID INT AUTO_INCREMENT PRIMARY KEY,
    label_description TEXT
) ENGINE=InnoDB;

-- Label Recipes table
CREATE TABLE label_recipe (
    label_ID INT,
    recipe_ID INT,
    PRIMARY KEY (label_ID, recipe_ID),
    FOREIGN KEY (label_ID) REFERENCES label(label_ID),
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
) ENGINE=InnoDB;

-- Steps table
CREATE TABLE steps (
    step_ID INT AUTO_INCREMENT PRIMARY KEY,
    recipe_ID INT,
    step_description TEXT,
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
) ENGINE=InnoDB;

-- User table OK
CREATE TABLE user_table (
    username INT AUTO_INCREMENT PRIMARY KEY,
    user_group_ID INT,
    image_ID INT,
    user_password CHAR(64),
    FOREIGN KEY (user_group_ID) REFERENCES user_group(user_group_ID),
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

-- User Group table
CREATE TABLE user_group (
    user_group_ID INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(255),
) ENGINE=InnoDB;

-- Episodes table
CREATE TABLE episode (
    ep_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT,
    judge_1 INT,
    judge_2 INT,
    judge_3 INT,
    season INT,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
) ENGINE=InnoDB;

CREATE TABLE theme (
    theme_ID INT AUTO_INCREMENT PRIMARY KEY,
    image_ID INT,
    theme_name TEXT,
    theme_desc TEXT,
    FOREIGN KEY (image_ID) REFERENCES images(image_ID)
)

CREATE TABLE theme_recipe (
    theme_ID INT,
    recipe_ID INT,
    FOREIGN KEY (theme_ID) REFERENCES theme(theme_ID),
    FOREIGN KEY (recipe_ID) REFERENCES recipe(recipe_ID)
)