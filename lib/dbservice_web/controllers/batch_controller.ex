defmodule DbserviceWeb.BatchController do
  use DbserviceWeb, :controller

  alias Dbservice.Batches
  alias Dbservice.Batches.Batch

  action_fallback DbserviceWeb.FallbackController

  use PhoenixSwagger

  def swagger_definitions do
    %{
      Batch:
        swagger_schema do
          title("Batch")
          description("A batch of students")

          properties do
            name(:string, "Batch name")
          end

          example(%{
            name: "Kendriya Vidyalaya - Class 12th"
          })
        end,
      Batches:
        swagger_schema do
          title("Batches")
          description("All the batches")
          type(:array)
          items(Schema.ref(:Batch))
        end,
      UserIds:
        swagger_schema do
          properties do
            user_ids(:array, "List of user ids")
          end

          example(%{
            user_ids: [1, 2]
          })
        end,
      SessionIds:
        swagger_schema do
          properties do
            session_ids(:array, "List of session ids")
          end

          example(%{
            session_ids: [1, 2]
          })
        end
    }
  end

  swagger_path :index do
    get("/api/batch")
    response(200, "OK", Schema.ref(:Batches))
  end

  def index(conn, _params) do
    batch = Batches.list_batch()
    render(conn, "index.json", batch: batch)
  end

  swagger_path :create do
    post("/api/batch")

    parameters do
      body(:body, Schema.ref(:Batch), "Batch to create", required: true)
    end

    response(201, "Created", Schema.ref(:Batch))
  end

  def create(conn, params) do
    with {:ok, %Batch{} = batch} <- Batches.create_batch(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.batch_path(conn, :show, batch))
      |> render("show.json", batch: batch)
    end
  end

  swagger_path :show do
    get("/api/batch/{batchId}")

    parameters do
      batchId(:path, :integer, "The id of the batch", required: true)
    end

    response(200, "OK", Schema.ref(:Batch))
  end

  def show(conn, %{"id" => id}) do
    batch = Batches.get_batch!(id)
    render(conn, "show.json", batch: batch)
  end

  swagger_path :update do
    patch("/api/batch/{batchId}")

    parameters do
      batchId(:path, :integer, "The id of the batch", required: true)
      body(:body, Schema.ref(:Batch), "batch to create", required: true)
    end

    response(200, "Updated", Schema.ref(:Batch))
  end

  def update(conn, params) do
    batch = Batches.get_batch!(params["id"])

    with {:ok, %Batch{} = batch} <- Batches.update_batch(batch, params) do
      render(conn, "show.json", batch: batch)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/batch/{batchId}")

    parameters do
      batchId(:path, :integer, "The id of the batch", required: true)
    end

    response(204, "No Content")
  end

  def delete(conn, %{"id" => id}) do
    batch = Batches.get_batch!(id)

    with {:ok, %Batch{}} <- Batches.delete_batch(batch) do
      send_resp(conn, :no_content, "")
    end
  end

  swagger_path :update_users do
    post("/api/batch/{batchId}/update-users")

    parameters do
      batchId(:path, :integer, "The id of the batch", required: true)
      body(:body, Schema.ref(:UserIds), "List of user ids to update", required: true)
    end

    response(200, "OK", Schema.ref(:Batch))
  end

  def update_users(conn, %{"id" => batch_id, "user_ids" => user_ids}) when is_list(user_ids) do
    with {:ok, %Batch{} = batch} <- Batches.update_users(batch_id, user_ids) do
      render(conn, "show.json", batch: batch)
    end
  end

  swagger_path :update_sessions do
    post("/api/batch/{batchId}/update-sessions")

    parameters do
      batchId(:path, :integer, "The id of the batch", required: true)
      body(:body, Schema.ref(:SessionIds), "List of session ids to update", required: true)
    end

    response(200, "OK", Schema.ref(:Batch))
  end

  def update_sessions(conn, %{"id" => batch_id, "session_ids" => session_ids})
      when is_list(session_ids) do
    with {:ok, %Batch{} = batch} <- Batches.update_sessions(batch_id, session_ids) do
      render(conn, "show.json", batch: batch)
    end
  end
end
