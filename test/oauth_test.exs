defmodule OAuthTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest Codex.OAuth, except: [get_request_token_and_secret: 0]

  setup_all do
    HTTPoison.start
  end

  test "get a token and token secret from Goodreads" do
    use_cassette "get_token_and_secret" do
      # mostly test that token and token secret are extracted correctly from an ok response.
      # the signature was generated using "YOUR_API_KEY" as :api_key  and "YOUR_API_SECRET"
      # as :api_secret in the config. By using the same timestamp and nonce_str in the headers
      # of the cassette, you should be able to generate the same signature.
      # TOKEN and TOKEN_SECRET in the response were also modified from the original values.
      assert {:ok,
        %{
          "oauth_token" => "TOKEN",
          "oauth_token_secret" => "TOKEN_SECRET"
          }
        } == Codex.OAuth.get_request_token_and_secret()
    end
  end
end
