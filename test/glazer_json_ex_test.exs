defmodule Glazer.JSONTest do
  use ExUnit.Case

  describe "decode/1,2" do
    test "returns {:ok, term} with nil for JSON null" do
      assert Glazer.JSON.decode(~s({"a":1,"b":null})) == {:ok, %{"a" => 1, "b" => nil}}
    end

    test "returns {:error, reason} on invalid input" do
      assert {:error, _reason} = Glazer.JSON.decode("not json")
    end

    test "passes through decode options" do
      assert Glazer.JSON.decode(~s({"a":1}), [{:keys, :atom}]) == {:ok, %{a: 1}}
    end
  end

  describe "decode!/1" do
    test "decodes valid JSON, using nil for JSON null" do
      assert Glazer.JSON.decode!(~s({"a":1,"b":null})) == %{"a" => 1, "b" => nil}
    end

    test "raises Glazer.ParseError on invalid input" do
      assert_raise Glazer.ParseError, fn -> Glazer.JSON.decode!("not json") end
    end
  end

  describe "encode!/1,2" do
    test "encodes a term to JSON, nil as null" do
      assert Glazer.JSON.encode!(%{"a" => 1, "b" => nil}) == ~s({"a":1,"b":null})
    end

    test "passes through encode options" do
      assert Glazer.JSON.encode!(%{"a" => 1}, [:pretty]) =~ "\n"
    end

    test "raises Glazer.ParseError when the term cannot be encoded" do
      assert_raise Glazer.ParseError, fn -> Glazer.JSON.encode!([1 | 2]) end
    end
  end

  test "encode_ndjson/1,2 encodes one JSON value per line" do
    assert Glazer.JSON.encode_ndjson([1, 2]) == "1\n2\n"
    assert Glazer.JSON.encode_ndjson([<<"héllo"::utf8>>], [:force_utf8]) =~ "héllo"
  end

  test "encode_to_iodata!/1 is equivalent to encode!/1" do
    data = %{"a" => 1}
    assert Glazer.JSON.encode_to_iodata!(data) == Glazer.JSON.encode!(data)
  end

  test "minify!/1 strips insignificant whitespace" do
    assert Glazer.JSON.minify!(~s({ "a" : 1 })) == ~s({"a":1})
  end

  test "prettify!/1 adds indentation" do
    assert Glazer.JSON.prettify!(~s({"a":1})) =~ "\n"
  end

  describe "query!/2,3" do
    test "runs a jq filter against a JSON document" do
      case Glazer.JSON.query!(~s({"a":[1,2,3]}), ".a[]") do
        {:ok, [1, 2, 3]} -> :ok
        {:error, :jq_not_available} -> :ok
      end
    end

    test "accepts decode options" do
      case Glazer.JSON.query!(~s({"a":1}), ".", [{:keys, :atom}]) do
        {:ok, [%{a: 1}]} -> :ok
        {:error, :jq_not_available} -> :ok
      end
    end
  end

  test "scan!/1,2 locates the end of the next complete JSON value" do
    assert Glazer.JSON.scan!(~s({"a":1})) == {:complete, 7}
    assert {:incomplete, state} = Glazer.JSON.scan!(~s({"a":))
    assert Glazer.JSON.scan!(~s({"a":1}), state) == {:complete, 7}
  end

  describe "streaming" do
    test "stream_decoder/0,1, stream_feed!/2, and stream_eof!/1 round-trip" do
      decoder = Glazer.JSON.stream_decoder()
      {values, decoder} = Glazer.JSON.stream_feed!(decoder, ~s({"a":1} {"b":))
      assert values == [%{"a" => 1}]

      {values, decoder} = Glazer.JSON.stream_feed!(decoder, ~s(2}))
      assert values == [%{"b" => 2}]

      assert Glazer.JSON.stream_eof!(decoder) == {:ok, []}
    end

    test "stream_decoder/1 passes decode options through to every value" do
      decoder = Glazer.JSON.stream_decoder([{:keys, :atom}])
      {values, _decoder} = Glazer.JSON.stream_feed!(decoder, ~s({"a":1}))
      assert values == [%{a: 1}]
    end
  end

  describe "read_file!/1,2 and write_file!/2,3" do
    setup do
      path = Path.join(System.tmp_dir!(), "glazer_json_ex_test_#{System.unique_integer([:positive])}.json")
      on_exit(fn -> File.rm(path) end)
      %{path: path}
    end

    test "round-trips a term through a file", %{path: path} do
      assert Glazer.JSON.write_file!(path, %{"a" => 1}) == :ok
      assert Glazer.JSON.read_file!(path) == %{"a" => 1}
    end

    test "write_file!/3 and read_file!/2 accept options", %{path: path} do
      assert Glazer.JSON.write_file!(path, %{"a" => 1}, [:pretty]) == :ok
      assert Glazer.JSON.read_file!(path, [{:keys, :atom}]) == %{a: 1}
    end
  end
end
