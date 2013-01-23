CREATE TABLE chefs (
  id INTEGER PRIMARY KEY,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  mentor INTEGER,
  FOREIGN KEY(mentor) REFERENCES chef(id)
);

CREATE TABLE restaurants (
  id INTEGER PRIMARY KEY,
  name VARCHAR(20),
  neighborhood VARCHAR(20),
  cuisine VARCHAR(20)
);

CREATE TABLE head_chef_tenures (
  id INTEGER PRIMARY KEY,
  chef_id INTEGER,
  restaurant_id INTEGER,
  start_date DATE,
  end_date DATE,
  FOREIGN KEY(chef_id) REFERENCES chef(id),
  FOREIGN KEY(restaurant_id) REFERENCES restaurant(id)
);

CREATE TABLE critics (
  id INTEGER PRIMARY KEY,
  screen_name VARCHAR(20)
);

CREATE TABLE restaurant_reviews (
  id INTEGER PRIMARY KEY,
  review TEXT,
  score REAL,
  review_date DATE,
  restaurant_id INTEGER,
  critic_id INTEGER,
  FOREIGN KEY(restaurant_id) REFERENCES restaurant(id),
  FOREIGN KEY(critic_id) REFERENCES critics(id)
);