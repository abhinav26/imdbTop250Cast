require_relative 'imdb.rb'

def new_list(num)
	list = GetTopMovies.new(num)
	list.get_top_movies
	puts "\nget movies by actors? (yes/no)"
	str = gets.chomp

	while(str.downcase == "yes")
		puts "Name?"
		name = gets.chomp
		list.get_movies_by_actor(name)
		puts "Again? (yes/no)"
		str = gets.chomp
	end 
end

puts "Number of movies to be processed?"
num = gets.chomp
new_list(num.to_i)