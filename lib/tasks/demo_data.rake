namespace :demo do
  task realistic: :environment do
    admin = User.find_by!(email: "admin@example.com")
    juan = User.find_by!(email: "juan@example.com")
    maria = User.find_by!(email: "maria@example.com")

    case1 = Case.find_by!(code: "CAS-2026-001")
    case1.update!(title: "Acceso no autorizado a equipo de Tesorería", description: "Análisis de una estación de trabajo con actividad sospechosa.", status: :open)
    case1.analysts = [juan, maria]

    case2 = Case.find_by!(code: "CAS-2026-002")
    case2.update!(title: "Posible copia no autorizada mediante USB", description: "Revisión de dispositivos vinculados a una posible copia de documentación interna.", status: :open)
    case2.analysts = [juan, maria]

    case3 = Case.find_or_initialize_by(code: "CAS-2026-003")
    case3.update!(title: "Análisis de smartphone corporativo", description: "Preservación y análisis de un teléfono corporativo.", status: :open, opened_at: Time.zone.local(2026, 9, 18, 11, 20), closed_at: nil)
    case3.analysts = [juan, maria]

    phone_type = EvidenceType.find_or_create_by!(name: "Smartphone") { |t| t.description = "Dispositivo móvil." }
    phone = Evidence.find_or_initialize_by(code: "EVD-2026-004")
    if phone.new_record?
      phone.assign_attributes(name: "Samsung Galaxy S22 corporativo", description: "Teléfono preservado para análisis técnico.", case: case3, evidence_type: phone_type, current_custodian: maria, status: :in_custody, collected_at: Time.zone.local(2026, 9, 18, 11, 45), location: "Depósito de evidencias")
      EvidenceRegistrationService.call(evidence: phone, performed_by: admin)
    end

    add_chain = lambda do |evidence, a, b, c|
      [[a, "Traslado a laboratorio forense"], [b, "Asignación para análisis técnico"], [c, "Retorno a depósito de evidencias"]].each_with_index do |(to_user, reason), index|
        next if evidence.custody_movements.exists?(reason: reason)
        from_user = evidence.custody_movements.order(:transferred_at, :id).last&.to_user || evidence.current_custodian
        next if from_user == to_user
        evidence.custody_movements.create!(from_user: from_user, to_user: to_user, performed_by: admin, transferred_at: evidence.collected_at + (index + 1).hours, reason: reason)
      end
      evidence.update!(current_custodian: evidence.custody_movements.order(:transferred_at, :id).last.to_user)
    end

    add_chain.call(Evidence.find_by!(code: "EVD-2026-001"), maria, juan, maria)
    add_chain.call(Evidence.find_by!(code: "EVD-2026-003"), maria, juan, maria)
    add_chain.call(phone, juan, maria, juan)

    puts "Demo lista: 3 casos con cadenas de custodia de 4 etapas."
  end
end
