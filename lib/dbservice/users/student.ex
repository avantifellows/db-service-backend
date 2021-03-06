defmodule Dbservice.Users.Student do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dbservice.Users.User
  alias Dbservice.Groups.Group

  schema "student" do
    field :category, :string
    field :father_name, :string
    field :father_phone, :string
    field :mother_name, :string
    field :mother_phone, :string
    field :stream, :string
    field :uuid, :string
    belongs_to :user, User
    belongs_to :group, Group

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [
      :user_id,
      :group_id,
      :uuid,
      :father_name,
      :father_phone,
      :mother_name,
      :mother_phone,
      :category,
      :stream
    ])
    |> validate_required([:user_id, :group_id, :uuid])
  end
end
