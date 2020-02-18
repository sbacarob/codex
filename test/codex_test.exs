defmodule CodexTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "signed request returns the expected result" do
    ExVCR.Config.filter_request_headers("Authorization")
    ExVCR.Config.filter_sensitive_data("<key>.*<\/key>", "<key>[CDATA[YOUR_API_KEY]]</key>")
    use_cassette "signed_request" do
      assert {:ok, xml_data} = Codex.signed_request("api/auth_user", "ACCESS_TOKEN", "ACCESS_TOKEN_SECRET")

      assert xml_data =~ "<authentication>true</authentication>"
      assert xml_data =~ "<name>Santiago Bacaro</name>"
    end
  end
end
