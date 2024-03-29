require "active_support/all"

module Parser
  class BinaryProtocol
    attr_accessor :binary_file

    def initialize(argv)
      @binary_file = argv[0]
    end

    def self.ascii
      # the artii gem creates ascii text
      `artii proto-MPS7 Parser`
    end

    def parse
      begin
        contents = File.open("#{binary_file}", 'rb') { |f| f.read }
      rescue Errno::ENOENT => e
        STDERR.puts "No binary file given as an argument. Please include binary file to continue."
        exit
      end
      header = contents.unpack("a4CL>")
      # header = ["MPS7", 1, 1191182336]

      index = 0
      calculations = { :debit => BigDecimal.new(0),
                       :credit => BigDecimal.new(0),
                       :started_count => 0,
                       :ended_count => 0,
                       '2456938384156277127' => BigDecimal.new(0) }

      data = contents.bytes.slice!(9..-1).pack("C*")

      while binary_data_present?(data, index)
        # debit
        if debit?(data, index)
          record = unpack_four_fields(data, index)
          # total amount in dollars of debits
          total_dollars(calculations, :debit, record)
          # for user ID 2456938384156277127,
          if for_user_id?(record, 2456938384156277127)
            # sum the dollars of debits from the user's total balance
            user_balance(calculations, 'sum', record)
          end
          index += 21
        # credit
        elsif credit?(data, index)
          record = unpack_four_fields(data, index)
          # total amount in dollars of credits
          total_dollars(calculations, :credit, record)
          # for user ID 2456938384156277127,
          if for_user_id?(record, 2456938384156277127)
            # subtract the dollars of credits from the user's total balance
            user_balance(calculations, 'difference', record)
          end
          index += 21
        # StartAutopay
        elsif start_autopay?(data, index)
          unpack_three_fields(data, index)
          # increase the total count of how many times Autopay has been started
          calculations[:started_count] += 1
          index += 13
        # EndAutopay
        elsif end_autopay?(data, index)
          unpack_three_fields(data, index)
          # increase the total count of how many times Autopay has been ended
          calculations[:ended_count] += 1
          index += 13
        else
          STDERR.puts "Binary does not follow custom protocol."
          exit
        end
      end
      calculations
    end

    def binary_data_present?(data, index)
      data[index].present?
    end

    def debit?(data, index)
      data[index].unpack("C")[0] == 0
    end

    def credit?(data, index)
      data[index].unpack("C")[0] == 1
    end

    def start_autopay?(data, index)
      data[index].unpack("C")[0] == 2
    end

    def end_autopay?(data, index)
      data[index].unpack("C")[0] == 3
    end

    def for_user_id?(record, id)
      record[2] == id
    end

    def unpack_four_fields(data, index)
      data[index..index + 21].unpack("CL>Q>G")
    end

    def unpack_three_fields(data, index)
      data[index..index + 13].unpack("CL>Q>")
    end

    def total_dollars(calculations, account, record)
      calculations[account] += record[3].to_d
    end

    def user_balance(calculations, operator, record)
      if operator == 'sum'
        calculations['2456938384156277127'] += record[3].to_d
      elsif operator == 'difference'
        calculations['2456938384156277127'] -= record[3].to_d
      end
    end

    def self.monetize(money)
      '%.2f' % money
    end

    def self.answers(calculations)
      puts <<~CALCS.strip
        $#{self.monetize(calculations[:debit])} is the total amount in dollars of debits,
        $#{self.monetize(calculations[:credit])} is the total amount of dollars of credits,
        #{calculations[:started_count]} autopays were started,
        #{calculations[:ended_count]} autopays were ended,
        user ID 2456938384156277127 has a balance of $#{self.monetize(calculations['2456938384156277127'])}.
        CALCS
    end
  end
end
