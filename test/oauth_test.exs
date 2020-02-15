defmodule OAuthTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest Codex.OAuth, except: [get_request_token_and_secret: 0]

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
        } == Codex.OAuth.get_request_token_and_secret()
    end
  end
end
