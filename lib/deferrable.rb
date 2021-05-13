# frozen_string_literal: true

require "set"
require_relative "deferrable/stack"
require_relative "deferrable/version"

module Deferrable
  class Error < StandardError; end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def defer(&block)
    deferred_in_method = caller_locations(1, 1).first.label.to_sym

    _deferred_stack(deferred_in_method).add(&block)
  end

  def _deferred_stack(method_name)
    if instance_variable_get("@_deferred_stack_#{method_name}").is_a?(Stack)
      instance_variable_get("@_deferred_stack_#{method_name}")
    else
      instance_variable_set("@_deferred_stack_#{method_name}", Stack.new(context: self))
    end
  end

  def _reset_deferred_stack(method_name)
    instance_variable_set("@_deferred_stack_#{method_name}", nil)
  end

  def _execute_deferred_stack(method_name)
    _deferred_stack(method_name).execute
  end

  module ClassMethods
    def deferrable(*method_names)
      method_names.map(&:to_sym).each do |method_name|
        next if _deferrable?(method_name)

        _define_deferrable_method(method_name)
        _deferred_methods << method_name
      end
    end

    def _define_deferrable_method(method_name)
      original_method = instance_method(method_name)

      define_method(method_name) do |*args, **opts, &block|
        _reset_deferred_stack(method_name)

        returned_value = original_method.bind_call(self, *args, **opts, &block)
      ensure
        _execute_deferred_stack(method_name)
        returned_value
      end
    end

    def _deferrable?(method_name)
      _deferred_methods.include?(method_name)
    end

    def _deferred_methods
      @@_deferred_methods ||= Set.new
    end
  end
end
