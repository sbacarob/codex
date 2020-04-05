defmodule Codex.Comment do
  @moduledoc """
  Contains functions for creating and retrieving comments
  """

  alias Codex.HttpClient

  @doc """
  Get a list of comments for the given subject

  ## Args:

  * `type` - One of "author_blog_post", "author_following", "book_news_post", "chapter", "comment",
  "community_answer", "event_response", "friend", "giveaway", "giveaway_request", "group_user",
  "interview", "librarian_note", "link_collection", "list", "owned_book", "photo", "poll", "poll_vote",
  "queued_item", "question", "question_user_stat", "quiz", "quiz_score", "rating", "read_status",
  "recommendation", "recommendation_request", "reading_year", "review", "review_proxy", "sharing",
  "services/models/reading_note", "topic", "user", "user_challenge", "user_following",
  "user_list_challenge", "user_list_vote", "user_quote", "user_status", "video".
  * `id` - The id of the resource
  * `page` - The page of results to fetch (optional. Defaults to 1)

  ## Examples:

      iex> Codex.Comment.list_comments("review", 18716597)
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[comment_index]]></method>\n  </Request>\n  <comments start=\"1\" end=\"20\" total=\"66\">\n  <comment>\n  <id>206000373</id>\n  <body><![CDATA[On and you were suspicious from the next word on once you realised it was a whiteguy. So you admit you had no problem till you saw his race, so you don't really have a problem with any of the literature its self, you just hate the white guy]]></body>\n  \n  <user>\n    <id>81584960</id>\n    <uri>kca://profile:goodreads/A1J9C2ZOKY3N0A</uri>\n    <name>Jo</name>\n    <display_name>Jo Sé</display_name>\n\n    <location><![CDATA[Cardiff, X5, The United Kingdom]]></location>\n\n    <link><![CDATA[https://www.goodreads.com/user/show/81584960-jo-s]]></link>\n\n    <image_url><![CDATA[https://images.gr-assets.com/users/1583028079p3/81584960.jpg]]></image_url>\n    <small_image_url><![CDATA[https://images.gr-assets.com/users/1583028079p2/81584960.jpg]]></small_image_url>\n    <has_image>true</has_image>\n\n  </user>\n\n  <created_at>Tue Mar 17 14:43:36 -0700 2020</created_at>\n  <updated_at>Tue Mar 17 14:43:36 -0700 2020</updated_at>\n</comment>\n\n  <comment>\n  <id>206000325</id>\n  <body><![CDATA[To me, you sound like you're Japanese yourself and have issue with a westerner daring to write about your culture, because all your complaints are arbitrary, you say little while saying a lot (quite the feat!). The fact the author as everything about the Geisha culture down and your complaint is little more than he's never been one himself, he's actually knocked it out the park and your review has made me WANT to now read this book]]></body>\n  \n  <user>\n    <id>81584960</id>\n    <uri>kca://profile:goodreads/A1J9C2ZOKY3N0A</uri>\n    <name>Jo</name>\n    <display_name>Jo Sé</display_name>\n\n    <location><![CDATA[Cardiff, X5, The United Kingdom]]></location>\n\n    <link><![CDATA[https://www.goodreads.com/user/show/81584960-jo-s]]></link>\n\n    <image_url><![CDATA[https://images.gr-assets.com/users/1583028079p3/81584960.jpg]]></image_url>\n    <small_image_url><![CDATA[https://images.gr-assets.com/users/1583028079p2/81584960.jpg]]></small_image_url>\n    <has_image>true</has_image>\n\n  </user>\n\n  <created_at>Tue Mar 17 14:42:00 -0700 2020</created_at>\n  <updated_at>Tue Mar 17 14:42:00 -0700 2020</updated_at>\n</comment>\n\n  <comment>\n  <id>205991441</id>\n  <body><![CDATA[I 1000% disagree with you. It is a masterpiece and it deserves a place on the top ten best books of all time list.]]></body>\n  \n  <user>\n    <id>111514772</id>\n    <uri>kca://profile:goodreads/A1BGCVCU8MDOXW</uri>\n    <name>Kenzi</name>\n    <display_name>Kenzi</display_name>\n\n    <location></location>\n\n    <link><![CDATA[https://www.goodreads.com/user/show/111514772-kenzi]]></link>\n\n    <image_url><![CDATA[https://images.gr-assets.com/users/1584467088p3/111514772.jpg]]></image_url>\n    <small_image_url><![CDATA[https://images.gr-assets.com/users/1584467088p2/111514772.jpg]]></small_image_url>\n    <has_image>true</has_image>\n\n  </user>\n\n  <created_at>Tue Mar 17 10:31:56 -0700 2020</created_at>\n  <updated_at>Tue Mar 17 10:31:56 -0700 2020</updated_at>\n</comment>\n\n  <comment>\n  <id>203539599</id>\n  <body><![CDATA[<i>Tim wrote: \"Reading some of the comments about how Memoirs of a Geisha is flawed because it supposedly lacks some kind of accuracy or cultural authenticity is weird. Kids, spoiler alert, J. K. Rowling was neve...\"</i><br /><br />Rowling may not have been a wizard at Hogwarts, but was still a wizard with words and built a believable character and world. London may not have been a Wolf but managed to charmingly describe wolves to people who knew little about them, and he did it so well that even zoologists can read his book with enjoyment.<br /><br />Golden did not do anywhere near as well. Many people who do understand anything, however small about Japanese history are likely to wince their way through a lot of Geisha. London used anthropomorphic terms to describe animals, but got a" <> ...}
  """
  def list_comments(type, id, opts \\ []) do
    endpoint = "comment.xml"

    params =
      %{
        "type" => type,
        "id" => id,
        "page" => Keyword.get(opts, :page)
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    HttpClient.get(endpoint, [], params: params)
  end
end
