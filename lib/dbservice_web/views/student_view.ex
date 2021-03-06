defmodule DbserviceWeb.StudentView do
  use DbserviceWeb, :view
  alias DbserviceWeb.StudentView
  alias DbserviceWeb.UserView
  alias Dbservice.Repo

  def render("index.json", %{student: student}) do
    render_many(student, StudentView, "student.json")
  end

  def render("show.json", %{student: student}) do
    render_one(student, StudentView, "student.json")
  end

  def render("show_with_user.json", %{student: student}) do
    render_one(student, StudentView, "student_with_user.json")
  end

  def render("student.json", %{student: student}) do
    %{
      id: student.id,
      uuid: student.uuid,
      father_name: student.father_name,
      father_phone: student.father_phone,
      mother_name: student.mother_name,
      mother_phone: student.mother_phone,
      category: student.category,
      stream: student.stream,
      user_id: student.user_id,
      group_id: student.group_id
    }
  end

  def render("student_with_user.json", %{student: student}) do
    student = Repo.preload(student, :user)

    %{
      id: student.id,
      uuid: student.uuid,
      father_name: student.father_name,
      father_phone: student.father_phone,
      mother_name: student.mother_name,
      mother_phone: student.mother_phone,
      category: student.category,
      stream: student.stream,
      user: render_one(student.user, UserView, "user.json"),
      group_id: student.group_id
    }
  end
end
