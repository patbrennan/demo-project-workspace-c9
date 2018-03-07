module Sluggable
  extend ActiveSupport::Concern
  
  included do
    before_save :generate_slug!
    class_attribute :slug_column
  end
  
  def generate_slug!
    return if self.slug
    
    new_slug = to_slug(self.send(self.class.slug_column.to_sym))
    last_char = new_slug[-1]
    
    while self.class.find_by(slug: new_slug)
      if last_char.to_i == 0
        new_slug += "-" + (last_char.to_i + 1).to_s
      else
        next_num = last_char.to_i + 1
        new_slug[-1] = next_num.to_s
      end
    end
    self.slug = new_slug
  end
  
  def to_slug(name)
    slugged = name.gsub(/[\s[^a-zA-Z0-9]]/, "-")
    slugged.gsub!(/-{2,}/, "-")
    slugged.gsub!(/\A-+|-+\z/, "")
    slugged.downcase
  end
  
  def to_param
    self.slug
  end
  
  module ClassMethods
    def sluggable_column(col_name)
      self.slug_column = col_name
    end
  end
end