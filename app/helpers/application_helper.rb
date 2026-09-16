module ApplicationHelper
  def human_status(value)
    {
      "open" => "Abierto",
      "closed" => "Cerrado",
      "registered" => "Registrada",
      "in_custody" => "En custodia",
      "under_analysis" => "En análisis",
      "archived" => "Archivada"
    }.fetch(value.to_s, value.to_s.humanize)
  end

  def human_role(value)
    { "admin" => "Administrador", "analyst" => "Analista" }.fetch(value.to_s, value.to_s.humanize)
  end

  def format_datetime(value)
    value&.strftime("%d/%m/%Y %H:%M") || "—"
  end
end
