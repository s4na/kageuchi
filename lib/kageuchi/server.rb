# frozen_string_literal: true

require "socket"

module Kageuchi
  class Server
    attr_reader :status, :logs

    def initialize(host = "localhost", port = 3000)
      @host = host
      @port = port
      @logs = []
      @status = :created
    end

    def start
      @server = TCPServer.open(@host, @port)

      loop do
        @socket = @server.accept
        @status = :running
        next unless handle

        request_close
      end
    end

    def close
      @server.close
      @status = :closed
    end

    private

    def handle
      request_params = @socket.gets.chomp.match(/^(?<verb>[A-Z]*) (?<path>[^ ]*) (?<ver>.*)$/)
      if request_params
        headers = set_headers
        request = set_request(request_params, headers)
        pp request
        @logs << request
      end
      !headers.nil?
    end

    def set_request(request_params, headers)
      {
        VERB: request_params[:verb],
        PATH: request_params[:path],
        VERSION: request_params[:ver],
        HEDERS: headers
      }
    end

    def set_headers
      headers = []
      while line = @socket.gets.chomp
        break if line.bytesize.zero?

        headers << line.split(": ")
      end
      headers
    end

    def request_close
      @socket.write "HTTP/1.1 200 OK\r\n"
      @socket.write "\r\n"
      @socket.write "Hello. This is Kageuchi server\r\n"
      @socket.close
    end
  end
end
