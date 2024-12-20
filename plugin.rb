# plugin.rb
# name: discourse-five-level-categories
# about: Extends Discourse categories to support 5 levels of hierarchy
# version: 0.1
# authors: Your Name
# url: https://github.com/yourusername/discourse-five-level-categories

enabled_site_setting :five_level_categories_enabled

after_initialize do
  Category.class_eval do
    # Override default max depth
    def self.max_depth
      5
    end

    # Validate category depth
    def validate_depth
      if parent_category_id.present?
        depth = 1
        current = parent_category
        while current.parent_category.present?
          depth += 1
          current = current.parent_category
          if depth >= Category.max_depth
            errors.add(:base, I18n.t("category.errors.depth_exceeded", max_depth: Category.max_depth))
            break
          end
        end
      end
    end

    # Calculate depth for a category
    def depth
      return 0 unless parent_category_id
      parent_category.depth + 1
    end

    # Get full hierarchy path
    def full_path
      path = [self]
      current = self
      while current.parent_category.present?
        current = current.parent_category
        path.unshift(current)
      end
      path
    end
  end

  # Add depth to category serializer
  CategorySerializer.class_eval do
    attributes :depth, :full_path_names

    def depth
      object.depth
    end

    def full_path_names
      object.full_path.map(&:name).join(" > ")
    end
  end

  # Override category creation/editing in admin
  add_to_serializer(:basic_category, :can_have_children) do
    object.depth < Category.max_depth
  end
end

# config/locales/server.en.yml
register_asset "config/locales/server.en.yml", :server_localization

# config/locales/client.en.yml
register_asset "config/locales/client.en.yml", :client_localization


