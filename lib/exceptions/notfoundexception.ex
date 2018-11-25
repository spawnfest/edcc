defmodule NotFoundException do
    defexception message: "Could not find"

    def full_message(error), do: "NotFoundException: #{error.message}"
end