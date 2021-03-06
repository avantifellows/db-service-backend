defmodule DbserviceWeb.EnrollmentRecordControllerTest do
  use DbserviceWeb.ConnCase

  import Dbservice.SchoolsFixtures

  alias Dbservice.Schools.EnrollmentRecord

  @create_attrs %{
    academic_year: "some academic_year",
    grade: "some grade",
    is_current: true
  }
  @update_attrs %{
    academic_year: "some updated academic_year",
    grade: "some updated grade",
    is_current: false
  }
  @invalid_attrs %{academic_year: nil, grade: nil, is_current: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all enrollment_record", %{conn: conn} do
      conn = get(conn, Routes.enrollment_record_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create enrollment_record" do
    test "renders enrollment_record when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.enrollment_record_path(conn, :create), enrollment_record: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.enrollment_record_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "academic_year" => "some academic_year",
               "grade" => "some grade",
               "is_current" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.enrollment_record_path(conn, :create), enrollment_record: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update enrollment_record" do
    setup [:create_enrollment_record]

    test "renders enrollment_record when data is valid", %{
      conn: conn,
      enrollment_record: %EnrollmentRecord{id: id} = enrollment_record
    } do
      conn =
        put(conn, Routes.enrollment_record_path(conn, :update, enrollment_record),
          enrollment_record: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.enrollment_record_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "academic_year" => "some updated academic_year",
               "grade" => "some updated grade",
               "is_current" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      enrollment_record: enrollment_record
    } do
      conn =
        put(conn, Routes.enrollment_record_path(conn, :update, enrollment_record),
          enrollment_record: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete enrollment_record" do
    setup [:create_enrollment_record]

    test "deletes chosen enrollment_record", %{conn: conn, enrollment_record: enrollment_record} do
      conn = delete(conn, Routes.enrollment_record_path(conn, :delete, enrollment_record))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.enrollment_record_path(conn, :show, enrollment_record))
      end
    end
  end

  defp create_enrollment_record(_) do
    enrollment_record = enrollment_record_fixture()
    %{enrollment_record: enrollment_record}
  end
end
