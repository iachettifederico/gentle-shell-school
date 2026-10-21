if defined?(RuboCop::Cop::Base)
  module RuboCop
    module Cop
      module Rails
        class HelperMethodAfterDefinition < RuboCop::Cop::Base
          MSG_SINGLE = "Use one helper_method declaration per line.".freeze
          MSG_AFTER_DEFINITION = "Declare helper_method on the line immediately after its method definition.".freeze

          def on_class(node)
            check_helper_method_placement(node)
          end

          def on_module(node)
            check_helper_method_placement(node)
          end

          private

          def check_helper_method_placement(node)
            children = class_children(node)
            return if children.empty?

            children.each_with_index do |child, index|
              next unless helper_method_call?(child)

              check_helper_method_call(children, index, child)
            end
          end

          def check_helper_method_call(children, index, child)
            helpers = helper_arguments(child)

            if helpers.size > 1
              add_offense(child, message: MSG_SINGLE)
              return
            end

            check_definition_position(children, index, helpers)
          end

          def class_children(node)
            body = node.body
            return [] unless body

            return body.children if body.begin_type?

            [body]
          end

          def check_definition_position(children, index, helpers)
            child = children[index]
            previous_node = children[index - 1]

            return if helpers.any? do |helper_name|
              helper_definition_precedes?(previous_node, helper_name, child)
            end

            add_offense(child, message: MSG_AFTER_DEFINITION)
          end

          def helper_method_call?(node)
            node.send_type? &&
              node.method_name == :helper_method &&
              node.receiver.nil?
          end

          def helper_arguments(node)
            node.arguments.filter_map { |argument| helper_name(argument) }
          end

          def helper_name(argument)
            case argument
            when RuboCop::AST::Node
              case argument.type
              when :sym, :str
                argument.children.first
              end
            end
          end

          def matching_definition?(previous_node, helper_name)
            previous_node&.def_type? && previous_node.method_name == helper_name
          end

          def helper_definition_precedes?(previous_node, helper_name, helper_node)
            matching_definition?(previous_node, helper_name) &&
              matching_definition_on_next_line?(previous_node, helper_node)
          end

          def matching_definition_on_next_line?(previous_node, helper_node)
            return false if previous_node.nil? || helper_node.nil?

            previous_node.loc.last_line == helper_node.loc.first_line - 1
          end
        end
      end
    end
  end
end
