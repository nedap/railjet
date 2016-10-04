namespace :gettext do
  def files_to_translate
    Dir.glob("{app,lib,config,locale,gems,engines}/**/*.{rb,erb,haml,slim,rhtml}")
  end

  desc "write the form attributes to <locale_path>/form_attributes.rb"
  task :store_form_attributes, [:file] => :environment do |t, args|
    FastGettext.silence_errors

    require "gettext_i18n/translate_attributes"

    storage_file = args[:file] || "#{locale_path}/form_attributes.rb"
    puts "writing form translations to: #{storage_file}"

    GettextI18n::TranslateAttributes.store_form_attributes(file: storage_file)
  end

  desc "write the policy attributes to <locale_path>/policy_attributes.rb"
  task :store_policy_attributes, [:file] => :environment do |t, args|
    args.with_defau
    FastGettext.silence_errors

    require "gettext_i18n/translate_attributes"

    storage_file = args[:file] || "#{locale_path}/policy_attributes.rb"
    puts "writing form translations to: #{storage_file}"

    GettextI18n::TranslateAttributes.store_policy_attributes(file: storage_file)
  end

  desc "write validators (policy & form) attributes"
  task :store_attributes, [:form_file, :policy_file] => :environment do |t, args|
    Rake::Task["gettext:store_form_attributes", args[:form_file]].invoke
    Rake::Task["gettext:store_policy_attributes", args[:policy_file]].invoke
  end
end
