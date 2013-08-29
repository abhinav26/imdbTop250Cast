require 'rubygems'
require 'nokogiri'
require 'open-uri'
   
class GetTopMovies
	attr_accessor :actor_involved_in

	TOP_250_LINK = "IMDbTop250.html"#"http://imdb.org/chart/top"

	def initialize(number)
		@number = number
		@actor_involved_in = Hash.new { |hash, key| hash[key] =[] }
	end

	def get_top_movies
		if @number<1
			puts "No Movies Selected"
			return
		elsif @number>250
			puts "Too many Movies Selected"
			return
		end
		hash = get_top_n_movies_pages
		display_movies_with_cast(hash)
	end

	def display_movies_with_cast(hash)
		hash.each do |movie_name, link|
			puts "\n" + movie_name
			cast_names = get_cast_movie(movie_name, link)
			puts "Cast : " + cast_names.join(", ")
		end
	end

	def get_top_n_movies_pages
		page = get_page_source(TOP_250_LINK)
		return if page == ""
		hash = {}
		list_of_links = page.xpath("//table[2]").css('a')
		@number.times do |counter|
			hash[list_of_links[counter].text] = "http://www.imdb.com" + list_of_links[counter][:href]
		end
		hash
	end

	def get_cast_movie(movie_name, link)
		movie_page = get_page_source(link)
		return if movie_page == ""
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
			Nokogiri::HTML(open(link))  
		rescue
			""
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

	private :get_page_source , :add_movie_to_actor, :get_cast_movie, :get_top_n_movies_pages, :display_movies_with_cast

end


