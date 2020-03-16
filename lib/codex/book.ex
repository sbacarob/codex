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

  @doc """
  Get the reviews of a book given its Goodreads book id.

  ## Args:

  * `book_id` - The book's Goodreads id.
  * `opts` - A Keyword List with options.

  ## Opts:

  * `:format` - The format to get the response in. Accepts "xml" | "json". Defaults to XML. If JSON
  is specified, it will contain a JSON response with the unique key "reviews_widget", and the value
  will be HTML code for a widget containing the book reviews.
  * `:text_only` - If true, only shows reviews that have text. Defaults to false.
  * `:rating` - Shows only reviews with a particular rating

  ## Examples:

      iex> Codex.Book.reviews_by_book_id(828165)
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[book_show]]></method>\n  </Request>\n  <book>\n  <id>828165</id>\n  <title>Education of a Wandering Man</title>\n  <isbn><![CDATA[0553286528]]></isbn>\n  <isbn13><![CDATA[9780553286526]]></isbn13>\n  <asin><![CDATA[]]></asin>\n  <kindle_asin><![CDATA[]]></kindle_asin>\n  <marketplace_id><![CDATA[]]></marketplace_id>\n  <country_code><![CDATA[ES]]></country_code>\n  <image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320462831l/828165._SY160_.jpg</image_url>\n  <small_image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320462831l/828165._SY75_.jpg</small_image_url>\n  <publication_year>1990</publication_year>\n  <publication_month>11</publication_month>\n  <publication_day>1</publication_day>\n  <publisher>Bantam</publisher>\n  <language_code></language_code>\n  <is_ebook>false</is_ebook>\n  <description><![CDATA[From his decision to leave school at fifteen to roam the world, to his recollections of life as a hobo on the Southern Pacific Railroad, as a cattle skinner in Texas, as a merchant seaman in Singapore and the West Indies, and as an itinerant bare-knuckled prizefighter across small-town America, here is Louis L'Amour's memoir of his lifelong love affair with learning--from books, from yondering, and from some remarkable men and women--that shaped him as a storyteller and as a man. Like classic L'Amour fiction, <i>Education of a Wandering Man</i> mixes authentic frontier drama--such as the author's desperate efforts to survive a sudden two-day trek across the blazing Mojave desert--with true-life characters like Shanghai waterfront toughs, desert prospectors, and cowboys whom Louis L'Amour met while traveling the globe. At last, in his own words, this is a story of a one-of-a-kind life lived to the fullest . . . a life that inspired the books that will forever enable us to relive our glorious frontier heritage.]]></description>\n  <work>\n  <id type=\"integer\">509736</id>\n  <books_count type=\"integer\">17</books_count>\n  <best_book_id type=\"integer\">828165</best_book_id>\n  <reviews_count type=\"integer\">7271</reviews_count>\n  <ratings_sum type=\"integer\">12259</ratings_sum>\n  <ratings_count type=\"integer\">2959</ratings_count>\n  <text_reviews_count type=\"integer\">365</text_reviews_count>\n  <original_publication_year type=\"integer\">1989</original_publication_year>\n  <original_publication_month type=\"integer\">1</original_publication_month>\n  <original_publication_day type=\"integer\">1</original_publication_day>\n  <original_title>Education of a Wandering Man</original_title>\n  <original_language_id type=\"integer\" nil=\"true\"/>\n  <media_type>book</media_type>\n  <rating_dist>5:1239|4:1077|3:494|2:125|1:24|total:2959</rating_dist>\n  <desc_user_id type=\"integer\">-50</desc_user_id>\n  <default_chaptering_book_id type=\"integer\" nil=\"true\"/>\n  <default_description_language_code nil=\"true\"/>\n  <work_uri>kca://work/amzn1.gr.work.v1.skfzVgkFsmD7COAJrPLUwA</work_uri>\n</work>\n  <average_rating>4.14</average_rating>\n  <num_pages><![CDATA[272]]></num_pages>\n  <format><![CDATA[Paperback]]></format>\n  <edition_information><![CDATA[]]></edition_information>\n  <ratings_count><![CDATA[2646]]></ratings_count>\n  <text_reviews_count><![CDATA[317]]></text_reviews_count>\n  <url><![CDATA[https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man]]></url>\n  <link><![CDATA[https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man]]></link>\n  <authors>\n<author>\n<id>858</id>\n<name>Louis L&apos;Amour</name>\n<role></role>\n<image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1343675199p5/858.jpg]]>\n</image_url>\n<small_image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1343675199p2/858.jpg]]>\n</small_image_url>\n<link><![CDATA[https://www.goodreads.com/author/show/858.Louis_L_Amour]]></link>\n<average_rating>4.04</average_rating>\n<ratings_count>322534</ratings_count>\n<tex" <> ...}

      iex> Codex.Book.reviews_by_book_id(828165, format: "json")
      {:ok, "{\"reviews_widget\":\"\\u003cstyle\\u003e\\n  #goodreads-widget {\\n    font-family: georgia, serif;\\n    padding: 18px 0;\\n    width:565px;\\n  }\\n  #goodreads-widget h1 {\\n    font-weight:normal;\\n    font-size: 16px;\\n    border-bottom: 1px solid #BBB596;\\n    margin-bottom: 0;\\n  }\\n  #goodreads-widget a {\\n    text-decoration: none;\\n    color:#660;\\n  }\\n  iframe{\\n    background-color: #fff;\\n  }\\n  #goodreads-widget a:hover { text-decoration: underline; }\\n  #goodreads-widget a:active {\\n    color:#660;\\n  }\\n  #gr_footer {\\n    width: 100%;\\n    border-top: 1px solid #BBB596;\\n    text-align: right;\\n  }\\n  #goodreads-widget .gr_branding{\\n    color: #382110;\\n    font-size: 11px;\\n    text-decoration: none;\\n    font-family: \\\"Helvetica Neue\\\", Helvetica, Arial, sans-serif;\\n  }\\n\\u003c/style\\u003e\\n\\u003cdiv id=\\\"goodreads-widget\\\"\\u003e\\n  \\u003cdiv id=\\\"gr_header\\\"\\u003e\\u003ch1\\u003e\\u003ca rel=\\\"nofollow\\\" href=\\\"https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man\\\"\\u003eEducation of a Wandering Man Reviews\\u003c/a\\u003e\\u003c/h1\\u003e\\u003c/div\\u003e\\n  \\u003ciframe id=\\\"the_iframe\\\" src=\\\"https://www.goodreads.com/api/reviews_widget_iframe?did=DEVELOPER_ID\\u0026amp;format=html\\u0026amp;isbn=0553286528\\u0026amp;links=660\\u0026amp;review_back=fff\\u0026amp;stars=000\\u0026amp;text=000\\\" width=\\\"565\\\" height=\\\"400\\\" frameborder=\\\"0\\\"\\u003e\\u003c/iframe\\u003e\\n  \\u003cdiv id=\\\"gr_footer\\\"\\u003e\\n    \\u003ca class=\\\"gr_branding\\\" target=\\\"_blank\\\" rel=\\\"nofollow noopener noreferrer\\\" href=\\\"https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man?utm_medium=api\\u0026amp;utm_source=reviews_widget\\\"\\u003eReviews from Goodreads.com\\u003c/a\\u003e\\n  \\u003c/div\\u003e\\n\\u003c/div\\u003e\\n\"}"}
  """
  def reviews_by_book_id(book_id, opts \\ []) do
    format = parse_format(Keyword.get(opts, :format, "xml"))
    endpoint = "book/show/#{book_id}.xml"

    params =
      %{
        "format" => format,
        "text_only" => Keyword.get(opts, :text_only),
        "rating" => Keyword.get(opts, :rating)
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    HttpClient.get(endpoint, [], params: params)
  end

  @doc """
  Get the reviews of a book given its ISBN.

  ## Args:

  * `isbn` - The book's ISBN.
  * `opts` - A Keyword List with options.

  ## Opts:

  * `:format` - The format to get the response in. Accepts "xml" | "json". Defaults to XML. If JSON
  is specified, it will contain a JSON response with the unique key "reviews_widget", and the value
  will be HTML code for a widget containing the book reviews.
  * `:user_id` - Required for JSON.
  * `:callback` - You can pass the name of a javascript function to wrap around the JSON result.
  * `:rating` - Shows only reviews with a particular rating

  ## Examples:

      iex> Codex.Book.reviews_by_isbn("0553286528")
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[book_isbn]]></method>\n  </Request>\n  <book>\n  <id>828165</id>\n  <title>Education of a Wandering Man</title>\n  <isbn><![CDATA[0553286528]]></isbn>\n  <isbn13><![CDATA[9780553286526]]></isbn13>\n  <asin><![CDATA[]]></asin>\n  <kindle_asin><![CDATA[]]></kindle_asin>\n  <marketplace_id><![CDATA[]]></marketplace_id>\n  <country_code><![CDATA[ES]]></country_code>\n  <image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320462831l/828165._SY160_.jpg</image_url>\n  <small_image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320462831l/828165._SY75_.jpg</small_image_url>\n  <publication_year>1990</publication_year>\n  <publication_month>11</publication_month>\n  <publication_day>1</publication_day>\n  <publisher>Bantam</publisher>\n  <language_code></language_code>\n  <is_ebook>false</is_ebook>\n  <description><![CDATA[From his decision to leave school at fifteen to roam the world, to his recollections of life as a hobo on the Southern Pacific Railroad, as a cattle skinner in Texas, as a merchant seaman in Singapore and the West Indies, and as an itinerant bare-knuckled prizefighter across small-town America, here is Louis L'Amour's memoir of his lifelong love affair with learning--from books, from yondering, and from some remarkable men and women--that shaped him as a storyteller and as a man. Like classic L'Amour fiction, <i>Education of a Wandering Man</i> mixes authentic frontier drama--such as the author's desperate efforts to survive a sudden two-day trek across the blazing Mojave desert--with true-life characters like Shanghai waterfront toughs, desert prospectors, and cowboys whom Louis L'Amour met while traveling the globe. At last, in his own words, this is a story of a one-of-a-kind life lived to the fullest . . . a life that inspired the books that will forever enable us to relive our glorious frontier heritage.]]></description>\n  <work>\n  <id type=\"integer\">509736</id>\n  <books_count type=\"integer\">17</books_count>\n  <best_book_id type=\"integer\">828165</best_book_id>\n  <reviews_count type=\"integer\">7271</reviews_count>\n  <ratings_sum type=\"integer\">12259</ratings_sum>\n  <ratings_count type=\"integer\">2959</ratings_count>\n  <text_reviews_count type=\"integer\">365</text_reviews_count>\n  <original_publication_year type=\"integer\">1989</original_publication_year>\n  <original_publication_month type=\"integer\">1</original_publication_month>\n  <original_publication_day type=\"integer\">1</original_publication_day>\n  <original_title>Education of a Wandering Man</original_title>\n  <original_language_id type=\"integer\" nil=\"true\"/>\n  <media_type>book</media_type>\n  <rating_dist>5:1239|4:1077|3:494|2:125|1:24|total:2959</rating_dist>\n  <desc_user_id type=\"integer\">-50</desc_user_id>\n  <default_chaptering_book_id type=\"integer\" nil=\"true\"/>\n  <default_description_language_code nil=\"true\"/>\n  <work_uri>kca://work/amzn1.gr.work.v1.skfzVgkFsmD7COAJrPLUwA</work_uri>\n</work>\n  <average_rating>4.14</average_rating>\n  <num_pages><![CDATA[272]]></num_pages>\n  <format><![CDATA[Paperback]]></format>\n  <edition_information><![CDATA[]]></edition_information>\n  <ratings_count><![CDATA[2646]]></ratings_count>\n  <text_reviews_count><![CDATA[317]]></text_reviews_count>\n  <url><![CDATA[https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man]]></url>\n  <link><![CDATA[https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man]]></link>\n  <authors>\n<author>\n<id>858</id>\n<name>Louis L&apos;Amour</name>\n<role></role>\n<image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1343675199p5/858.jpg]]>\n</image_url>\n<small_image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1343675199p2/858.jpg]]>\n</small_image_url>\n<link><![CDATA[https://www.goodreads.com/author/show/858.Louis_L_Amour]]></link>\n<average_rating>4.04</average_rating>\n<ratings_count>322538</ratings_count>\n<tex" <> ...}

      iex> Codex.Book.reviews_by_isbn("0553286528", format: "json")
      {:ok, "{\"reviews_widget\":\"\\u003cstyle\\u003e\\n  #goodreads-widget {\\n    font-family: georgia, serif;\\n    padding: 18px 0;\\n    width:565px;\\n  }\\n  #goodreads-widget h1 {\\n    font-weight:normal;\\n    font-size: 16px;\\n    border-bottom: 1px solid #BBB596;\\n    margin-bottom: 0;\\n  }\\n  #goodreads-widget a {\\n    text-decoration: none;\\n    color:#660;\\n  }\\n  iframe{\\n    background-color: #fff;\\n  }\\n  #goodreads-widget a:hover { text-decoration: underline; }\\n  #goodreads-widget a:active {\\n    color:#660;\\n  }\\n  #gr_footer {\\n    width: 100%;\\n    border-top: 1px solid #BBB596;\\n    text-align: right;\\n  }\\n  #goodreads-widget .gr_branding{\\n    color: #382110;\\n    font-size: 11px;\\n    text-decoration: none;\\n    font-family: \\\"Helvetica Neue\\\", Helvetica, Arial, sans-serif;\\n  }\\n\\u003c/style\\u003e\\n\\u003cdiv id=\\\"goodreads-widget\\\"\\u003e\\n  \\u003cdiv id=\\\"gr_header\\\"\\u003e\\u003ch1\\u003e\\u003ca rel=\\\"nofollow\\\" href=\\\"https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man\\\"\\u003eEducation of a Wandering Man Reviews\\u003c/a\\u003e\\u003c/h1\\u003e\\u003c/div\\u003e\\n  \\u003ciframe id=\\\"the_iframe\\\" src=\\\"https://www.goodreads.com/api/reviews_widget_iframe?did=DEVELOPER_ID\\u0026amp;format=html\\u0026amp;isbn=0553286528\\u0026amp;links=660\\u0026amp;review_back=fff\\u0026amp;stars=000\\u0026amp;text=000\\\" width=\\\"565\\\" height=\\\"400\\\" frameborder=\\\"0\\\"\\u003e\\u003c/iframe\\u003e\\n  \\u003cdiv id=\\\"gr_footer\\\"\\u003e\\n    \\u003ca class=\\\"gr_branding\\\" target=\\\"_blank\\\" rel=\\\"nofollow noopener noreferrer\\\" href=\\\"https://www.goodreads.com/book/show/828165.Education_of_a_Wandering_Man?utm_medium=api\\u0026amp;utm_source=reviews_widget\\\"\\u003eReviews from Goodreads.com\\u003c/a\\u003e\\n  \\u003c/div\\u003e\\n\\u003c/div\\u003e\\n\"}"}
  """
  def reviews_by_isbn(isbn, opts \\ []) do
    format = parse_format(Keyword.get(opts, :format, "xml"))
    endpoint = "book/isbn/#{isbn}"

    params =
      %{
        "format" => format,
        "rating" => Keyword.get(opts, :rating),
        "user_id" => Keyword.get(opts, :user_id),
        "callback" => Keyword.get(opts, :callback)
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    HttpClient.get(endpoint, [], params: params)
  end

  @doc """
  Get the reviews of a book given a title string.

  ## Args:

  * `title` - The string to use to search for the book's reviews.
  * `opts` - A Keyword List with options.

  ## Opts:

  * `:author` - a string with the author's name. Useful for filtering out results.
  * `:rating` - Shows only reviews with a particular rating

  > Goodread's API's documentation says it allows `format` but the JSON option doesn't seem to work.

  ## Examples:

      iex> Codex.Book.reviews_by_title_string("Rosario Tijeras")
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[book_title]]></method>\n  </Request>\n  <book>\n  <id>171327</id>\n  <title>Rosario Tijeras</title>\n  <isbn><![CDATA[1583226125]]></isbn>\n  <isbn13><![CDATA[9781583226124]]></isbn13>\n  <asin><![CDATA[]]></asin>\n  <kindle_asin><![CDATA[]]></kindle_asin>\n  <marketplace_id><![CDATA[]]></marketplace_id>\n  <country_code><![CDATA[ES]]></country_code>\n  <image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320484864l/171327._SX98_.jpg</image_url>\n  <small_image_url>https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1320484864l/171327._SX50_.jpg</small_image_url>\n  <publication_year>2004</publication_year>\n  <publication_month>1</publication_month>\n  <publication_day>6</publication_day>\n  <publisher>Siete Cuentos</publisher>\n  <language_code></language_code>\n  <is_ebook>false</is_ebook>\n  <description><![CDATA[\"Como a Rosario le pegaron un tiro a quemarropa mientras le daban un beso, confundió el dolor del amor con el de la muerte\". Rosario Tijeras es el violento y violado personaje al centro de este estudio de contrastes ambientado en la Medellín autodestructiva de los años '80. Su mismo nombre -simbólico y contradictorio a la vez- sugiere el conflicto que vive como mujer que se 'convierte' al sicariato para aislarse de la violencia aterradora de las calles. Desde los pasillos del hospital donde Rosario está luchando por su vida, Antonio, el narrador, espera saber si sobrevivirá. A través de él reconstruimos la amistad entre los dos, su historia de amor con Emilio y su vida como sicaria.<br />Rosario Tijeras es una obra que pertenece al estudio socio-realista Latinoamericano. Es una obra cuya prosa se revela en toda su vitalidad y vena poética.]]></description>\n  <work>\n  <id type=\"integer\">165444</id>\n  <books_count type=\"integer\">43</books_count>\n  <best_book_id type=\"integer\">171327</best_book_id>\n  <reviews_count type=\"integer\">3573</reviews_count>\n  <ratings_sum type=\"integer\">8291</ratings_sum>\n  <ratings_count type=\"integer\">2141</ratings_count>\n  <text_reviews_count type=\"integer\">186</text_reviews_count>\n  <original_publication_year type=\"integer\">1998</original_publication_year>\n  <original_publication_month type=\"integer\">11</original_publication_month>\n  <original_publication_day type=\"integer\">30</original_publication_day>\n  <original_title>Rosario Tijeras</original_title>\n  <original_language_id type=\"integer\" nil=\"true\"/>\n  <media_type>book</media_type>\n  <rating_dist>5:637|4:794|3:541|2:138|1:31|total:2141</rating_dist>\n  <desc_user_id type=\"integer\">5008685</desc_user_id>\n  <default_chaptering_book_id type=\"integer\" nil=\"true\"/>\n  <default_description_language_code nil=\"true\"/>\n  <work_uri>kca://work/amzn1.gr.work.v1.CjNnS5EDorvc9wRF-TOerA</work_uri>\n</work>\n  <average_rating>3.87</average_rating>\n  <num_pages><![CDATA[176]]></num_pages>\n  <format><![CDATA[Paperback]]></format>\n  <edition_information><![CDATA[]]></edition_information>\n  <ratings_count><![CDATA[1679]]></ratings_count>\n  <text_reviews_count><![CDATA[123]]></text_reviews_count>\n  <url><![CDATA[https://www.goodreads.com/book/show/171327.Rosario_Tijeras]]></url>\n  <link><![CDATA[https://www.goodreads.com/book/show/171327.Rosario_Tijeras]]></link>\n  <authors>\n<author>\n<id>84825</id>\n<name>Jorge Franco</name>\n<role></role>\n<image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1541629332p5/84825.jpg]]>\n</image_url>\n<small_image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1541629332p2/84825.jpg]]>\n</small_image_url>\n<link><![CDATA[https://www.goodreads.com/author/show/84825.Jorge_Franco]]></link>\n<average_rating>3.79</average_rating>\n<ratings_count>4241</ratings_count>\n<text_reviews_count>433</text_reviews_count>\n</author>\n<author>\n<id>50060</id>\n<name>Gregory Rabassa</name>\n<role>Translator</role>\n<image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1464035315p5/50" <> ...}

      iex> Codex.Book.reviews_by_title_string("larga noche", author: "Santiago Gamboa")
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[book_title]]></method>\n  </Request>\n  <book>\n  <id>48140839</id>\n  <title>Será larga la noche</title>\n  <isbn><![CDATA[]]></isbn>\n  <isbn13><![CDATA[]]></isbn13>\n  <asin><![CDATA[B07XH5RC7N]]></asin>\n  <kindle_asin><![CDATA[]]></kindle_asin>\n  <marketplace_id><![CDATA[]]></marketplace_id>\n  <country_code><![CDATA[ES]]></country_code>\n  <image_url>https://s.gr-assets.com/assets/nophoto/book/111x148-bcc042a9c91a29c1d680899eff700a03.png</image_url>\n  <small_image_url>https://s.gr-assets.com/assets/nophoto/book/50x75-a91bf249278a81aabab721ef782c4a74.png</small_image_url>\n  <publication_year></publication_year>\n  <publication_month></publication_month>\n  <publication_day></publication_day>\n  <publisher></publisher>\n  <language_code></language_code>\n  <is_ebook>true</is_ebook>\n  <description></description>\n  <work>\n  <id type=\"integer\">73367364</id>\n  <books_count type=\"integer\">4</books_count>\n  <best_book_id type=\"integer\">48140839</best_book_id>\n  <reviews_count type=\"integer\">181</reviews_count>\n  <ratings_sum type=\"integer\">233</ratings_sum>\n  <ratings_count type=\"integer\">58</ratings_count>\n  <text_reviews_count type=\"integer\">11</text_reviews_count>\n  <original_publication_year type=\"integer\">2019</original_publication_year>\n  <original_publication_month type=\"integer\" nil=\"true\"/>\n  <original_publication_day type=\"integer\" nil=\"true\"/>\n  <original_title nil=\"true\"/>\n  <original_language_id type=\"integer\" nil=\"true\"/>\n  <media_type nil=\"true\"/>\n  <rating_dist>5:15|4:31|3:10|2:2|1:0|total:58</rating_dist>\n  <desc_user_id type=\"integer\">-9</desc_user_id>\n  <default_chaptering_book_id type=\"integer\" nil=\"true\"/>\n  <default_description_language_code nil=\"true\"/>\n  <work_uri>kca://work/amzn1.gr.work.v2.1a536abb-f4af-447e-a773-c115ec311fdd</work_uri>\n</work>\n  <average_rating>4.02</average_rating>\n  <num_pages><![CDATA[]]></num_pages>\n  <format><![CDATA[]]></format>\n  <edition_information><![CDATA[]]></edition_information>\n  <ratings_count><![CDATA[45]]></ratings_count>\n  <text_reviews_count><![CDATA[8]]></text_reviews_count>\n  <url><![CDATA[https://www.goodreads.com/book/show/48140839-ser-larga-la-noche]]></url>\n  <link><![CDATA[https://www.goodreads.com/book/show/48140839-ser-larga-la-noche]]></link>\n  <authors>\n<author>\n<id>84824</id>\n<name>Santiago Gamboa</name>\n<role></role>\n<image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1299941002p5/84824.jpg]]>\n</image_url>\n<small_image_url nophoto='false'>\n<![CDATA[https://images.gr-assets.com/authors/1299941002p2/84824.jpg]]>\n</small_image_url>\n<link><![CDATA[https://www.goodreads.com/author/show/84824.Santiago_Gamboa]]></link>\n<average_rating>3.92</average_rating>\n<ratings_count>3186</ratings_count>\n<text_reviews_count>366</text_reviews_count>\n</author>\n</authors>\n\n    <reviews_widget>\n      <![CDATA[\n        <style>\n  #goodreads-widget {\n    font-family: georgia, serif;\n    padding: 18px 0;\n    width:565px;\n  }\n  #goodreads-widget h1 {\n    font-weight:normal;\n    font-size: 16px;\n    border-bottom: 1px solid #BBB596;\n    margin-bottom: 0;\n  }\n  #goodreads-widget a {\n    text-decoration: none;\n    color:#660;\n  }\n  iframe{\n    background-color: #fff;\n  }\n  #goodreads-widget a:hover { text-decoration: underline; }\n  #goodreads-widget a:active {\n    color:#660;\n  }\n  #gr_footer {\n    width: 100%;\n    border-top: 1px solid #BBB596;\n    text-align: right;\n  }\n  #goodreads-widget .gr_branding{\n    color: #382110;\n    font-size: 11px;\n    text-decoration: none;\n    font-family: \"Helvetica Neue\", Helvetica, Arial, sans-serif;\n  }\n</style>\n<div id=\"goodreads-widget\">\n  <div id=\"gr_header\"><h1><a rel=\"nofollow\" href=\"https://www.goodreads.com/book/show/48140839-ser-larga-la-noche\">Será larga la noche Reviews</a></h1></div>\n  <iframe id=\"the_iframe\" src=\"https://www.goodreads.com/api/reviews_widget_iframe?did=DEVELOPER_ID&amp;format=html&amp;isbn=B07XH5RC7N&amp;links=660&amp;min_rati" <> ...}
  """
  def reviews_by_title_string(title, opts \\ []) do
    endpoint = "book/title.xml"

    params =
      %{
        "title" => title,
        "author" => Keyword.get(opts, :author),
        "rating" => Keyword.get(opts, :rating)
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    HttpClient.get(endpoint, [], params: params)
  end

  defp parse_format(format) when format in ["xml", "json"], do: format
  defp parse_format(_), do: "xml"
end
