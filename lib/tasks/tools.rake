namespace :tools do

  desc "Use content type properties ids insted of names in the content properties hash"
  task :properties_name_to_id => :environment do
    CB::Core::ContentType.scoped.each do |type|
      CB::Core::Content.where(content_type_id: type.id).each do |content|
        prop_names = content.properties.keys
        if prop_names[0].to_i.zero?
          type.properties.each do |prop|
            content.properties[prop.id.to_s] = content.properties[prop.name]
          end
          content.properties.delete_if {|k,v| prop_names.include?(k)}
          saved = content.save
          puts (saved ? "saved content #{content.title}" : "Could not save content #{content.title}")
        else
          puts "skipped content #{content.title}"
        end
      end
    end
  end

  desc "reset all cache counters"
  task :reset_all_counters => :environment do
    CB::Core::ContentType.scoped.each {|ct| CB::Core::ContentType.reset_counters(ct.id, :contents) }
    CB::Core::Content.scoped.each     {|c| CB::Core::Content.reset_counters(c.id, :publications)   }
  end

  task :create_user, [:nest_name, :email] => :environment do |t, args|
    CB::Core::User.create(email: args[:email],
                          nest_name: args[:nest_name],
                          password: 'testtest',
                          password_confirmation: 'testtest')
  end

  desc "initialize platform content types"
  task :set_platform_content_types => :environment do |t, args|
    cb_user = CB::Core::User.find_by_nest_name('contentbird')
    cb_user.update_attributes(platform_user: true)
    CB::Core::ContentType.owned_by(cb_user).each do |content_type|
      content_type.update_attributes(by_platform: true)
    end
    CB::Core::ContentType.basic.each do |content_type|
      content_type.update_attributes(by_platform: true)
    end
  end
end