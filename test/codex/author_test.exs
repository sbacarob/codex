defmodule Codex.AuthorTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Codex.Author

  setup_all do
    HTTPoison.start
  end

  describe "paginate books" do
    test "retrieves a list of books when api key is set up" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/paginate_books" do
        assert {:ok, books_data} = Author.paginate_books(84825, 1)

        assert books_data =~ "<authentication>true</authentication>"
        assert books_data =~ "<name>Jorge Franco</name>"
        assert books_data =~ "<id>84825</id>"
      end
    end

    test "yields the same results when page is not specified" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/paginate_books" do
        assert {:ok, books_data} = Author.paginate_books(84825)

        assert books_data =~ "<authentication>true</authentication>"
        assert books_data =~ "<name>Jorge Franco</name>"
        assert books_data =~ "<id>84825</id>"
      end
    end

    test "returns 401 error when config is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/paginate_books_error" do
        assert {:ok, response} = Author.paginate_books(84825)

        assert response.status_code == 401
        assert response.body =~ "Invalid API key"
      end
    end
  end

  describe "info by id" do
    test "retrieves info about an author given the author id" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/get_info_by_id" do
        assert {:ok, author_data} = Author.info_by_id(84825)

        assert author_data =~ "<authentication>true</authentication>"
        assert author_data =~ "<name>Jorge Franco</name>"
        assert author_data =~ "<id>84825</id>"
        assert author_data =~ "<books>"
        assert author_data =~ "Premio Alfaguara 2014"
        assert author_data =~ "born in Colombia"
      end
    end

    test "returns 401 error when config is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/get_info_by_id_error" do
        assert {:ok, response} = Author.info_by_id(84825)

        assert response.status_code == 401
        assert response.body =~ "Invalid API key"
      end
    end
  end

  describe "find by name" do
    test "retrieves info about an author given a name for the author" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/find_by_name" do
        assert {:ok, author_data} = Author.find_by_name("Jorge Franco")

        assert author_data =~ "<authentication>true</authentication>"
        assert author_data =~ "Jorge Franco"
        assert author_data =~ "<author id=\"84825\">"
      end
    end

    test "returns 401 error when config is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/find_by_name_error" do
        assert {:ok, response} = Author.find_by_name("Jorge Franco")

        assert response.status_code == 401
        assert response.body =~ "Invalid API key"
      end
    end
  end

  describe "list series" do
    test "retrieves a list of series of an author" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/list_series" do
        assert {:ok, author_data} = Author.list_series(1077326)

        assert author_data =~ "<authentication>true</authentication>"
        assert author_data =~ "Fantastic Beasts"
        assert author_data =~ "Harry Potter"
      end
    end

    test "returns 401 error when config is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/list_series_error" do
        assert {:ok, response} = Author.list_series(1077326)

        assert response.status_code == 401
        assert response.body =~ "Invalid API key"
      end
    end
  end
end
