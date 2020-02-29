defmodule Codex.BookTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Codex.Book

  setup_all do
    HTTPoison.start
  end

  describe "id from isbn" do
    test "returns a book's Goodreads id given its ISBN 13" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      use_cassette "book/id_from_isbn" do
        assert {:ok, id} = Book.id_from_isbn("9780553286526")

        assert id == "828165"
      end
    end

    test "returns a book's Goodreads id given its ISBN 9" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      use_cassette "book/id_from_isbn_9" do
        assert {:ok, id} = Book.id_from_isbn("0553286528")

        assert id == "828165"
      end
    end

    test "returns comma separated Goodreads ids for the different given ISBN codes" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      use_cassette "book/ids_from_isbn_list" do
        assert {:ok, id} = Book.id_from_isbn(["9780553286526", "9780385486804", "9780156628709"])

        assert id == "828165,1845,46132"
      end
    end

    test "returns the same list of Goodreads ids when the list of ISBN codes is passed as a string" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      use_cassette "book/ids_from_isbn_list" do
        assert {:ok, id} = Book.id_from_isbn("9780553286526,9780385486804,9780156628709")

        assert id == "828165,1845,46132"
      end
    end

    test "when API key is not present, redirects to the book's page" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      use_cassette "book/id_from_isbn_error" do
        assert {:ok, response} = Book.id_from_isbn("0553286528")

        assert response.status_code == 301
        assert response.body =~  ~r"You are being.*redirected"

        {"Location", redirect_url} = Enum.find(response.headers, fn {k, _v} -> k == "Location" end)

        assert redirect_url =~ "828165"
      end
    end
  end

  describe "id to work id" do
    test "returns an XML response containing the work id of a book given its Goodreads book id" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&?", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "book/id_to_work_id" do
        assert {:ok, data} = Book.id_to_work_id("828165")

        assert data =~ "<authentication>true</authentication>"
        assert data =~ "book_id_to_work_id"
        assert data =~ "<item>509736</item>"
      end
    end

    test "returns an XML response containing the Goodreads work ids for the different given book ids" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&?", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "book/id_to_work_id_list" do
        assert {:ok, data} = Book.id_to_work_id(["828165", "1845", "46132"])

        assert data =~ "<authentication>true</authentication>"
        assert data =~ "book_id_to_work_id"
        assert data =~ "<item>509736</item>"
        assert data =~ "<item>3284484</item>"
        assert data =~ "<item>841320</item>"
      end
    end

    test "returns an XML response containing the Goodreads work ids when passed ids in single string" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&?", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "book/id_to_work_id_list" do
        assert {:ok, data} = Book.id_to_work_id("828165,1845,46132")

        assert data =~ "<authentication>true</authentication>"
        assert data =~ "book_id_to_work_id"
        assert data =~ "<item>509736</item>"
        assert data =~ "<item>3284484</item>"
        assert data =~ "<item>841320</item>"
      end
    end

    test "returns 406 error when api key is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "book/id_to_work_id_error" do
        assert {:ok, response} = Book.id_to_work_id("828165")

        assert response.status_code == 406
        assert response.body == ""
      end
    end
  end

  describe "review statistics by ISBN" do
    test "gets review statistics for a single book" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      use_cassette "book/review_statistics_by_isbn" do
        assert {:ok, response} = Book.review_statistics_by_isbn("9780385486804")

        assert response =~ "\"isbn13\":\"9780385486804\""
        assert response =~ "\"id\":1845"
        assert response =~ "\"average_rating\":\"3.98\""
      end
    end

    test "gets review statistics for a list of books" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")

      use_cassette "book/multiple_review_statsitics_by_isbn" do
        assert {:ok, response} = Book.review_statistics_by_isbn(["9780385486804", "9780553286526"])

        assert response =~ "\"isbn13\":\"9780385486804\""
        assert response =~ "\"id\":1845"
        assert response =~ "\"average_rating\":\"3.98\""

        assert response =~ "\"isbn13\":\"9780553286526\""
        assert response =~ "\"id\":828165"
        assert response =~ "\"average_rating\":\"4.14\""
      end
    end
  end

  describe "reviews by book id" do
    test "gets an XML response with reviews for a book given its id" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&?", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "book/reviews_by_id" do
        assert {:ok, data} = Book.reviews_by_book_id("828165")

        assert data =~ "<authentication>true</authentication>"
        assert data =~ "<id>828165</id>"
        assert data =~ "<title>Education of a Wandering Man</title>"
      end
    end

    test "returns a JSON widget when specified the JSON format" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&?", "key=YOUR_API_KEY")
      use_cassette "book/json_reviews_by_id" do
        assert {:ok, data} = Book.reviews_by_book_id("828165", format: "json")

        assert data =~ "\"reviews_widget\":"
        assert data =~ "828165"
      end
    end

    test "returns 406 error when api key is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "book/reviews_by_id_error" do
        assert {:ok, response} = Book.reviews_by_book_id("828165")

        assert response.status_code == 401
        assert response.body =~ "Invalid API key"
      end
    end
  end
end
