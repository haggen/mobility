module Mobility
=begin

Module loading ActiveRecord-specific classes for Mobility models.

=end
  module ActiveRecord
    autoload :BackendResetter,     "mobility/active_record/backend_resetter"
    autoload :ModelTranslation,    "mobility/active_record/model_translation"
    autoload :StringTranslation,   "mobility/active_record/string_translation"
    autoload :TextTranslation,     "mobility/active_record/text_translation"
    autoload :Translation,         "mobility/active_record/translation"
    autoload :UniquenessValidator, "mobility/active_record/uniqueness_validator"

    if ::ActiveRecord::VERSION::MAJOR == 5 && ::ActiveRecord::VERSION::MINOR == 0
      def changes_applied
        @previously_changed = changes
        super
      end

      def clear_changes_information
        @previously_changed = ActiveSupport::HashWithIndifferentAccess.new
        super
      end

      def previous_changes
        super.merge(@previously_changed ||= ActiveSupport::HashWithIndifferentAccess.new)
      end
    end

    def self.included(model_class)
      model_class.extend(ClassMethods)
      model_class.const_set(:UniquenessValidator,
                            Class.new(::Mobility::ActiveRecord::UniquenessValidator))
    end

    module ClassMethods
      # @return [ActiveRecord::Relation] relation extended with Mobility query methods.
      define_method ::Mobility.query_method do
        all
      end
    end
  end
end
