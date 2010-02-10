# encoding: utf-8
module Mongoid #:nodoc:
  module Contexts #:nodoc:
    class Enumerable
      include Paging
      attr_reader :selector, :options, :documents

      delegate :first, :last, :to => :documents

      # Return aggregation counts of the grouped documents. This will count by
      # the first field provided in the fields array.
      #
      # Returns:
      #
      # A +Hash+ with field values as keys, count as values
      def aggregate
        counts = {}
        group.each_pair { |key, value| counts[key] = value.size }
        counts
      end

      # Gets the number of documents in the array. Delegates to size.
      def count
        @documents.size
      end

      # Groups the documents by the first field supplied in the field options.
      #
      # Returns:
      #
      # A +Hash+ with field values as keys, arrays of documents as values.
      def group
        field = @options[:fields].first
        @documents.group_by { |doc| doc.send(field) }
      end

      # Enumerable implementation of execute. Returns matching documents for
      # the selector, and adds options if supplied.
      #
      # Returns:
      #
      # An +Array+ of documents that matched the selector.
      def execute
        @documents.select { |document| document.matches?(@selector) }
      end

      # Create the new enumerable context. This will need the selector and
      # options from a +Criteria+ and a documents array that is the underlying
      # array of embedded documents from a has many association.
      #
      # Example:
      #
      # <tt>Mongoid::Contexts::Enumerable.new(selector, options, docs)</tt>
      def initialize(selector, options, documents)
        @selector, @options, @documents = selector, options, documents
      end

      # Get the largest value for the field in all the documents.
      #
      # Returns:
      #
      # The numerical largest value.
      def max(field)
        largest = @documents.inject(nil) do |memo, doc|
          value = doc.send(field)
          (memo && memo >= value) ? memo : value
        end
      end

      # Get the smallest value for the field in all the documents.
      #
      # Returns:
      #
      # The numerical smallest value.
      def min(field)
        smallest = @documents.inject(nil) do |memo, doc|
          value = doc.send(field)
          (memo && memo <= value) ? memo : value
        end
      end

      # Get one document.
      #
      # Returns:
      #
      # The first document in the +Array+
      def one
        @documents.first
      end

      # Get the sum of the field values for all the documents.
      #
      # Returns:
      #
      # The numerical sum of all the document field values.
      def sum(field)
        sum = @documents.inject(nil) do |memo, doc|
          value = doc.send(field)
          memo ? memo += value : value
        end
      end

    end
  end
end
