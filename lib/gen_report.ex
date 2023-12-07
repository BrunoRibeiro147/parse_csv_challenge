defmodule GenReport do
  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(path) when is_binary(path) do
    parsed_csv = GenReport.Parser.parse_file(path)

    workers_hours = calculate_worked_hours(parsed_csv, %{})

    build_report(workers_hours)
  end

  def build(_path), do: {:error, "Insira o nome de um arquivo"}

  defp build_report(workers_hours) do
    report = %{"all_hours" => %{}, "hours_per_month" => %{}, "hours_per_year" => %{}}

    workers = Map.keys(workers_hours)

    Enum.reduce(workers, report, fn worker_name, acc ->
      worker = Map.get(workers_hours, worker_name)

      all_hours =
        acc
        |> Map.get("all_hours")
        |> Map.put(worker_name, worker["all_hours"])

      hours_per_month =
        acc
        |> Map.get("hours_per_month")
        |> Map.put(worker_name, worker["months"])

      hours_per_year =
        acc
        |> Map.get("hours_per_year")
        |> Map.put(worker_name, worker["years"])

      acc
      |> Map.put("all_hours", all_hours)
      |> Map.put("hours_per_month", hours_per_month)
      |> Map.put("hours_per_year", hours_per_year)
    end)
  end

  defp calculate_worked_hours([], acc), do: acc

  defp calculate_worked_hours([head | tail], acc) do
    [current_name, hours, _day, month, year] = head

    case Map.get(acc, current_name) do
      nil ->
        worker = %{
          "all_hours" => hours,
          "months" => %{"#{month}" => hours},
          "years" => %{year => hours}
        }

        calculate_worked_hours(tail, Map.put(acc, current_name, worker))

      worker ->
        worker = update_worker_hours(worker, hours, month, year)

        calculate_worked_hours(tail, Map.put(acc, current_name, worker))
    end
  end

  defp update_worker_hours(worker, hours, month, year) do
    worker
    |> calculate_all_hours(hours)
    |> calculate_month_hours(month, hours)
    |> calculate_year_hours(year, hours)
  end

  defp calculate_all_hours(worker, hours),
    do: Map.put(worker, "all_hours", worker["all_hours"] + hours)

  defp calculate_month_hours(worker, month, hours) do
    case get_in(worker, ["months", month]) do
      nil -> put_in(worker, ["months", month], hours)
      value -> put_in(worker, ["months", month], value + hours)
    end
  end

  defp calculate_year_hours(worker, year, hours) do
    case get_in(worker, ["years", year]) do
      nil -> put_in(worker, ["years", year], hours)
      value -> put_in(worker, ["years", year], value + hours)
    end
  end
end
