defmodule Glazer.JSON.EncoderTest do
  use ExUnit.Case

  defmodule TestUser do
    @derive {Glazer.JSON.Encoder, only: [:id, :name, :email]}
    defstruct [:id, :name, :email, :secret]
  end

  defmodule TestUserWithExcept do
    @derive {Glazer.JSON.Encoder, except: [:secret]}
    defstruct [:id, :name, :secret]
  end

  defmodule AllFieldsUser do
    @derive Glazer.JSON.Encoder
    defstruct [:id, :name, :secret]
  end

  test "Glazer.JSON.Encoder filters fields with :only" do
    user = %TestUser{id: 1, name: "Alice", email: "alice@example.com", secret: "password"}
    json = Glazer.JSON.Encoder.encode(user, [])

    # Verify the included fields are present
    assert String.contains?(json, "\"id\"")
    assert String.contains?(json, "\"name\"")
    assert String.contains?(json, "\"email\"")
    # Verify secret is excluded
    refute String.contains?(json, "secret")
    refute String.contains?(json, "password")
  end

  test "Glazer.JSON.Encoder filters fields with :except" do
    user = %TestUserWithExcept{id: 2, name: "Bob", secret: "hidden"}
    json = Glazer.JSON.Encoder.encode(user, [])

    # Verify the included fields are present
    assert String.contains?(json, "\"id\"")
    assert String.contains?(json, "\"name\"")
    # Verify secret is excluded
    refute String.contains?(json, "secret")
    refute String.contains?(json, "hidden")
  end

  test "Glazer.JSON.Encoder includes all fields by default" do
    user = %AllFieldsUser{id: 3, name: "Charlie", secret: "password123"}
    json = Glazer.JSON.Encoder.encode(user, [])

    # All fields should be present
    assert String.contains?(json, "\"id\"")
    assert String.contains?(json, "\"name\"")
    assert String.contains?(json, "\"secret\"")
    assert String.contains?(json, "password123")
  end

  test "Glazer.JSON.Encoder works with encoding options" do
    user = %TestUser{id: 1, name: "Alice", email: "alice@example.com", secret: "password"}
    json_pretty = Glazer.JSON.Encoder.encode(user, [:pretty])

    # Pretty-printed should have newlines
    assert String.contains?(json_pretty, "\n")
    # Fields should still be filtered
    refute String.contains?(json_pretty, "secret")
  end
end
