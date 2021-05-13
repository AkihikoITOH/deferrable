# frozen_string_literal: true

RSpec.describe Deferrable do
  it "has a version number" do
    expect(Deferrable::VERSION).not_to be nil
  end

  describe "a class that includes Deferrable" do
    let(:instance) { Klass.new }

    # standard:disable Lint/ConstantDefinitionInBlock,Lint/UnreachableCode
    class Klass
      include Deferrable

      class SomeError < StandardError; end

      def initialize
        @deferred_calls = []
      end

      def single_defer
        defer { deferred_call }
      end

      def multiple_defer
        defer { deferred_call(1) }
        defer { deferred_call(2) }
        defer { deferred_call(3) }
      end

      def multiple_defer_with_error
        defer { deferred_call(1) }
        defer { deferred_call(2) }

        raise SomeError

        defer { deferred_call(3) }
      end

      def multiple_defer_with_early_return
        defer { deferred_call(1) }
        defer { deferred_call(2) }

        return "early"

        defer { deferred_call(3) }
      end

      deferrable :single_defer, :multiple_defer, :multiple_defer_with_error, :multiple_defer_with_early_return

      attr_reader :deferred_calls

      private

      attr_writer :deferred_calls

      def deferred_call(id = nil)
        deferred_calls << id
      end
    end
    # standard:enable Lint/ConstantDefinitionInBlock,Lint/UnreachableCode

    context "single defer" do
      subject { instance.single_defer }

      it "calls #deferred_call once" do
        expect(instance).to receive(:deferred_call).once

        subject
      end
    end

    context "multiple defer" do
      subject { instance.multiple_defer }

      it "calls #deferred_call in LIFO" do
        expect { subject }.to change { instance.deferred_calls }.to([3, 2, 1])
      end
    end

    context "when error is raised between multiple deferred calls" do
      subject { instance.multiple_defer_with_error }

      it "calls the deferred calls until that point and raises the error" do
        expect { subject }.to change { instance.deferred_calls }.to([2, 1]).and \
          raise_error(Klass::SomeError)
      end
    end

    context "when returned early between multiple deferred calls" do
      subject { instance.multiple_defer_with_early_return }

      it "calls the deferred calls until that point and returns" do
        expect { subject }.to change { instance.deferred_calls }.to([2, 1])
        expect(subject).to eq "early"
      end
    end
  end
end
