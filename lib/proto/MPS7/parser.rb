require 'csv'
require "active_support/all"
require 'active_support/time_with_zone'
require 'awesome_print'

module Parser
  class BinaryProtocol
    attr_accessor :binary_file

    def initialize(argv)
      @binary_file = argv[0]
    end

    def self.ascii
      # the artii gem creates ascii text
      # this method shells it out
      `artii proto-MPS7 Parser`
    end

    def open(binary_file)
      contents = File.open("#{binary_file}", 'rb') { |f| f.read }
    end
  end
end
