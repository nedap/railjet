# Railjet, architecture for high-speed railway

![Railjet](https://www.swisspasses.com/railpass/popup/railjet/slideshow/RailJet-Zuerich-St.-Anton-Transfer-Ticket-from-Swisspasses.com.jpg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'railjet'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install railjet

## Usage

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
AppRegistry = Railjet::Repository::Registry.new

AppRegistry.register(:employee, EmployeeRepository, query: Employee, cupido: Cupido::Employee)
AppRegistry.register(:event,    EventRepository,    query: Event)
```

```ruby
# app/repositories/employee_repository.rb
class EmployeeRepository
  include Railjet::Repository
  include Railjet::Repository::ActiveRecordRepository
  include Railjet::Repository::CupidoRepository
  
  def find_contract(employee)
    cupido.find(employee.id).contract_agreement
  end
  
  def employees_with_contract
    query.all.select { |e| find_contract(e).present? }
  end
end

# app/repositories/event_repository.rb
class EventRepository
  include Railjet::Repository
  include Railjet::Repository::ActiveRecordRepository
  
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

### UseCase

```ruby
class UseCase::EditEvent
  include Railjet::UseCase
  
  # auth module is described below
  check_ability :can_edit_event?  
  
  # policy module is described below
  check_policy { |event| policy(EventEmployeeHasContract, event) } 
  
  context      :current_employee
  repositories :events
  
  def call(id, form)
    event = events.find_by_id(id)
    
    with_requirements_check(event) do
      event.attributes = form.attributes
      events.persist(event, as: current_employee)
    end
  end
end
```

### Auth
```ruby
# app/auth/ability.rb
class Auth::Ability < Railjet::Auth::Ability

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
class Auth::Event::Edit < Railjet::Auth::Activity
  def can_be_edited_by?(actor)
  end
  
  def can_be_taken_over_by?(actor)
  end
end

# app/auth/event/delete.rb
class Auth::Event::Delete < Railjet::Auth::Activity
  def can_be_deleted_by?(actor)
  end
end
```

### Policy

```ruby
class EventEmployeeHasContract
  object  :event
  context :repository
  
  validate :employee_has_contract
  
  private
  
  def employee_has_contract
    errors.add(:employee, "Inactive Employee") unless repository.employees.find_contract(event.employee)
  end
end
```

### Form

Form is a decorator for request params.
In normal Rails app params are just strings, and they're coerced inside ActiveRecord model. We definitely don't want that. We want to coerce and validate as soon as possible.

Of course, not validations are possible to perform in Form object. It doesn't have access to the context, so there are no settings, no repository. Do as much as possible here, and put more complex stuff in policies

```ruby
class EditForm
  include Railjet::Form
  
  attribute :name,        String
  attribute :date,        Date
  attribute :employee_id, Integer
  
  validates_presence_of :name, :date
end
```

### Let's connect everything!

```ruby
# app/context.rb
class AppContext < Railjet::Context
  def initialize(current_employee:, repository:)
    super
  end
end
```

```ruby
# app/controller/events_controller.rb
class EventsController < ApplicationController
  include Railjet::Util::UseCaseHelper
  include Railjet::Util::FormHelper

  def edit
    form  = form(EditForm) # this will raise exception if validation rules are not met
    event = use_case(UseCase::EditEvent).call(params[:id], form)

    respond_with event
  end
  
  private
  
  # we need context that will be injected to domain objects
  def context
    AppContext.new(
      current_employee: current_employee,
      repository:       repository
    )
  end
  
  def repository
    AppRegistry.new(settings: care_provider_settings)
  end
  
  def object_params
    params[:event]
  end
  
  # This one is not necessary, but if you need to do something with params
  # before they go into the form, this is the place:
  def clean_params
    dirty_params = super # this calls #object_params
    dirty_params.select { |k,v| v.present? }
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nedap/ons-context.

