require_relative "../imdb.rb"


describe GetTopMovies do
	
	context "Invalid Argument passed" do
		describe "#get_top_movies" do
			it "ends when argument zero is passed" do
				get_movies = GetTopMovies.new(0)
				get_movies.should_not_receive(:get_top_n_movies_pages)
			end

			it "ends when argument >250 is passed" do
				get_movies = GetTopMovies.new(255)
				get_movies.should_not_receive(:get_top_n_movies_pages)
			end
		end
	end

	context "Request for Top 3(valid number of movies) movies" do
		
		before(:each) do
			@get_movies = GetTopMovies.new(3)
		end

		describe "#get_top_movies" do
			it "checks if all functions are called when accepted argument is passed" do
				@get_movies.should_receive(:get_top_n_movies_pages).and_call_original
				@get_movies.should_receive(:display_movies_with_cast)
				@get_movies.get_top_movies
			end
		end

		describe "#display_movies_with_cast" do
			it "checks if get_cast_movie is called appripriate number of times" do
				@get_movies.should_receive(:get_cast_movie).exactly(3).times.and_call_original
				hash = @get_movies.send(:get_top_n_movies_pages)
				@get_movies.send(:display_movies_with_cast, hash)
			end
		end

		describe "#get_top_n_movies_pages" do
			it "checks if get_page_source is called before creating hash and returns is file not present" do
				@get_movies.should_receive(:get_page_source).and_call_original
				Nokogiri::HTML::Document.any_instance.should_receive(:xpath).and_call_original
				@get_movies.send(:get_top_n_movies_pages)
			end

			it "checks if links are not empty and of movie titles" do
				hash = @get_movies.send(:get_top_n_movies_pages)
				hash.each do|key, link|
					hash[key].slice!"http://www.imdb.com"
					hash[key].match("/title/tt").should_not eql nil
				end
			end

			it "checks if hash is of correct size" do
				@get_movies.send(:get_top_n_movies_pages).length.should eql 3
			end
		end

		describe "#get_page_source" do
			it "gets HTML source when given valid html input" do
				page = @get_movies.send(:get_page_source, "IMDbTop250.html")
				page.should be_an_instance_of(Nokogiri::HTML::Document)
			end

			it "gets empty string when given invalid file" do
				page = @get_movies.send(:get_page_source,"abc.html")
				page.should eql ""
			end
		end

		describe "#get_cast_movie" do
			it "returns when link is invalid" do
				Nokogiri::HTML::Document.any_instance.should_not_receive(:xpath)
				@get_movies.send(:get_cast_movie, "Test_movie", "abcd.html")
			end

			it "checks if cast names are collected properly" do
				@get_movies.send(:get_cast_movie, "Test_movie", "sample.html").should eql ["Tim Robbins", "Morgan Freeman"]
			end

			it "checks if all internal functions are called" do
				@get_movies.should_receive(:get_page_source).with("sample.html").and_call_original
				Nokogiri::HTML::Document.any_instance.should_receive(:xpath).and_call_original
				@get_movies.should_receive(:add_movie_to_actor).twice.and_call_original
				@get_movies.send(:get_cast_movie, "Test_movie", "sample.html")
			end

		end

		describe "#add_movie_to_actor" do
			it "checks if hash is created and appended" do
				@get_movies.send(:add_movie_to_actor, "Test_actor", "Test_movie")
				@get_movies.actor_involved_in["Test_actor"].should eql ["Test_movie"]
				@get_movies.send(:add_movie_to_actor, "Test_actor", "Test_movie2")
				@get_movies.actor_involved_in["Test_actor"].should eql ["Test_movie", "Test_movie2"]
			end
		end

		describe "#get_movies_by_actor" do
			it "checks when no movies found" do
				output = capture_stdout { @get_movies.get_movies_by_actor("actor") }
				output.strip.should == "Name : actor\nNo Movies Found"
			end

			it "checks output when movies present" do
				@get_movies.send(:add_movie_to_actor, "actor", "Test_movie")
				@get_movies.send(:add_movie_to_actor, "actor", "Test_movie2")
				output = capture_stdout { @get_movies.get_movies_by_actor("actor") }
				output.strip.should == "Name : actor\nMovies : Test_movie, Test_movie2"
			end
		end
	end
end


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