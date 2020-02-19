defmodule Codex.Author do
  @moduledoc """
  contains functions to access Goodreads' API endpoints related to authors
  """

  alias Codex.HttpClient

  @doc """
  Paginate an author's books. Calls Goodreads' `/author/list.xml` endpoint.

  ## Args:

  * `author_id` - The Goodreads id of the author.
  * `page` - (optional) the number of the page of results to retrieve. Defaults to `1`.

  ## Examples:

      iex> Codex.Author.paginate_books(8425, 1)
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[author_list]]></method>\n  </Request>\n  <author>\n  <id>84825</id>\n  <name>Jorge Franco</name>\n  <link><![CDATA[https://www.goodreads.com/author/show/84825.Jorge_Franco]]></link>\n  <books start=\"1\" end=\"23\" total=\"23\">\n    <book>\n  <id type=\"integer\">171327</id>\n  <isbn>1583226125</isbn>\n  <isbn13>9781583226124</isbn13>\n  <text_reviews_count type=\"integer\">123</text_reviews_count>\n  <uri>kca://book/amzn1.gr.book.v1.ngRyFV31gzi2cERCSkT7mA</uri>\n  <title>Rosario Tijeras</title>\n  <title_without_series>Rosario Tijeras</title_without_series>\n  <image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320484864l/171327._SX98_.jpg</image_url>\n  <small_image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320484864l/171327._SX50_.jpg</small_image_url>\n  <large_image_url/>\n  <link>https://www.goodreads.com/book/show/171327.Rosario_Tijeras</link>\n  <num_pages>176</num_pages>\n  <format>Paperback</format>\n  <edition_information/>\n  <publisher>Siete Cuentos</publisher>\n  <publication_day>6</publication_day>\n  <publication_year>2004</publication_year>\n  <publication_month>1</publication_month>\n  <average_rating>3.87</average_rating>\n  <ratings_count>2122</ratings_count>\n  <description>\"Como a Rosario le pegaron un tiro a quemarropa mientras le daban un beso, confundió el dolor del amor con el de la muerte\". Rosario Tijeras es el violento y violado personaje al centro de este estudio de contrastes ambientado en la Medellín autodestructiva de los años '80. Su mismo nombre -simbólico y contradictorio a la vez- sugiere el conflicto que vive como mujer que se 'convierte' al sicariato para aislarse de la violencia aterradora de las calles. Desde los pasillos del hospital donde Rosario está luchando por su vida, Antonio, el narrador, espera saber si sobrevivirá. A través de él reconstruimos la amistad entre los dos, su historia de amor con Emilio y su vida como sicaria.&lt;br /&gt;Rosario Tijeras es una obra que pertenece al estudio socio-realista Latinoamericano. Es una obra cuya prosa se revela en toda su vitalidad y vena poética.</description>\n<authors>\n<author>\n<id>84825</id>\n<name>Jorge Franco</name>\n<role></role>\n<image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1541629332p5/84825.jpg]]>\n</image_url>\n<small_image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1541629332p2/84825.jpg]]>\n</small_image_url>\n<link><![CDATA[https://www.goodreads.com/author/show/84825.Jorge_Franco]]></link>\n<average_rating>3.79</average_rating>\n<ratings_count>4201</ratings_count>\n<text_reviews_count>424</text_reviews_count>\n</author>\n</authors>\n  <published>2004</published>\n<work>  <id>165444</id>\n  <uri>kca://work/amzn1.gr.work.v1.CjNnS5EDorvc9wRF-TOerA</uri>\n</work></book>\n\n    <book>\n  <id type=\"integer\">21562844</id>\n  <isbn>1622639405</isbn>\n  <isbn13>9781622639403</isbn13>\n  <text_reviews_count type=\"integer\">129</text_reviews_count>\n  <uri>kca://book/amzn1.gr.book.v1.jinMskCOdtFRCXp8WlrrYA</uri>\n  <title>El mundo de afuera</title>\n  <title_without_series>El mundo de afuera</title_without_series>\n  <image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1398035667l/21562844._SY160_.jpg</image_url>\n  <small_image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1398035667l/21562844._SY75_.jpg</small_image_url>\n  <large_image_url/>\n  <link>https://www.goodreads.com/book/show/21562844-el-mundo-de-afuera</link>\n  <num_pages>303</num_pages>\n  <format>Paperback</format>\n  <edition_information/>\n  <publisher>Alfaguara</publisher>\n  <publication_day>1</publication_day>\n  <publication_year>2014</publication_year>\n  <publication_month>9</publication_month>\n  <average_rating>3.62</average_rating>\n  <ratings_count>1002</ratings_count>\n  <description>&lt;i&gt;El mundo de afuera&lt;/i&gt; transcurre en Medellín. Allí, el tiempo viene envuelto " <> ...}
  """
  def paginate_books(author_id, page \\ 1) do
    endpoint = "author/list.xml"

    HttpClient.get(endpoint, [], params: %{"id" => author_id, "page" => page})
  end
end
