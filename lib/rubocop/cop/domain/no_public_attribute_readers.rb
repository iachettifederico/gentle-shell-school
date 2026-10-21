if defined?(RuboCop::Cop::Base)
  module RuboCop
    module Cop
      module Domain
        class NoPublicAttributeReaders < RuboCop::Cop::Base
          MSG = "Avoid public attribute readers in domain objects; use explicit query methods instead.".freeze

          def on_send(node)
            return unless node.receiver.nil?

            method_name = node.method_name
            return unless %i[attr_reader attr_writer attr_accessor].include?(method_name)

            add_offense(node)
          end
        end
      end
    end
  end
end
