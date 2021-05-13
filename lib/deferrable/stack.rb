module Deferrable
  class Stack
    def initialize(context:)
      @context = context
      @stack = []
    end

    def add(&block)
      stack.push(
        -> { context.instance_eval(&block) }
      )
    end

    def execute
      stack.pop.call until stack.empty?
    end

    private

    attr_reader :context, :stack
  end
end
