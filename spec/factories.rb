FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@contentbird.com"
  end
  sequence :nest do |n|
    "nest_#{n}"
  end
  sequence :book_title do |n|
    "book_#{n}"
  end

  sequence :link_title do |n|
    "link_#{n}"
  end

  sequence :gallery_title do |n|
    "gallery_#{n}"
  end

  sequence :article_title do |n|
    "article_#{n}"
  end

  factory :user, class: CB::Core::User do
    email     { generate :email }
    nest_name { generate :nest }
    password 'testtest'
    password_confirmation 'testtest'
  end

  factory :content_type, class: CB::Core::ContentType do
    factory :basic_type do
      title 'Basic'
      composite false
      by_platform true
    end
    factory :composite_type do
      title 'Composite'
      composite true
    end
    factory :user_type  do
      title 'UserType'
      composite   true
      association :owner, :factory => :user
    end
    factory :shared_type do
      title 'Shared'
      composite true
      by_platform true
    end
  end

  factory :post_type, parent: :shared_type do
    title 'Blog'
    after(:build) do |post|
      post.properties << FactoryGirl.build(:memo_property, title: 'body',  position: 0)
    end
  end

  factory :link_type, parent: :shared_type do
    title 'Link'
    after(:build) do |link|
      link.properties << FactoryGirl.build(:text_property, title:  'Comment',   position: 0)
      link.properties << FactoryGirl.build(:url_property, title:   'Link',      position: 1)
      link.properties << FactoryGirl.build(:image_property, title: 'Thumbnail', position: 2)
    end
  end

  factory :gallery_type, parent: :shared_type do
    title 'Gallery'
    after(:build) do |gallery|
      gallery.properties << FactoryGirl.build(:text_property,    title: 'Comment',   position: 0)
      gallery.properties << FactoryGirl.build(:gallery_property, title: 'Images',    position: 1)
      gallery.properties << FactoryGirl.build(:image_property,   title: 'Portrait',  position: 2)
    end
  end

  factory :article_type, parent: :composite_type do
    title 'Article'
    after(:build) do |article|
      article.properties << FactoryGirl.build(:text_property, title: 'header', position: 0)
      article.properties << FactoryGirl.build(:memo_property, title: 'body',  position: 1)
    end
  end

  factory :book_type, parent: :user_type do
    title 'Book'
    after(:build) do |book|
      book.properties << FactoryGirl.build(:text_property,  title: 'Author',  position: 0)
      book.properties << FactoryGirl.build(:memo_property,  title: 'Summary', position: 1)
      book.properties << FactoryGirl.build(:image_property, title: 'Image',   position: 2)
    end
  end

  factory :content_property, class: CB::Core::ContentProperty do
    factory :text_property do
      content_type CB::Core::ContentType.find_or_create_by(title: 'text',          composite: false, by_platform: true)
    end
    factory :memo_property do
      content_type CB::Core::ContentType.find_or_create_by(title: 'memo',          composite: false, by_platform: true)
    end
    factory :image_property do
      content_type CB::Core::ContentType.find_or_create_by(title: 'image',         composite: false, by_platform: true)
    end
    factory :url_property do
      content_type CB::Core::ContentType.find_or_create_by(title: 'url',           composite: false, by_platform: true)
    end
    factory :gallery_property do
      content_type CB::Core::ContentType.find_or_create_by(title: 'image_gallery', composite: false, by_platform: true)
    end
  end

  factory :user_content, class: CB::Core::Content do
    title 'User content'
    association :content_type, factory: :user_type
  end

  factory :article_content, class: CB::Core::Content do
    title { generate :article_title }
    association :content_type, factory: :article_type
    association :owner, factory: :user
    after(:build) do |article|
      type_props = article.content_type.properties.to_a
      article.properties[type_props[0].id.to_s] = 'my header'
      article.properties[type_props[1].id.to_s] = 'my body'
    end
  end

  factory :book_content, class: CB::Core::Content do
    title { generate :book_title }
    association :content_type, factory: :book_type
    association :owner, factory: :user
    after(:build) do |book|
      type_props = book.content_type.properties.to_a
      book.properties[type_props[0].id.to_s] = 'my author'
      book.properties[type_props[1].id.to_s] = 'my summary'
      book.properties[type_props[2].id.to_s] = 'my_image.png'
    end
  end

  factory :link_content, class: CB::Core::Content do
    title { generate :link_title }
    association :content_type, factory: :link_type
    association :owner, factory: :user
    after(:build) do |link|
      type_props = link.content_type.properties.to_a
      link.properties[type_props[0].id.to_s] = 'a nice video'
      link.properties[type_props[1].id.to_s] = 'https://youtube.com/watch?v=1234567'
      link.properties[type_props[2].id.to_s] = nil
    end
  end

  factory :link_content_with_image, parent: :link_content do
    after(:build) do |link|
      type_props = link.content_type.properties.to_a
      link.properties[type_props[2].id.to_s] = 'img/1.jpg'
    end
  end

  factory :gallery_content, class: CB::Core::Content do
    title { generate :gallery_title }
    association :content_type, factory: :gallery_type
    association :owner, factory: :user
    after(:build) do |gallery|
      type_props = gallery.content_type.properties.to_a
      gallery.properties[type_props[0].id.to_s] = 'what a nice gallery'
      gallery.properties[type_props[1].id.to_s] = [ {'url' => 'gal/photo1.png', 'legend' => 'la photo 1'},
                                                    {'url' => 'gal/photo2.jpg', 'legend' => 'la photo 2'} ]
      gallery.properties[type_props[2].id.to_s] = 'img/portrait.jpg'
    end
  end

  factory :email, class: OpenStruct do
    to [{ raw: 'ME <me@cbird.me>', email: 'me@cbird.me', token: 'me', host: 'cbird.me' }]
    from 'sender@email.com'
    subject 'See my Birdy!'
    body 'Look at my bird, isn\'t it nice ?'
    attachments {[]}

    trait :with_attachment do
      attachments {[
        ActionDispatch::Http::UploadedFile.new({
          filename: 'img.jpeg',
          type: 'image/jpeg',
          tempfile: File.new("#{File.expand_path File.dirname(__FILE__)}/fixtures/files/bird.jpeg")
        })
      ]}
    end
  end

end