defmodule DbserviceWeb.UserController do
  use DbserviceWeb, :controller

  alias Dbservice.Users
  alias Dbservice.Users.User

  action_fallback DbserviceWeb.FallbackController

  use PhoenixSwagger

  def swagger_definitions do
    %{
      User:
        swagger_schema do
          title("User")
          description("A user in the application")

          properties do
            first_name(:string, "First name")
            last_name(:string, "Last name")
            email(:string, "Email")
            phone(:string, "Phone number")
            gender(:string, "Gender")
            address(:string, "Address")
            city(:string, "City")
            district(:string, "District")
            state(:string, "State")
            pincode(:string, "Pin code")
            role(:string, "User role")
          end

          example(%{
            first_name: "Rahul",
            last_name: "Sharma",
            email: "rahul.sharma@example.com",
            phone: "9998887777",
            gender: "Male",
            address: "Bandra Complex, Kurla Road",
            city: "Mumbai",
            district: "Mumbai",
            state: "Maharashtra",
            pincode: "400011",
            role: "student"
          })
        end,
      Users:
        swagger_schema do
          title("Users")
          description("All users in the application")
          type(:array)
          items(Schema.ref(:User))
        end,
      BatchIds:
        swagger_schema do
          properties do
            batch_ids(:array, "List of batch ids")
          end

          example(%{
            batch_ids: [1, 2]
          })
        end
    }
  end

  swagger_path :index do
    get("/api/user")
    response(200, "OK", Schema.ref(:Users))
  end

  def index(conn, _params) do
    user = Users.list_all_users()
    render(conn, "index.json", user: user)
  end

  swagger_path :create do
    post("/api/user")

    parameters do
      body(:body, Schema.ref(:User), "User to create", required: true)
    end

    response(201, "Created", Schema.ref(:User))
  end

  def create(conn, params) do
    with {:ok, %User{} = user} <- Users.create_user(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  swagger_path :show do
    get("/api/user/{userId}")

    parameters do
      userId(:path, :integer, "The id of the user", required: true)
    end

    response(200, "OK", Schema.ref(:User))
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.json", user: user)
  end

  swagger_path :update do
    patch("/api/user/{userId}")

    parameters do
      userId(:path, :integer, "The id of the user", required: true)
      body(:body, Schema.ref(:User), "User to create", required: true)
    end

    response(200, "Updated", Schema.ref(:User))
  end

  def update(conn, params) do
    user = Users.get_user!(params["id"])

    with {:ok, %User{} = user} <- Users.update_user(user, params) do
      render(conn, "show.json", user: user)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/user/{userId}")

    parameters do
      userId(:path, :integer, "The id of the user", required: true)
    end

    response(204, "No Content")
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  swagger_path :update_batches do
    post("/api/user/{userId}/update-batches")

    parameters do
      userId(:path, :integer, "The id of the user", required: true)

      body(:body, Schema.ref(:BatchIds), "List of batch ids to update for the user",
        required: true
      )
    end

    response(200, "OK", Schema.ref(:User))
  end

  def update_batches(conn, %{"id" => user_id, "batch_ids" => batch_ids})
      when is_list(batch_ids) do
    with {:ok, %User{} = user} <- Users.update_batches(user_id, batch_ids) do
      render(conn, "show.json", user: user)
    end
  end
end
