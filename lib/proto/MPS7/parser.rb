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

    # byte_data = contents.bytes.slice(9..-1)
    # header = ["MPS7", 1, 1191182336]
    def open
      contents = File.open("#{binary_file}", 'rb') { |f| f.read }
      header = contents.unpack("a4CL>")

      data = contents.bytes.slice!(9..-1).pack("C*")
      index = 0

      while data[index].present?
        # byebug
        if data[index].unpack("C")[0]  == 0 || data[index].unpack("C")[0] == 1
          puts data[index..index + 21].unpack("CL>Q>G")
          index += 21
        else
          puts data[index..index + 13].unpack("CL>Q>")
          index += 13
        end
      end
    end
  end
end
