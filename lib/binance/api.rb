module Binance
  module Api
    class << self
      # Valid limits:[5, 10, 20, 50, 100, 500, 1000]
      def candlesticks!(endTime: nil, interval: nil, limit: 500, startTime: nil, symbol: nil)
        raise Error.new(message: 'interval is required') unless interval
        raise Error.new(message: 'symbol is required') unless symbol
        params = { endTime: endTime, interval: interval, limit: limit, startTime: startTime, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/klines', params: params)
      end

      def compressed_aggregate_trades!(endTime: nil, fromId: nil, limit: 500, startTime: nil, symbol: nil)
        raise Error.new(message: "symbol is required") unless symbol
        params = {
          endTime: endTime, fromId: fromId, limit: limit, startTime: startTime, symbol: symbol
        }.delete_if { |key, value| value.nil? }
        Request.send!(api_key_type: :read_info, path: '/api/v1/aggTrades', params: params)
      end

      def depth!(symbol: nil, limit: 100)
        raise Error.new(message: "symbol is required") unless symbol
        params = { limit: limit, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/depth', params: params)
      end

      def exchange_info!
        Request.send!(api_key_type: :read_info, path: '/api/v1/exchangeInfo')
      end

      def historical_trades!(symbol: nil, limit: 500, fromId: nil)
        raise Error.new(message: "symbol is required") unless symbol
        params = { fromId: fromId, limit: limit, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/historicalTrades', params: params, security_type: :market_data)
      end

      def info!(recvWindow: nil)
        timestamp = Configuration.timestamp
        params = { recvWindow: recvWindow, timestamp: timestamp }.delete_if { |key, value| value.nil? }
        Request.send!(api_key_type: :read_info, path: '/api/v3/account', params: params, security_type: :user_data)
      end

      def ping!
        Request.send!(path: '/api/v1/ping')
      end

      def ticker!(symbol: nil, type: nil)
        ticker_type = type&.to_sym
        error_message = "type must be one of: #{ticker_types.join(', ')}. #{type} was provided."
        raise Error.new(message: error_message) unless ticker_types.include? ticker_type
        path = ticker_path(type: ticker_type)
        params = symbol ? { symbol: symbol } : {}
        Request.send!(api_key_type: :read_info, path: path, params: params)
      end

      def time!
        Request.send!(path: '/api/v1/time')
      end

      def trades!(symbol: nil, limit: 500)
        raise Error.new(message: "symbol is required") unless symbol
        params = { limit: limit, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/trades', params: params)
      end

      private

      def ticker_path(type:)
        case type
        when :daily
          '/api/v1/ticker/24hr'
        when :price, :bookTicker
          "/api/v3/ticker/#{type.to_s.camelize(:lower)}"
        end
      end

      def ticker_types
        [:daily, :price, :bookTicker].freeze
      end
    end
  end
end
