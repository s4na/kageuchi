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
        socket = @server.accept
        request_params = socket.gets.chomp.match(/^(?<verb>[A-Z]*) (?<path>[^ ]*) (?<ver>.*)$/)
        if request_params
          headers = []
          while line = socket.gets.chomp
            break if line.bytesize.zero?

            headers << line.split(": ")
          end
          request = {
            VERB: request_params[:verb],
            PATH: request_params[:path],
            VERSION: request_params[:ver],
            HEDERS: headers
          }
          pp request
          @logs << request
        end

        @status = :running
        next unless line.bytesize.zero?

        socket.write "HTTP/1.1 200 OK\r\n"
        socket.write "\r\n"
        socket.write "Hello. This is Kageuchi server\r\n"
        socket.close
      end
    end

    def close
      @server.close
      @status = :closed
    end
  end
end
