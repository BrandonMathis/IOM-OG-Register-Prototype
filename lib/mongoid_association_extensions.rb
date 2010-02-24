module Mongoid
  module Associations
    module ClassMethods

      def reflect_on_association(name)
        association = associations[name.to_s]
        association ? association : nil
      end
      
      def add_association_with_reflection_on_options(type, options)
        add_association_without_reflection_on_options(type, options)
        name = options.name.to_s
        associations[name] = {:type => type, :options => options}
      end

      alias_method_chain :add_association, :reflection_on_options
    end
  end
end