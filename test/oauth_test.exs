defmodule OAuthTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Codex.OAuth

  doctest OAuth, except: [get_request_token_and_secret: 0, generate_oauth_header: 4]

  setup_all do
    HTTPoison.start
  end

  test "get a token and token secret from Goodreads" do
    ExVCR.Config.filter_sensitive_data("oauth_token=[^&].+&", "oauth_token=TOKEN&")
    ExVCR.Config.filter_sensitive_data("oauth_token_secret=.+", "oauth_token_secret=TOKEN_SECRET")
    ExVCR.Config.filter_request_headers("Authorization")
    use_cassette "get_token_and_secret" do
      # mostly test that token and token secret are extracted correctly from an ok response.
      assert {:ok,
        %{
          "oauth_token" => "TOKEN",
          "oauth_token_secret" => "TOKEN_SECRET"
          }
        } == OAuth.get_request_token_and_secret()
    end
  end

  test "get request authorization url" do
    assert OAuth.get_request_authorization_url("API_TOKEN") ==
      "https://www.goodreads.com/oauth/authorize?oauth_token=API_TOKEN"

     assert OAuth.get_request_authorization_url("API_TOKEN", "https://myapp.com/goodreads_oauth_callback") ==
      "https://www.goodreads.com/oauth/authorize?oauth_token=API_TOKEN&oauth_callback=https://myapp.com/goodreads_oauth_callback"
  end

  describe "generate oauth header" do
    test "generates the OAuth Authorization header with all required info" do
      "OAuth " <> header_data = OAuth.generate_oauth_header("test_endpoint")

      data_as_map =
        for pair <- String.split(header_data, ","),
            [key, value] = String.split(pair, "=", parts: 2),
            into: %{},
            do: {key, value}

      %{
        "oauth_consumer_key" => api_key,
        "oauth_nonce" => _nonce,
        "oauth_signature" => signature,
        "oauth_signature_method" => signature_method,
        "oauth_timestamp" => _timestamp,
        "oauth_version" => oauth_version
      } = data_as_map

      assert api_key == "YOUR_API_KEY"
      assert String.length(signature) > 0
      assert signature_method == "HMAC-SHA1"
      assert oauth_version == "1.0"
    end
  end

  test "generates the OAuth Authorization header including the right request token" do
    "OAuth " <> header_data = OAuth.generate_oauth_header("test_endpoint", "TOKEN", "TOKEN_SECRET")

      data_as_map =
        for pair <- String.split(header_data, ","),
            [key, value] = String.split(pair, "=", parts: 2),
            into: %{},
            do: {key, value}

      %{
        "oauth_consumer_key" => api_key,
        "oauth_nonce" => _nonce,
        "oauth_signature" => signature,
        "oauth_signature_method" => signature_method,
        "oauth_timestamp" => _timestamp,
        "oauth_version" => oauth_version,
        "oauth_token" => oauth_token
      } = data_as_map

      assert api_key == "YOUR_API_KEY"
      assert String.length(signature) > 0
      assert signature_method == "HMAC-SHA1"
      assert oauth_version == "1.0"
      assert oauth_token == "TOKEN"
  end
end
