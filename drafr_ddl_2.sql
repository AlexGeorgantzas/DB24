-- Drop tables if they exist to avoid errors
-- SET FOREIGN_KEY_CHECKS = 0;

-- -- Drop tables in the order of dependency (least dependent first)
-- DROP TABLE IF EXISTS recipe_img, label_recipe, meal_recipe, steps, episode, ep_info;
-- DROP TABLE IF EXISTS recipe, user, label, meal_type;
-- DROP TABLE IF EXISTS ingredient, equipment;
-- DROP TABLE IF EXISTS images, food_group, user_group, cook, national_cuisine, thematic_section, expertise;

-- -- Re-enable foreign key checks after operations
-- SET FOREIGN_KEY_CHECKS = 1;


-- Images table
CREATE TABLE images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    image_desc TEXT
) ENGINE=InnoDB;

-- Food Group table
CREATE TABLE food_group (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(255),
    image_id INT,
    FOREIGN KEY (image_id) REFERENCES images(image_id)
) ENGINE=InnoDB;

-- Ingredients table
CREATE TABLE ingredient (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    calories DECIMAL(10, 2),
    unit VARCHAR(50),
    image_id INT,
    group_id INT,
    FOREIGN KEY (image_id) REFERENCES images(image_id),
    FOREIGN KEY (group_id) REFERENCES food_group(group_id)
) ENGINE=InnoDB;

-- Equipment table
CREATE TABLE equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    instructions TEXT,
    image_id INT,
    FOREIGN KEY (image_id) REFERENCES images(image_id)
) ENGINE=InnoDB;

-- Meal Type table
CREATE TABLE meal_type (
    meal_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- Cook table
CREATE TABLE cook (
    cook_id INT AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(255),
    lastname VARCHAR(255),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    age INT,
    experience INT
) ENGINE=InnoDB;

-- Recipes table
CREATE TABLE recipe (
    recipe_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255),
    national_cuisine VARCHAR(255),
    difficulty_level INT,
    description TEXT,
    prep_time INT,
    cook_time INT,
    portions INT,
    main_ingredient INT,
    tip_1 TEXT,
    tip_2 TEXT,
    tip_3 TEXT,
    calories DECIMAL(10, 2),
    FOREIGN KEY (main_ingredient) REFERENCES ingredient(ingredient_id)
) ENGINE=InnoDB;

-- Recipe Images table
CREATE TABLE recipe_img (
    img_id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT,
    image_id INT,
    FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id),
    FOREIGN KEY (image_id) REFERENCES images(image_id)
) ENGINE=InnoDB;

-- Meal Type Recipes table
CREATE TABLE meal_recipe (
    meal_type_id INT,
    recipe_id INT,
    PRIMARY KEY (meal_type_id, recipe_id),
    FOREIGN KEY (meal_type_id) REFERENCES meal_type(meal_type_id),
    FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id)
) ENGINE=InnoDB;

-- Labels table
CREATE TABLE label (
    label_id INT AUTO_INCREMENT PRIMARY KEY,
    description TEXT
) ENGINE=InnoDB;

-- Label Recipes table
CREATE TABLE label_recipe (
    label_id INT,
    recipe_id INT,
    PRIMARY KEY (label_id, recipe_id),
    FOREIGN KEY (label_id) REFERENCES label(label_id),
    FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id)
) ENGINE=InnoDB;

-- Steps table
CREATE TABLE steps (
    step_id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT,
    description TEXT,
    FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id)
) ENGINE=InnoDB;

-- User table
CREATE TABLE user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(255),
    user_group_id INT,
    image_id INT,
    FOREIGN KEY (user_group_id) REFERENCES user_group(user_group_id),
    FOREIGN KEY (image_id) REFERENCES images(image_id)
) ENGINE=InnoDB;

-- User Group table
CREATE TABLE user_group (
    user_group_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    image_id INT,
    FOREIGN KEY (image_id) REFERENCES images(image_id)
) ENGINE=InnoDB;

-- Episodes table
CREATE TABLE episode (
    episode_id INT AUTO_INCREMENT PRIMARY KEY,
    judge_1 INT,
    judge_2 INT,
    judge_3 INT,
    season INT
) ENGINE=InnoDB;
