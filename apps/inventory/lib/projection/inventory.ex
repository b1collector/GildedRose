defmodule Inventory.Projection.Inventory do
  @moduledoc false

  @type t :: %__MODULE__{streams: [{String.t, struct}]}

  defstruct streams: %{}

  @doc """
  Convert a stream of events into an inventory.
  """
  def projection(stream) do
    projection(stream, %__MODULE__{})
  end

  @doc """
  Convert a stream of events into an inventory using a specified starting state.
  """
  def projection(stream, initial) do
    stream
    |> Enum.reduce(initial, &(project(&2, &1)))
    |> (fn x -> x.streams end).()
    |> Map.values()
  end


  defp project(p, %EventStore.RecordedEvent{metadata: %{"item_id" => id}} = e) do
    item = p.streams
           |> Map.get(id, %Inventory.Projection.ItemDetails{})
           |> Inventory.Projection.project(e)
    %__MODULE__{p | streams: Map.put(p.streams, id, item)}
  end
end
