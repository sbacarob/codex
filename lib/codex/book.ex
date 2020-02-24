defmodule Codex.Book do
  @moduledoc """
  Contains functions to access Goodreads' API endpoints related to books
  """

  alias Codex.HttpClient

  @doc """
  Get a book's Goodreads id given its ISBN

  ## Args:

  * `isbn` - The ISBN of the book. Can be ISBN 9 or 13. You may also pass a list of ISBNs in two
  different ways. The first one is to pass the ISBNs in a simple string, separated by commas; and
  the other one is to pass a List with the different ISBNs.

  ## Examples:

      iex> Codex.Book.id_from_isbn("9780553286526")
      {:ok, "828165"}

      iex> Codex.Book.id_from_isbn(["9780553286526", "9780385486804", "9780156628709"])
      {:ok, "828165,1845,46132"}

      iex> Codex.Book.id_from_isbn("9780553286526,9780385486804,9780156628709")
      {:ok, "828165,1845,46132"}
  """
  def id_from_isbn(isbn) when is_binary(isbn) do
    endpoint = "book/isbn_to_id"

    HttpClient.get(endpoint, [], params: %{"isbn" => isbn})
  end

  def id_from_isbn(isbn) when is_list(isbn) do
    endpoint = "book/isbn_to_id"

    HttpClient.get(endpoint, [], params: %{"isbn" => Enum.join(isbn, ",")})
  end

  @doc """
  Get a book's Goodreads work id given its Goodreads book id

  ## Args:

  * `id` - The Goodreads id of the book. You may also pass a list of book ids as a List or in a
  single string, separated by commas.

  ## Examples:

      iex> Codex.Book.id_to_work_id("828165")
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[book_id_to_work_id]]></method>\n  </Request>\n  <work-ids>\n    <item>509736</item>\n</work-ids>\n\n</GoodreadsResponse>"}

      iex> Codex.Book.id_to_work_id(["828165", "1845", "46132"])
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[book_id_to_work_id]]></method>\n  </Request>\n  <work-ids>\n    <item>509736</item>\n    <item>3284484</item>\n    <item>841320</item>\n</work-ids>\n\n</GoodreadsResponse>"}

      iex> Codex.Book.id_to_work_id("828165,1845,46132")
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[book_id_to_work_id]]></method>\n  </Request>\n  <work-ids>\n    <item>509736</item>\n    <item>3284484</item>\n    <item>841320</item>\n</work-ids>\n\n</GoodreadsResponse>"}
  """
  def id_to_work_id(book_id) when is_binary(book_id) do
    HttpClient.get("book/id_to_work_id/#{book_id}")
  end

  def id_to_work_id(book_id) when is_list(book_id) do
    HttpClient.get("book/id_to_work_id/#{Enum.join(book_id, ",")}")
  end

  @doc """
  Gets review statistics given an ISBN or a list of ISBNs. Up to 1000 per request

  ## Args:

  * `isbn` - an ISBN or list of ISBNs to get review statistics for.

  ## Examples:

      iex> Codex.Book.review_statistics_by_isbn("9783730601631")
      {:ok, "{\"books\":[{\"id\":25408685,\"isbn\":\"3730601636\",\"isbn13\":\"9783730601631\",\"ratings_count\":8,\"reviews_count\":1,\"text_reviews_count\":3,\"work_ratings_count\":52104,\"work_reviews_count\":116539,\"work_text_reviews_count\":3334,\"average_rating\":\"3.87\"}]}"}

      iex> Codex.Book.review_statistics_by_isbn(["9783730601631", "9780553213881"])
      {:ok, "{\"books\":[{\"id\":25408685,\"isbn\":\"3730601636\",\"isbn13\":\"9783730601631\",\"ratings_count\":8,\"reviews_count\":1,\"text_reviews_count\":3,\"work_ratings_count\":52104,\"work_reviews_count\":116539,\"work_text_reviews_count\":3334,\"average_rating\":\"3.87\"},{\"id\":123847,\"isbn\":\"0553213881\",\"isbn13\":\"9780553213881\",\"ratings_count\":248,\"reviews_count\":693,\"text_reviews_count\":13,\"work_ratings_count\":271,\"work_reviews_count\":800,\"work_text_reviews_count\":16,\"average_rating\":\"4.06\"}]}"}
  """
  def review_statistics_by_isbn(isbn) when is_binary(isbn) do
    endpoint = "book/review_counts.json"

    HttpClient.get(endpoint, [], params: %{"isbns" => isbn, "format" => "json"})
  end

  def review_statistics_by_isbn(isbn) when is_list(isbn) do
    endpoint = "book/review_counts.json"

    HttpClient.get(endpoint, [], params: %{"isbns" => Enum.join(isbn, ","), "format" => "json"})
  end
end
