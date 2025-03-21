# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


def seed_departments
  puts "Seeding default departments...."

  departments = [
    'CITY MAYOR\'S OFFICE',
    'CITY GENERAL SERVICES OFFICE',
    'CITY ENGINEERS OFFICE',
    'CITY SOCIAL WELFARE DEVELOPMENT OFFICE'
  ]

  departments.each  do |department|
    Department.create(name: department)
  end

  puts "Seed default departments done!"
end


def seed_department_divisions
  puts "Seeding default divisions...."

  divisions = [
    ['EXECUTIVE', 'ADMINISTRATIVE'],
    ['WAREHOUSE', 'ADMINISTRATIVE', 'ACCOUNTING'],
    ['ASPHALT']
  ]

  i = 0;
  divisions.each do |division|
    i += 1
    division.each do |name|
      DepartmentDivision.create(department_id: i, division: name)
    end
  end

  puts "Seed default divisions done!"
end


def seed_system_roles
  puts "Seeding default system roles...."

  roles = ['SPECTATOR', 'DATA ENCODER', 'ADMINISTRATOR']
  roles.each do |role|
    SystemRole.create(role: role)
  end

  puts "Seed default system roles done!"
end


def seed_user_default
  puts "Seeding default admin user...."

  user_params = {
    name: 'Charlie G. Pandacan',
    designation: 'Clerk I',
    department_id: 1,
    department_division_id: 1,
    username: 'cgso.chang',
    password: 'cgso.it',
    password_confirmation: 'cgso.it',
    system_role_id: 3
  }

  User.create(user_params)

  puts "Seeding default admin user done!"
end


def seed_supply_kind
  puts "Seeding default supply kinds...."

  supplies = ['CONSTRUCTION', 'OFFICE', 'SPARE PARTS', 'AGRICULTURAL', 'ELECTRICAL', 'FOOD']
  supplies.each do |supply|
    Supply.create(kind: supply)
  end

  puts "Seed default supplies done!"
end


def seed_inspectors
  puts "Seeding default inspectors...."

  inspectors = ['LITO PAREDES', 'VICENTE ILAGAN', 'ARIEL BALINON', 'ROSSEL SERADO']
  inspectors.each do |inspector|
    Inspector.create(name: inspector)
  end

  puts "Seed default inspectors done!"
end


def seed_units
  puts "Seeding default units...."

  units = [
    { :name => 'LENGTH', :abbrev => 'lgth/s'},
    { :name => 'PIECE', :abbrev => 'pc/s' },
    { :name => 'GALLON', :abbrev => 'gal/s' },
    { :name => 'ROLL', :abbrev => 'roll/s' },
    { :name => 'KILOGRAM', :abbrev => 'kg/s' },
    { :name => 'METER', :abbrev => 'mtr/s' },
    { :name => 'SHEET', :abbrev => 'sht/s' },
    { :name => 'BOARD FEET', :abbrev => 'bd.ft.' }
  ]
  units.each do |unit|
    Unit.create(name: unit[:name], abbrev: unit[:abbrev])
  end

  puts "Seed default units done!"
end


def seed_suppliers
  puts "Seeding default suppliers...."

  suppliers = [
    { name: 'DAVAO TCM HARDWARE', address: 'PRK. DELA CRUZ, MANKILAM, TAGUM CITY'},
    { name: 'FL2 LUMBER & CONSTRUCTION SUPPLY', address: 'PRK. BAYANIHAN, BRGY. MAGUGPO WEST, TAGUM CITY'},
    { name: 'UP-TOWN INDUSTRIAL SALES, INC.', address: 'KM.5 J.P. LAUREL AVE. BAJADA, DAVAO CITY'}
  ]

  suppliers.each do |supplier|
    Supplier.create(name: supplier[:name], address: supplier[:address])
  end

  puts "Seed default suppliers done!"
end


def seed_items
  puts "Seeding default items...."

  items = [
    { :name => 'DEFORMED ROUND BAR - 16MMØ X 10.5M - GRADE 40', :unit_id => 1, :supply_id => 1 },
    { :name => 'G.I. TIE WIRE - #10', :unit_id => 5, :supply_id => 1 },
    { :name => "PLYWOOD (ORDINARY) - 4' X 8' X 9.0MM - 10MM THK", :unit_id => 7, :supply_id => 1 },
    { :name => 'WIRE MESH - 1/8"', :unit_id => 6, :supply_id => 1 },
    { :name => 'WIRE MESH - 1" GA. #16', :unit_id => 6, :supply_id => 1 },
    { :name => "COCO LUMBER - 1\" X 8\" X 10'", :unit_id => 8, :supply_id => 1 },
    { :name => "COCO LUMBER - 4\" X 8\" X 18'", :unit_id => 8, :supply_id => 1 },
  ]
  items.each do |item|
    ItemMasterlist.create(name: item[:name], unit_id: item[:unit_id], supply_id: item[:supply_id])
  end

  puts "Seed default items done!"
end


def seed_mode_of_procurements
  puts "Seeding default mode of procurements...."

  modes = ['SMALL VALUE PROCUREMENT', 'PUBLIC BIDDING', 'SHOPPING']
  modes.each do |mode|
    ModeOfProcurement.create(mode: mode)
  end

  puts "Seed default mode of procurements done!"
end


def seed_procurement_forms
  puts "Seeding default procurement forms...."

  forms = [
    { long_name: 'PURCHASE ORDER', short_name: 'po', effect: 'IN' },
    { long_name: 'REQUISITION ISSUED SLIP', short_name: 'ris', effect: 'OUT' }
  ]
  forms.each do |form|
    ProcurementForm.create(long_name: form[:long_name], short_name: form[:short_name], effect: form[:effect])
  end

  puts "Seed default procurement forms done!"
end


def seed_warehousemen
  puts "Seeding default warehousemen...."

  warehousemen = ['DOMINIC GAMPOSILAO', 'MICHAEL ALMOJUELA', 'AUTO']
  warehousemen.each do |warehouseman|
    Warehouseman.create(name: warehouseman)
  end

  puts "Seed default warehousemen done!"
end


seed_departments
seed_department_divisions
seed_system_roles
seed_user_default
seed_supply_kind
seed_inspectors
seed_units
seed_suppliers
seed_items
seed_mode_of_procurements
seed_procurement_forms
seed_warehousemen