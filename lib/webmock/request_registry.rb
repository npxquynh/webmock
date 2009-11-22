module WebMock

  class RequestRegistry
    include Singleton

    attr_accessor :request_stubs, :requested_signatures

    def initialize
      reset_webmock
    end

    def reset_webmock
      self.request_stubs = []
      self.requested_signatures = HashCounter.new
    end

    def register_request_stub(stub)
      request_stubs.insert(0, stub)
      stub
    end

    def registered_request?(request_signature)
      stub_for(request_signature)
    end

    def response_for_request(request_signature)
      stub = stub_for(request_signature)
      self.requested_signatures.put(request_signature)
      stub ? stub.response : nil
    end
    
    def times_executed(request_profile)
      self.requested_signatures.hash.select { |request_signature, times_executed|
        request_signature.match(request_profile)
      }.inject(0) {|sum, (_, times_executed)| sum + times_executed }
    end

    private

    def stub_for(request_signature)
      request_stubs.detect { |registered_request_stub|
        request_signature.match(registered_request_stub.request_profile)
      }
    end

  end
end
