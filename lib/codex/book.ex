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
end
