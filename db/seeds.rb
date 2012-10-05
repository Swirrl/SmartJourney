# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

zone = Zone.new('http://zone')
zone.rdf_type = Zone.rdf_type
zone.label = "My First Zone"
zone.save!

report_type = ReportType.new("http://testreporttype")
report_type.label = "Report Type 1"
report_type.save!