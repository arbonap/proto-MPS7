require_relative "parser"

  class Cli
    extend Parser

    puts Parser::BinaryProtocol.ascii
    @protocol = Parser::BinaryProtocol.new(ARGV)
    calculations = @protocol.parse
    puts Parser::BinaryProtocol.answers(calculations)
  end
