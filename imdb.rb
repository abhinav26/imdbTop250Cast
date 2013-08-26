require 'rubygems'
require 'nokogiri'
require 'open-uri'
   
class GetTopMovies
	attr_accessor :actor_involved_in

	TOP_250_LINK = "IMDbTop250.html"#"http://imdb.org/chart/top"

	def initialize(number)
		@number = number
		@actor_involved_in = Hash.new { |hash, key| hash[key] =[]  }
	end

	def get_top_movies
		str = "No Movies Selected" if @number<1 
		str = "Too many Movies Selected" if @number>250
		
		if str
			puts str 
			return str
		end

		page = get_page_source(TOP_250_LINK)
		hash = get_top_n_movies_pages(page)

		hash.each do |movie_name, link|
			puts "\n" + movie_name
			cast_names = get_cast_movie(movie_name, link)
			puts "Cast : " + cast_names.join(", ")
		end

	end

	def get_top_n_movies_pages(page)
		hash = {}

		counter=1
		table = page.xpath("//table[2]")
		puts table.class
		table.css('a').each do |link|
			hash[link.text] = "http://www.imdb.com" + link[:href]
			counter += 1
			break if counter>@number
		end

		hash
	end

	def get_cast_movie(movie_name, link)
		movie_page = get_page_source(link)
		return if movie_page == ""
		counter = 1
		cast_names = []

		table = movie_page.xpath("//table[@class=\"cast_list\"]")

		table.css('tr td[2]').each do |name|
			cast_names << name.text.strip
			add_movie_to_actor(name.text.strip, movie_name)
		end
		
		cast_names
	end

	def add_movie_to_actor(actor_name, movie_name)
		@actor_involved_in[actor_name] << movie_name
	end

	def get_page_source(link)
		begin
			page = Nokogiri::HTML(open(link))  
		rescue
			return ""
		end
	end

	def get_movies_by_actor(name)
		puts "\nName : #{name}"
		if @actor_involved_in[name] == []
			puts "No Movies Found"
		else
			puts "Movies : " + @actor_involved_in[name].join(", ")
		end
	end
end


