module OnsContext
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/gettext_i18n.rake'
    end
  end
end
