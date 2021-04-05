# frozen_string_literal: true

require "kageuchi"
require "kageuchi/server"
require "net/http"
require "uri"

RSpec.describe Kageuchi::Server do
  class RequestSender # rubocop:disable Lint/ConstantDefinitionInBlock
    def initialize(host, port)
      uri = URI.parse("http://#{host}:#{port}/hello")
      request = Net::HTTP::Get.new(uri.path)
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(request)
      end
    end
  end

  let(:host) { "localhost" }
  let(:port) { 1234 }
  let(:server) { Kageuchi::Server.new(host, port) }

  before do
    Thread.new do
      server.start
    end

    RequestSender.new(host, port)
    sleep 1 while server.status != :running
  end

  after do
    server.close
  end

  describe "#start" do
    it do
      expect(server.logs.first).to eq(
        {
          VERB: "GET",
          PATH: "/hello",
          VERSION: "HTTP/1.1",
          HEDERS: [
            ["Accept-Encoding", "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"],
            ["Accept", "*/*"],
            %w[User-Agent Ruby],
            ["Host", "#{host}:#{port}"]
          ]
        }
      )
    end
  end
end
