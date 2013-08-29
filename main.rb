require_relative 'imdb.rb'

def new_list(number)
	list = GetTopMovies.new(number)
	list.get_top_movies
	puts "\nget movies by actors? (yes/no)"
	choice = gets.chomp

	while(choice.downcase == "yes")
		puts "Name?"
		name = gets.chomp
		list.get_movies_by_actor(name)
		puts "Again? (yes/no)"
		choice = gets.chomp
	end 
end

puts "Number of movies to be processed?(integer)"
number_of_movies = gets.chomp
new_list(number_of_movies.to_i)