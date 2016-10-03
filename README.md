# Ons::Context

Use Design Patterns, goddammit!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ons-context'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ons-context

## Usage

### Auth
```ruby
# app/auth/ability.rb
class Auth::Ability < OnsContext::Auth::Ability

  def can_edit_event?(event)
    activity(Auth::Event::Edit, event).can_be_edited_by?(actor)
  end
  
  def can_take_over_event?(event)
    activity(Auth::Event::Edit, event).can_be_taken_over_by?(actor)
  end
  
  def can_delete_event?(event)
    activity(Auth::Event::Delete, event).can_be_deleted_by?(actor)
  end
end
```

```ruby
# app/auth/event/edit.rb
class Auth::Event::Edit < OnsContext::Auth::Activity
  def can_be_edited_by?(actor)
  end
  
  def can_be_taken_over_by?(actor)
  end
end

# app/auth/event/delete.rb
class Auth::Event::Delete < OnsContext::Auth::Activity
  def can_be_deleted_by?(actor)
  end
end
```

### Repository

Assuming your app has 2 ActiveRecord models and uses 1 Cupido object

```ruby
class Employee < ActiveRecord::Base
  has_many :events
end

class Event < ActiveRecord::Base
  belongs_to :employee
end
```

```ruby
# app/repositories/registry.rb
AppRegistry = Class.new(OnsContext::Repository::Registry)

AppRegistry.register(:employee, EmployeeRepository, query: Employee, cupido: Cupido::Employee)
AppRegistry.register(:event, EventRepository, query: Event)
```

```ruby
# app/repositories/employee_repository.rb
class EmployeeRepository
  include OnsContext::Repository
  include OnsContext::Repository::ActiveRecordRepository
  include OnsContext::Repository::CupidoRepository
  
  def find_contract(employee)
    cupido.find(employee.id).contract_agreement
  end
  
  def employees_with_contract
    query.all.select { |e| find_contract(e).present? }
  end
end

# app/repositories/event_repository.rb
class EventRepository
  include OnsContext::Repository
  include OnsContext::Repository::ActiveRecordRepository
  
  def find_for_employee(employee)
    query.where(employee_id: employee.id).select(query_columns)
  end
  
  def events_for_active_employees
    registry.employees.employees_with_contract.map do |e|
      find_for_employee(employee)
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nedap/ons-context.

