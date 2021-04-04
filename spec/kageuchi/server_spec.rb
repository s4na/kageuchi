# frozen_string_literal: true

require "kageuchi"
require "kageuchi/server"
require "net/http"
require "uri"

RSpec.describe Kageuchi::Server do
  class RequestSender # rubocop:disable Lint/ConstantDefinitionInBlock
    def initialize
      uri = URI.parse("http://localhost:3000/hello")
      req = Net::HTTP::Get.new(uri.path)
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end

      p res
    end
  end

  before do
    port = 1234
    @server = Kageuchi::Server.new(port)

    Thread.new do
      @server.start
    end

    RequestSender.new
    sleep 1 while @server.status != :running
  end

  after do
    @server.close
  end

  describe "#start" do
    it "" do
      expect(@server.logs.first).to eq(
        {
          VERB: "GET",
          PATH: "/hello",
          VERSION: "HTTP/1.1",
          HEDERS: [
            ["Accept-Encoding", "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"],
            ["Accept", "*/*"],
            %w[User-Agent Ruby],
            ["Host", "localhost:3000"]
          ]
        }
      )
    end
  end
end
