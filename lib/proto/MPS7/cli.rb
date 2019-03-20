require "byebug"
require_relative "parser"

  class Cli
    extend Parser

    # byebug
    puts Parser::BinaryProtocol.ascii
    # Parser::BinaryProtocol.welcome
    @protocol = Parser::BinaryProtocol.new(ARGV)
    @protocol.open
    #
    # @normalization = Parser::Normalization.new(ARGV)
    # @normalization.truncate if File.open('normalized_data.csv', "a+").present?
    # @normalization.scrub
    # @normalization.normalize
  end
