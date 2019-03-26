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
      calculations = { :debit => 0,
                       :credit => 0,
                       :started_count => 0,
                       :ended_count => 0,
                       '2456938384156277127' => 0 }

      while data[index].present?
        # debit
        if data[index].unpack("C")[0]  == 0
          record = data[index..index + 21].unpack("CL>Q>G")
          puts record
          # total amount in dollars of debits
          calculations[:debit] += record[3].to_f
          # for user ID 2456938384156277127,
          if record[2] == 2456938384156277127
            # sum the dollars of debits from the user's total balance
            calculations['2456938384156277127'] += record[3].to_f
          end
          index += 21
        # credit
        elsif data[index].unpack("C")[0] == 1
          record = data[index..index + 21].unpack("CL>Q>G")
          puts record
          # total amount in dollars of credits
          calculations[:credit] += record[3].to_f
          # for user ID 2456938384156277127,
          if record[2] == 2456938384156277127
            # subtract the dollars of credits from the user's total balance
            calculations['2456938384156277127'] -= record[3].to_f
          end
          index += 21
          # StartAutopay
        elsif data[index].unpack("C")[0] == 2
          puts data[index..index + 13].unpack("CL>Q>")
          # increase the total count of how many times Autopay has been started
          calculations[:started_count] += 1
          index += 13
          # EndAutopay
        elsif data[index].unpack("C")[0] == 3
          puts data[index..index + 13].unpack("CL>Q>")
          # increase the total count of how many times Autopay has been started
          calculations[:ended_count] += 1
          index += 13
        end
      end
      calculations
    end
  end
end
