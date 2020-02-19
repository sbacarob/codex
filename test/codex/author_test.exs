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

    test "fails when config is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "author/paginate_books_error" do
        assert {:ok, response} = Author.paginate_books(84825)

        assert response.status_code == 401
        assert response.body =~ "Invalid API key"
      end
    end
  end
end
