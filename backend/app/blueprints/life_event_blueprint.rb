class LifeEventBlueprint < Blueprinter::Base
  identifier :id

  fields :event_type, :name, :scheduled_date, :estimated_cost, :notes
  
  field :created_at do |life_event|
    life_event.created_at.iso8601
  end
  
  field :updated_at do |life_event|
    life_event.updated_at.iso8601
  end
end
