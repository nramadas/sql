require 'singleton'
require 'sqlite3'

class RestaurantReviews < SQLite3::Database
  include Singleton

  def initialize
    super('restaurant_reviews.db')
    self.results_as_hash = true
    self.type_translation = true
  end
  
  # good formatting!
  def add_restaurant(name, neighborhood, cuisine)
    RestaurantReviews.instance.execute(
      "INSERT INTO restaurants (name, neighborhood, cuisine)
      VALUES(?, ?, ?)",
      name, neighborhood, cuisine)
  end

  def add_chef(first_name, last_name, mentor = 0)
    RestaurantReviews.instance.execute(
      "INSERT INTO chefs (first_name, last_name, mentor)
      VALUES(?, ?, ?)", first_name, last_name, mentor)
  end

  def add_critic(screen_name)
    RestaurantReviews.instance.execute(
      "INSERT INTO critics (screen_name)
      VALUES(?)", screen_name)
  end

  def add_restaurant_review(review, score, review_date, restaurant_id, critic_id)
    RestaurantReviews.instance.execute(
      "INSERT INTO restaurant_reviews (review, score, review_date,
      restaurant_id, critic_id)
      VALUES(?, ?, ?, ?, ?)", review, score, review_date, restaurant_id, critic_id)
  end

  def add_tenure(chef_id, restaurant_id, start_date, end_date)
    RestaurantReviews.instance.execute(
      "INSERT INTO head_chef_tenures (chef_id, restaurant_id, start_date,
        end_date)
      VALUES(?,?,?,?)", chef_id, restaurant_id, start_date, end_date)
  end

  def find_restaurant(neighborhood)
    RestaurantReviews.instance.execute(
      "SELECT id, name, neighborhood FROM restaurants WHERE neighborhood=(?)",
      neighborhood)
  end

  def find_reviews_by_critic(critic)
    reviews = RestaurantReviews.instance.execute(
      "SELECT c.screen_name, rev.review, rev.score, res.name
      FROM restaurant_reviews rev
      INNER JOIN restaurants res
      ON rev.restaurant_id = res.id
      INNER JOIN critics c
      ON c.id = rev.critic_id
      WHERE c.screen_name = (?)", critic)

    total_score = reviews.inject(0) do |sum, row|
      sum + row["score"]
    end
    average_score = total_score / reviews.count.to_f

    puts "\n#{critic}'s Reviews"
    puts "Average Score: #{average_score.round(1)}\n"
    reviews.each do |review|
      puts
      puts "#{review['name']}".center(50, '-')
      puts "Rating: #{review['score'].round(1)}"
      puts
      puts "#{review['review']}".scan(/\S.{0,50}\S(?=\s|$)|\S+/)
      puts "".center(50, '-')
    end
  end

  def find_reviews_by_restaurant(restaurant_name)
    reviews = RestaurantReviews.instance.execute(
      "SELECT c.screen_name, rev.review, rev.score
      FROM restaurant_reviews rev
      INNER JOIN restaurants res
      ON rev.restaurant_id = res.id
      INNER JOIN critics c
      ON c.id = rev.critic_id
      WHERE res.name = (?)", restaurant_name)

    total_score = reviews.inject(0) do |sum, row|
      sum + row["score"]
    end
    average_score = total_score / reviews.count.to_f
    # I would break this into it's own pretty print method
    puts "\n'#{restaurant_name}' Reviews:"
    puts "Average Score: #{average_score.round(1)}\n"
    reviews.each do |review|
      puts
      puts "#{review['screen_name']}".center(50, '-')
      puts "Rating: #{review['score'].round(1)}"
      puts
      puts "#{review['review']}".scan(/\S.{0,50}\S(?=\s|$)|\S+/)
      puts "".center(50, '-')
    end
  end

  def find_chef(first_name, last_name)
    RestaurantReviews.instance.execute(
      "SELECT id, first_name, last_name
      FROM chefs
      WHERE first_name=(?) AND last_name=(?)", first_name, last_name)
  end

  def protege_count(chef_first_name, chef_last_name)
    chef_id = find_chef_id_by_name(chef_first_name, chef_last_name)

    proteges = RestaurantReviews.instance.execute(
      "SELECT first_name, last_name
      FROM chefs
      WHERE mentor = (?)", chef_id)

    proteges.count
  end

  def find_average_chef_review(chef_first_name, chef_last_name)
    chef_id = find_chef_id_by_name(chef_first_name, chef_last_name)

    scores = RestaurantReviews.instance.execute(
      "SELECT reviews.score
      FROM restaurant_reviews reviews
      JOIN head_chef_tenures tenures
      ON reviews.restaurant_id = tenures.restaurant_id
      WHERE tenures.chef_id = (?)", chef_id)

    total_score = scores.inject(0) { |sum, row| sum + row['score'] }
    average_score = (total_score / scores.count.to_f).round(1)
  end

  def find_chef_id_by_name(chef_first_name, chef_last_name)
    RestaurantReviews.instance.execute(
      "SELECT id
      FROM chefs
      WHERE first_name=(?) AND last_name = (?)", chef_first_name, chef_last_name
      )[0]['id']
  end

  # make_query({select: ["first_name", "last_name"], from: [chefs], where: ["first_name"]})

  # def make_query(options)
  #   defaults = {
  #     select: [],
  #     from: [],
  #     where: [],
  #     insert: [],
  #     into: [],
  #     values: []
  #   }

  #   options = defaults.merge(options)

  #   string = ""
  #   options.each do |option, values|

  # end
end
