# DB24

# DB24 Project

## Introduction
This project is a semester assignment for the Database Systems course at the National Technical University of Athens, developed by students from the School of Electrical and Computer Engineering.

## Project Team
- **Georgios Alexandros Georgantzas** (AM: 03120017)
- **Athanasios Kalogeropoulos** (AM: 03120149)
- **Christina Lada** (AM: 09120007)

## Project Overview
The project involves the design and implementation of a database system using ER and Relational diagrams. The primary focus is on converting ER diagrams to relational models, managing many-to-many relationships, and optimizing query performance with indexes.

## Database Design
- **ER Diagram**: Created using Lucidchart.
- **Relational Diagram**: Translates ER models into relational tables.

### Key Tables
- meal_recipe
- label_recipe
- recipe_ingr
- theme_recipe
- ep_info
- expertise
- recipe_eq

### Indexes
- **Automatic Indexes**: Primary keys.
- **Additional Indexes**:
  - fk_image_id_idx
  - cook_name_idx
  - recipe_name_idx

### Unique Indexes
- ingr_group_image_idx (ingredient_ID, food_group_ID)
- recipe_cuisine_main_ingr (recipe_ID, national_cuisine_ID, main_ingredient_ID)
- recipe_label_idx (label_ID, recipe_ID)
- steps_recipe (step_ID, recipe_ID, sequence_number)
- ep_info_idx (ep_ID, cook_ID, recipe_ID)
- cook_user_idx (cook_ID, user_ID)

## DDL & DML Scripts
- **DDL.sql**: Creates the database schema.
- **DML.sql**: Populates the database with initial data.

## Installation
1. Install [MariaDB](https://mariadb.org).
2. Install [phpMyAdmin](https://www.phpmyadmin
