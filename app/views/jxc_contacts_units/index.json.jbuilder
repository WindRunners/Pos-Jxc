if @staffs.present?
  json.array!(@staffs) do |staff|
    json.extract! staff, :id
    json.url staff_url(staff, format: :json)
  end
end

if @jxc_contacts_units.present?
  json.array!(@jxc_contacts_units) do |jxc_contacts_unit|
    json.extract! jxc_contacts_unit, :id
    json.url jxc_contacts_unit_url(jxc_contacts_unit, format: :json)
  end
end