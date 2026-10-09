if Rails.env.production? && ENV["ALLOW_DEMO_SEEDS"] != "true"
  puts "No se cargarán datos de demostración en producción."
  return
end

admin = User.find_or_initialize_by(email: "admin@example.com")
admin.update!(
  name: "Administrador",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  active: true
)

juan = User.find_or_initialize_by(email: "juan@example.com")
juan.update!(
  name: "Juan Pérez",
  password: "password123",
  password_confirmation: "password123",
  role: :analyst,
  active: true
)

maria = User.find_or_initialize_by(email: "maria@example.com")
maria.update!(
  name: "María López",
  password: "password123",
  password_confirmation: "password123",
  role: :analyst,
  active: true
)

evidence_types = {
  "Disco rígido" => "Unidad de almacenamiento magnético.",
  "SSD" => "Unidad de almacenamiento de estado sólido.",
  "Pendrive" => "Dispositivo de almacenamiento USB.",
  "Smartphone" => "Dispositivo móvil.",
  "Archivo digital" => "Archivo incorporado como evidencia."
}

types_by_name = evidence_types.to_h do |name, description|
  type = EvidenceType.find_or_initialize_by(name:)
  type.update!(description:)
  [name, type]
end

case_one = Case.find_or_initialize_by(code: "CAS-2026-001")
case_one.update!(
  title: "Incidente de seguridad en equipo administrativo",
  description: "Análisis de un equipo posiblemente comprometido perteneciente al área administrativa.",
  status: :open,
  opened_at: Time.zone.local(2026, 9, 16, 9, 0),
  closed_at: nil
)
case_one.analyst_ids = [juan.id, maria.id]

case_two = Case.find_or_initialize_by(code: "CAS-2026-002")
case_two.update!(
  title: "Análisis de dispositivo externo",
  description: "Revisión técnica de un dispositivo de almacenamiento externo.",
  status: :open,
  opened_at: Time.zone.local(2026, 9, 16, 10, 0),
  closed_at: nil
)
case_two.analyst_ids = [juan.id]

register_evidence = lambda do |attributes, custodian|
  evidence = Evidence.find_or_initialize_by(code: attributes.fetch(:code))

  if evidence.new_record?
    evidence.assign_attributes(attributes.merge(current_custodian: custodian))
    EvidenceRegistrationService.call(evidence:, performed_by: admin)
  else
    evidence.update!(attributes.except(:code))
    if evidence.custody_movements.none?
      evidence.custody_movements.create!(
        from_user: nil,
        to_user: evidence.current_custodian,
        performed_by: admin,
        transferred_at: Time.current,
        reason: "Registro inicial"
      )
    end
  end
end

register_evidence.call(
  {
    code: "EVD-2026-001",
    name: "Disco Seagate 1TB",
    description: "Disco rígido retirado del equipo administrativo para análisis.",
    case: case_one,
    evidence_type: types_by_name.fetch("Disco rígido"),
    status: :in_custody,
    collected_at: Time.zone.local(2026, 9, 16, 9, 15),
    location: "Laboratorio de análisis"
  },
  juan
)

register_evidence.call(
  {
    code: "EVD-2026-002",
    name: "Pendrive Kingston 32GB",
    description: "Dispositivo USB encontrado conectado al equipo investigado.",
    case: case_one,
    evidence_type: types_by_name.fetch("Pendrive"),
    status: :registered,
    collected_at: Time.zone.local(2026, 9, 16, 9, 30),
    location: "Depósito de evidencias"
  },
  maria
)

register_evidence.call(
  {
    code: "EVD-2026-003",
    name: "SSD Samsung 500GB",
    description: "Unidad de estado sólido recibida para análisis técnico.",
    case: case_two,
    evidence_type: types_by_name.fetch("SSD"),
    status: :under_analysis,
    collected_at: Time.zone.local(2026, 9, 16, 10, 15),
    location: "Laboratorio de análisis"
  },
  juan
)

puts "Datos de demostración preparados."
puts "Administrador: admin@example.com / password123"
