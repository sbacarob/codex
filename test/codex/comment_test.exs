defmodule Codex.CommentTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Codex.Comment

  setup_all do
    HTTPoison.start
  end

  describe "list_comments" do
    test "gets the comments for the given subject" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "comment/list_comments" do
        assert {:ok, data} = Comment.list_comments("review", 18716597)

        assert data =~ "<authentication>true</authentication>"
        assert data =~ "Geisha"
      end
    end

    test "returns 401 error when api key is missing" do
      ExVCR.Config.filter_sensitive_data("key=[^&]+&", "key=YOUR_API_KEY")
      ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
      use_cassette "comment/list_comments_error" do
        assert {:ok, response} = Comment.list_comments("review", 18716597)

        assert response.status_code == 401
        assert response.body =~ "Invalid API key"
      end
    end
  end
end
