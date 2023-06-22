defmodule Demo.Command do
  @moduledoc """
  The `Command` struct is a wrapper around each step in a document processing workflow.
  It holds a command module (e.g. `ParseHTTPRequest`), the parameters with which the
  command module should be called, and a status which indicates whether the command
  has been executed already (`:completed`) or still needs to be executed (`:pending`).

  It also includes the position of the command in the overall workflow and it stores
  the result of the command in the `:result` field. The result can be passed on to
  the next command and it can be used for auditing the result of each command.

  The main function of this module is the `execute/3` function. It receives the workflow
  in which a command is one of the steps, the command, and the result of the command that
  was executed previously to the given command. It calls the command's module with the
  given parameter and returns the result of the command module.

  Every command module needs to implement the behaviour of this module, which means
  implementing the `execute/3` function which is called on the implementing command
  module when the commmand is executed.

  The naming of this module, the implementing command modules, and the two `execute/3`
  functions might need improvement though to avoid confusion.
  """

  defstruct [:position, :module, :params, :result, status: :pending]

  require Logger

  alias Demo.Workflows.Workflow

  @callback execute(workflow :: Workflow.t(), params :: map(), previous_result :: map()) ::
              {:ok, workflow :: Workflow.t(), result :: map() | nil} | :abort | {:error, any()}

  @spec run(Demo.Command, Workflow.t(), map()) ::
          {:ok, Workflow.t(), map()} | :abort | {:error, any()}
  def run(
        %Demo.Command{module: module, params: params} = _command,
        %Demo.Workflows.Workflow{} = workflow,
        previous_result
      ) do
    module.execute(workflow, params, previous_result)
  end

  def mark_as_completed(command) do
    mark_as(command, :completed)
  end

  def mark_as_waiting(command) do
    mark_as(command, :waiting)
  end

  defp mark_as(command, status) do
    Logger.debug("Marking Command #{command.position} - #{command.module} as #{status}")
    Map.put(command, :status, status)
  end

  def put_result(command, result) do
    Map.put(command, :result, result)
  end

  def completed?(command), do: command.status == :completed

  def complete_command(command, result) do
    command
    |> put_result(result)
    |> mark_as_completed()
  end

  @doc """
  This function is a helper function for Commands for fetching a field as defined in the
  user-provided access path (e.g. `["document", "parsed_content", "amount"]`). It handles
  the conversion of string-based access keys (e.g. `"document"`) to atom-based keys
  (e.g. `:document`) because the map from which a field needs to be fetched can have a mix
  of atom- and string-based keys.

  The function fetches the field from either the provided `Workflow` or the `previous_result`,
  depending on the first key in the access path. There are three valid first keys in the path:

  * "workflow" - Indicates that the field should be fetched from the `Workflow` struct
  * "document" - Indicates that the field should be fetsched from the `Document` struct
  of the `Workflow`
  * "previous" - Indicates that the field should be fetched from the previous result map.

  ## Examples

      iex> workflow = %Workflow{id: 123, document: %Document{parsed_content: %{"amount" => 100}}}
      %Workflow{}
      iex> previous_result = %{"decision" => "process"}
      %{"decision" => "process"}
      iex> get_field(["workflow", "id"], workflow, previous_result)
      123
      iex> get_field(["document", "parsed_content", "amount"], workflow, previous_result)
      100
      iex> get_field(["previous", "decision"], workflow, previous_result)
      "process"

  """
  @spec get_field(list(binary), Demo.Workflows.Workflow.t(), map()) :: any()
  def get_field(["workflow", field] = _path, workflow, _previous_result) do
    atom_field = String.to_existing_atom(field)
    Map.fetch!(workflow, atom_field)
  end

  def get_field(["document", field] = _path, workflow, _previous_result) do
    atom_field = String.to_existing_atom(field)
    Map.fetch!(workflow.document, atom_field)
  end

  def get_field(["document", field | rest] = _path, workflow, previous_result) do
    value = get_field(["document", field], workflow, previous_result)
    get_in(value, rest)
  end

  def get_field(["previous" | path], _workflow, previous_result) do
    get_in(previous_result, path)
  end
end
