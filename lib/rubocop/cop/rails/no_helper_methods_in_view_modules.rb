if defined?(RuboCop::Cop::Base)
  module RuboCop
    module Cop
      module Rails
        class NoHelperMethodsInViewModules < RuboCop::Cop::Base
          MSG = "Avoid helper methods in app helper modules; use view context objects and locals.".freeze

          def on_new_investigation
            nil
          end

          def on_def(node)
            add_offense(node, message: MSG)
          end

          def on_defs(node)
            add_offense(node, message: MSG)
          end
        end
      end
    end
  end
end
