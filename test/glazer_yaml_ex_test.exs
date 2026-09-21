defmodule Glazer.YAMLTest do
  use ExUnit.Case

  describe "decode/1,2" do
    test "returns {:ok, term} for valid YAML" do
      assert Glazer.YAML.decode("a: 1\n") == {:ok, %{"a" => 1}}
    end

    test "returns {:error, reason} on invalid input" do
      assert {:error, _reason} = Glazer.YAML.decode("a: [")
    end

    test "passes through decode options" do
      assert Glazer.YAML.decode("a: ~\n", [:use_nil]) == {:ok, %{"a" => nil}}
    end
  end

  describe "decode!/1,2" do
    test "decodes valid YAML" do
      assert Glazer.YAML.decode!("a: 1\nb:\n  - true\n  - null\n  - 3.5\n") ==
               %{"a" => 1, "b" => [true, :null, 3.5]}
    end

    test "raises on invalid input" do
      assert_raise ErlangError, fn -> Glazer.YAML.decode!("a: [") end
    end

    test "passes through decode options" do
      assert Glazer.YAML.decode!("a: 1\n", [{:keys, :atom}]) == %{a: 1}
    end
  end

  describe "encode!/1,2" do
    test "encodes a term to YAML in block style" do
      assert Glazer.YAML.encode!(%{"a" => 1, "b" => [true, :null, 3.5]}) ==
               "a: 1\nb:\n- true\n- null\n- 3.5\n"
    end

    test "passes through encode options" do
      assert Glazer.YAML.encode!(%{"a" => nil}, [:use_nil]) == "a: null\n"
    end

    test "raises when the term cannot be encoded" do
      assert_raise ErlangError, fn -> Glazer.YAML.encode!([1 | 2]) end
    end
  end

  describe "read_file!/1,2 and write_file/2,3" do
    setup do
      path = Path.join(System.tmp_dir!(), "glazer_yaml_ex_test_#{System.unique_integer([:positive])}.yaml")
      on_exit(fn -> File.rm(path) end)
      %{path: path}
    end

    test "round-trips a term through a file", %{path: path} do
      assert Glazer.YAML.write_file(path, %{"a" => 1}) == :ok
      assert Glazer.YAML.read_file!(path) == %{"a" => 1}
    end

    test "write_file/3 and read_file!/2 accept options", %{path: path} do
      assert Glazer.YAML.write_file(path, %{"a" => nil}, [:use_nil]) == :ok
      assert Glazer.YAML.read_file!(path, [:use_nil]) == %{"a" => nil}
    end
  end
end
