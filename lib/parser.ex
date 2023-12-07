defmodule GenReport.Parser do
  def parse_file(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn person ->
      [name, hours, day, month, year] = String.split(person, ",")

      [
        String.downcase(name),
        String.to_integer(hours),
        String.to_integer(day),
        get_month_by_number(String.to_integer(month)),
        String.to_integer(year)
      ]
    end)
  end

  defp get_month_by_number(1), do: "janeiro"
  defp get_month_by_number(2), do: "fevereiro"
  defp get_month_by_number(3), do: "março"
  defp get_month_by_number(4), do: "abril"
  defp get_month_by_number(5), do: "maio"
  defp get_month_by_number(6), do: "junho"
  defp get_month_by_number(7), do: "julho"
  defp get_month_by_number(8), do: "agosto"
  defp get_month_by_number(9), do: "setembro"
  defp get_month_by_number(10), do: "outubro"
  defp get_month_by_number(11), do: "novembro"
  defp get_month_by_number(12), do: "dezembro"
end
