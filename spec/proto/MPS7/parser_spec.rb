require "proto/MPS7/parser"

RSpec.describe Proto::MPS7 do
  let(:binary_path) { ["spec/proto/MPS7/txnlog_spec.dat"] }

  subject { Parser::BinaryProtocol.new(binary_path) }


  it "parses MPS7 binary protocol" do
    calculations = subject.parse

    expect(monetize(calculations[:debit])).to eq("18203.70")
    expect(monetize(calculations[:credit])).to eq("10073.36")
    expect(calculations[:started_count].to_s).to eq("10")
    expect(calculations[:ended_count].to_s).to eq("8")
    expect(monetize(calculations["2456938384156277127"])).to eq("0.00")
  end
end
