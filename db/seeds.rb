%w(text memo image markdown image_gallery email phone url).each do |name|
  CB::Core::ContentType.find_or_create_by(name: name, title: name, composite: false, by_platform: true)
end

users_data = [  {email: 'nico.nardone@gmail.com',  nest_name: 'nna', admin: true},
                {email: 'adrien.thery@gmail.com',  nest_name: 'ath', admin: true},
                {email: 'sneusch@gmail.com',       nest_name: 'sne', admin: true},
                {email: 'contact@contentbird.com', nest_name: 'contentbird', platform_user: true}  ]

users_data.each do |user_data|
  unless CB::Core::User.where(user_data).any?
    CB::Core::User.create(user_data.merge(password: 'testtest', password_confirmation: 'testtest'))
  end
end

cb_user = CB::Core::User.find_by_nest_name('contentbird')

def self.create_default_shared_content_type user, title, title_label, available_to_basic_users, picto, properties
  #create shared content type
  unless CB::Core::ContentType.where(title: title, owner_id: user.id).any?
    type = CB::Core::ContentType.create(title: title,
                                        title_label: title_label,
                                        composite: true,
                                        usable_by_default: true,
                                        owner: user,
                                        picto: picto,
                                        by_platform: true,
                                        available_to_basic_users: available_to_basic_users)
    properties.each_with_index do |(key,value), index|
      type.properties.create(title: key,  father_type_id: type.id, content_type: CB::Core::ContentType.find_by_name(value),    position: index)
    end
  end

  #give everyone a usage on this content type
  type = CB::Core::ContentType.where(title: title, owner_id: user.id).first
  CB::Core::User.where('id <> ?', user.id).each do |user|
    unless user.content_types.where(id: type.id).any?
      user.content_types << type
      user.save!
    end
  end
end

create_default_shared_content_type(cb_user, 'Post',         nil,                  true,  '&#xe607;', { 'Image'     => 'image',
                                                                                                       'Header'    => 'memo',
                                                                                                       'Body'      => 'markdown'      })

create_default_shared_content_type(cb_user, 'Photo album',  nil,                  true,  '&#xe608;', { 'Forewords' => 'memo',
                                                                                                       'Photos'    => 'image_gallery' })

create_default_shared_content_type(cb_user, 'Contact',     'First and last name', false, '&#xe609;', { 'Email'     => 'email',
                                                                                                       'Telephone' => 'phone',
                                                                                                       'Comment'   => 'memo'          })
create_default_shared_content_type(cb_user, 'Link',        nil,                   true,  '&#xe60a;', { 'Url'       => 'url',
                                                                                                       'Comment'   => 'memo'          })