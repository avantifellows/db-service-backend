defmodule DbserviceWeb.SchoolController do
  use DbserviceWeb, :controller

  alias Dbservice.Schools
  alias Dbservice.Schools.School

  action_fallback DbserviceWeb.FallbackController

  use PhoenixSwagger

  def swagger_definitions do
    %{
      School:
        swagger_schema do
          title("School")
          description("A school in the application")

          properties do
            code(:string, "Code")
            name(:string, "Name")
            medium(:string, "Medium")
          end

          example(%{
            code: "872931",
            name: "Kendriya Vidyalaya - Rajori Garden",
            medium: "en"
          })
        end,
      Schools:
        swagger_schema do
          title("Schools")
          description("All schools in the application")
          type(:array)
          items(Schema.ref(:School))
        end
    }
  end

  swagger_path :index do
    get("/api/school")
    response(200, "OK", Schema.ref(:Schools))
  end

  def index(conn, _params) do
    school = Schools.list_school()
    render(conn, "index.json", school: school)
  end

  swagger_path :create do
    post("/api/school")

    parameters do
      body(:body, Schema.ref(:School), "School to create", required: true)
    end

    response(201, "Created", Schema.ref(:School))
  end

  def create(conn, params) do
    with {:ok, %School{} = school} <- Schools.create_school(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.school_path(conn, :show, school))
      |> render("show.json", school: school)
    end
  end

  swagger_path :show do
    get("/api/school/{schoolId}")

    parameters do
      schoolId(:path, :integer, "The id of the school", required: true)
    end

    response(200, "OK", Schema.ref(:School))
  end

  def show(conn, %{"id" => id}) do
    school = Schools.get_school!(id)
    render(conn, "show.json", school: school)
  end

  swagger_path :update do
    patch("/api/school/{schoolId}")

    parameters do
      schoolId(:path, :integer, "The id of the school", required: true)
      body(:body, Schema.ref(:School), "School to create", required: true)
    end

    response(200, "Updated", Schema.ref(:School))
  end

  def update(conn, params) do
    school = Schools.get_school!(params["id"])

    with {:ok, %School{} = school} <- Schools.update_school(school, params) do
      render(conn, "show.json", school: school)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/school/{schoolId}")

    parameters do
      schoolId(:path, :integer, "The id of the school", required: true)
    end

    response(204, "No Content")
  end

  def delete(conn, %{"id" => id}) do
    school = Schools.get_school!(id)

    with {:ok, %School{}} <- Schools.delete_school(school) do
      send_resp(conn, :no_content, "")
    end
  end
end
