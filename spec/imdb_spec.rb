require_relative "../imdb.rb"

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

describe GetTopMovies do
	
	context "Invalid Argument passed" do
		describe "#get_top_movies"
			it "ends when argument zero is passed" do
				get_movies = GetTopMovies.new(0)
				get_movies.get_top_movies.should eql "No Movies Selected" 
			end

			it "ends when argument >250 is passed" do
				@get_movies = GetTopMovies.new(255)
				@get_movies.get_top_movies.should eql "Too many Movies Selected" 
			end
		end
	end

	context "Top 3 movies" do
		
		before(:each) do
			@get_movies = GetTopMovies.new(3)
		end

		describe "#get_top_n_movies_pages" do
			it "checks if hash is of correct size" do
				page = @get_movies.get_page_source("IMDbTop250.html")
				hash = @get_movies.get_top_n_movies_pages(page)
				hash.length.should eql 3
			end

			it "gets empty string when given invalid file" do
				page = @get_movies.get_page_source("abc.html")
				page.should eql ""
			end
		end

		describe "#get_page_source" do
			it "gets HTML source when given valid html input" do
				page = @get_movies.get_page_source("IMDbTop250.html")
				page.class.should eql Nokogiri::HTML::Document
			end

			it "gets empty string when given invalid file" do
				page = @get_movies.get_page_source("abc.html")
				page.should eql ""
			end
		end

		describe "#get_cast_movie" do

			it "checks if cast names are collected properly" do
				@get_movies.get_cast_movie("Test_movie", "sample.html").should eql ["Tim Robbins", "Morgan Freeman"]
			end
		end

		describe "#add_movie_to_actor" do
			it "checks if hash is created and appended" do
				@get_movies.add_movie_to_actor("Test_actor", "Test_movie")
				@get_movies.actor_involved_in["Test_actor"].should eql ["Test_movie"]
				@get_movies.add_movie_to_actor("Test_actor", "Test_movie2")
				@get_movies.actor_involved_in["Test_actor"].should eql ["Test_movie", "Test_movie2"]
			end
		end

		describe "#get_movies_by_actor" do

			it "checks when no movies found" do
				output = capture_stdout { @get_movies.get_movies_by_actor("actor") }
				output.strip.should == "Name : actor\nNo Movies Found"
			end

			it "checks output when movies present" do
				@get_movies.add_movie_to_actor("actor", "Test_movie")
				@get_movies.add_movie_to_actor("actor", "Test_movie2")
				output = capture_stdout { @get_movies.get_movies_by_actor("actor") }
				output.strip.should == "Name : actor\nMovies : Test_movie, Test_movie2"
			end
		end
	end
end
