defmodule InventoryApi.InventoryController do
  use InventoryApi.Web, :controller

  def index(conn, params) do
    name_filter = Map.get(params, "name", "*")
    status_filter = Map.get(params, "status", "*")
  
    render(conn, "inventory.json", inventory: Inventory.Query.inventory(name_filter, status_filter))
  end

  def create(conn, params) do
    n = Map.get(params, "name")
    c = Map.get(params, "category")
    s = Map.get(params, "sell_in")
    q = Map.get(params, "quality")

    case Inventory.Command.add_item_to_inventory(n, c, s, q) do
      {:ok, id} -> render(conn, "item_id.json", item_id: id)
      {:error, error} -> conn |> put_status(400) |> render("error.json", message: error)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Inventory.Query.item_details(id)

    render(conn, "item.json", inventory: item)
  end

  def end_day(conn, _params) do
    case Inventory.Command.end_day() do
      :ok -> render(conn, "success.json")
      {:error, error} -> conn |> put_status(500) |> render("error.json", message: error)
    end
  end
end
