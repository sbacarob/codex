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
end
