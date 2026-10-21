if defined?(RuboCop::Cop::Base)
  module RuboCop
    module Cop
      module Rails
        class NoHelperMethod < RuboCop::Cop::Base
          MSG = "Avoid helper_method in controllers; pass view state through locals.".freeze

          def on_send(node)
            return unless node.receiver.nil?
            return unless node.method_name == :helper_method

            add_offense(node, message: MSG)
          end
        end
      end
    end
  end
end
