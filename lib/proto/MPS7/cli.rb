require_relative "parser"

  class Cli
    extend Parser

    puts Parser::BinaryProtocol.ascii
    `proto_MPS7 txnlog.dat`
    @protocol = Parser::BinaryProtocol.new(ARGV)
    calculations = @protocol.parse
    puts Parser::BinaryProtocol.answers(calculations)
  end
