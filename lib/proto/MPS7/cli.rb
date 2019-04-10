require "byebug"
require_relative "parser"

  class Cli
    extend Parser

    puts Parser::BinaryProtocol.ascii
    @protocol = Parser::BinaryProtocol.new(ARGV)
    @protocol.open
  end
