class EvidencePdfReport
  PAGE_WIDTH = 595
  PAGE_HEIGHT = 842
  LEFT_MARGIN = 48
  TOP = 790
  LINE_HEIGHT = 15
  LINES_PER_PAGE = 44

  def initialize(evidence:, movements:)
    @evidence = evidence
    @movements = movements
  end

  def render
    pages = build_lines.each_slice(LINES_PER_PAGE).to_a
    build_pdf(pages)
  end

  private

  def build_lines
    lines = []
    lines << [16, "DIGITAL CUSTODY - INFORME DE EVIDENCIA"]
    lines << [12, "#{@evidence.code} - #{@evidence.name}"]
    lines << [10, ""]
    lines << [12, "DATOS GENERALES"]
    lines.concat(wrapped("Caso: #{@evidence.case.code} - #{@evidence.case.title}"))
    lines.concat(wrapped("Tipo: #{@evidence.evidence_type.name}"))
    lines.concat(wrapped("Estado: #{@evidence.status.humanize}"))
    lines.concat(wrapped("Custodio actual: #{@evidence.current_custodian.name}"))
    lines.concat(wrapped("Ubicacion: #{@evidence.location.presence || '-'}"))
    lines.concat(wrapped("Fecha de recoleccion: #{@evidence.collected_at.strftime('%d/%m/%Y %H:%M')}"))
    lines.concat(wrapped("Descripcion: #{@evidence.description.presence || 'Sin descripcion'}"))
    lines << [10, ""]
    lines << [12, "CADENA DE CUSTODIA"]

    if @movements.any?
      @movements.each_with_index do |movement, index|
        origin = movement.from_user&.name || "Ingreso inicial"
        text = "#{index + 1}. #{movement.transferred_at.strftime('%d/%m/%Y %H:%M')} | #{origin} -> #{movement.to_user.name} | #{movement.reason} | Registrado por: #{movement.performed_by.name}"
        lines.concat(wrapped(text))
      end
    else
      lines << [10, "No hay movimientos de custodia registrados."]
    end

    lines << [10, ""]
    lines << [9, "Documento generado por Digital Custody."]
    lines
  end

  def wrapped(text, width = 86)
    plain = I18n.transliterate(text.to_s)
    words = plain.split
    result = []
    current = +""

    words.each do |word|
      candidate = current.empty? ? word : "#{current} #{word}"
      if candidate.length > width
        result << [10, current]
        current = word
      else
        current = candidate
      end
    end

    result << [10, current] unless current.empty?
    result
  end

  def build_pdf(pages)
    objects = []
    page_object_numbers = []
    font_object_number = 3 + (pages.length * 2)

    pages.each_with_index do |page_lines, index|
      page_number = 3 + (index * 2)
      content_number = page_number + 1
      page_object_numbers << page_number

      content = page_content(page_lines)
      objects[page_number] = "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 #{PAGE_WIDTH} #{PAGE_HEIGHT}] /Resources << /Font << /F1 #{font_object_number} 0 R >> >> /Contents #{content_number} 0 R >>"
      objects[content_number] = "<< /Length #{content.bytesize} >>\nstream\n#{content}\nendstream"
    end

    kids = page_object_numbers.map { |number| "#{number} 0 R" }.join(" ")
    objects[1] = "<< /Type /Catalog /Pages 2 0 R >>"
    objects[2] = "<< /Type /Pages /Kids [#{kids}] /Count #{pages.length} >>"
    objects[font_object_number] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"

    assemble(objects)
  end

  def page_content(lines)
    commands = ["BT", "#{LEFT_MARGIN} #{TOP} Td"]

    lines.each do |size, text|
      commands << "/F1 #{size} Tf"
      commands << "(#{escape_pdf(text)}) Tj"
      commands << "0 -#{LINE_HEIGHT} Td"
    end

    commands << "ET"
    commands.join("\n")
  end

  def escape_pdf(text)
    I18n.transliterate(text.to_s)
        .encode("ASCII", invalid: :replace, undef: :replace, replace: "?")
        .gsub("\\", "\\\\")
        .gsub("(", "\\(")
        .gsub(")", "\\)")
  end

  def assemble(objects)
    pdf = +"%PDF-1.4\n"
    offsets = Array.new(objects.length, 0)

    (1...objects.length).each do |number|
      next unless objects[number]

      offsets[number] = pdf.bytesize
      pdf << "#{number} 0 obj\n#{objects[number]}\nendobj\n"
    end

    xref_offset = pdf.bytesize
    pdf << "xref\n0 #{objects.length}\n"
    pdf << "0000000000 65535 f \n"

    (1...objects.length).each do |number|
      pdf << format("%010d 00000 n \n", offsets[number])
    end

    pdf << "trailer\n<< /Size #{objects.length} /Root 1 0 R >>\n"
    pdf << "startxref\n#{xref_offset}\n%%EOF\n"
    pdf
  end
end
