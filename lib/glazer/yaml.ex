defmodule Glazer.YAML do
  @moduledoc """
  Idiomatic Elixir wrapper around `:glazer_yaml` for fast YAML encoding and
  decoding.

  This module simply `defdelegate`s to the underlying Erlang `:glazer_yaml`
  module — see its docs for the full behaviour, option reference, and
  examples (options are passed through unchanged, as atoms/tuples).

  ## Example

  ```elixir
  iex> Glazer.YAML.decode("a: 1\\nb:\\n  - true\\n  - null\\n  - 3.5\\n")
  %{"a" => 1, "b" => [true, nil, 3.5]}

  iex> Glazer.YAML.encode(%{"a" => 1, "b" => [true, nil, 3.5]}, [:use_nil])
  "a: 1\\nb:\\n  - true\\n  - null\\n  - 3.5\\n"
  ```
  """

  @doc """
  Decode a YAML binary or iolist to an Elixir term, raising `{parse_error,
  reason}` on invalid input. YAML mappings are returned as maps (default).

  See `:glazer_yaml.decode/1`.
  """
  defdelegate decode!(input), to: :glazer_yaml, as: :decode

  @doc """
  Like `decode!/1`, but with decode options (see `t::glazer_yaml.decode_opts/0`).

  See `:glazer_yaml.decode/2`.
  """
  defdelegate decode!(input, opts), to: :glazer_yaml, as: :decode

  @doc """
  Decode a YAML binary or iolist, returning `{:ok, term}` or `{:error,
  reason}` instead of raising.

  See `:glazer_yaml.try_decode/1`.
  """
  defdelegate decode(input), to: :glazer_yaml, as: :try_decode

  @doc """
  Like `decode/1`, but with decode options (see `t::glazer_yaml.decode_opts/0`).

  See `:glazer_yaml.try_decode/2`.
  """
  defdelegate decode(input, opts), to: :glazer_yaml, as: :try_decode

  @doc """
  Encode an Elixir term to a YAML binary in block style, raising
  `{encode_error, reason}` if `data` cannot be represented as YAML.

  See `:glazer_yaml.encode/1`.
  """
  defdelegate encode!(data), to: :glazer_yaml, as: :encode

  @doc """
  Like `encode!/1`, but with encode options (see `t::glazer_yaml.encode_opts/0`).

  See `:glazer_yaml.encode/2`.
  """
  defdelegate encode!(data, opts), to: :glazer_yaml, as: :encode

  @doc """
  Read `filename` and decode its contents as YAML.

  See `:glazer_yaml.read_file/1`.
  """
  defdelegate read_file!(filename), to: :glazer_yaml, as: :read_file

  @doc """
  Like `read_file!/1`, but with decode options (see `t::glazer_yaml.decode_opts/0`).

  See `:glazer_yaml.read_file/2`.
  """
  defdelegate read_file!(filename, opts), to: :glazer_yaml, as: :read_file

  @doc """
  Encode `data` to YAML and write it to `filename`, overwriting any existing
  file.

  See `:glazer_yaml.write_file/2`.
  """
  defdelegate write_file(filename, data), to: :glazer_yaml

  @doc """
  Like `write_file/2`, but with encode options (see `t::glazer_yaml.encode_opts/0`).

  See `:glazer_yaml.write_file/3`.
  """
  defdelegate write_file(filename, data, opts), to: :glazer_yaml
end
