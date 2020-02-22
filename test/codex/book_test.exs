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
end
