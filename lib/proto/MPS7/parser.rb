require 'csv'
require "active_support/all"
require 'active_support/time_with_zone'
require 'awesome_print'

module Parser
  class BinaryProtocol
    def self.ascii
      # the artii gem creates ascii text
      # this method shells it out
      `artii proto-MPS7 Parser`
    end
  end
end
