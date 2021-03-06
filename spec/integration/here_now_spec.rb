require 'spec_helper'

describe Pubnub::HereNow do
  around(:each) do |example|
    @response_output = StringIO.new
    @message_output = StringIO.new

    @callback = lambda { |envelope|
      Pubnub.logger.debug 'FIRING CALLBACK FROM TEST'
      @response_output.write envelope.response
      @message_output.write envelope.msg
      @after_callback = true
    }

    @error_callback = lambda { |envelope|
      Pubnub.logger.debug 'FIRING ERROR CALLBACK FROM TEST'
      @response_output.write envelope.response
      @message_output.write envelope.msg
      @after_error_callback = true
    }

    @pn = Pubnub.new(:max_retries => 0, :subscribe_key => :demo, :publish_key => :demo, :auth_key => :demoish_authkey, :secret_key => 'some_secret_key', :error_callback => @error_callback)
    @pn.uuid = 'rubytests'

    Celluloid.boot
    example.run
    Celluloid.shutdown
  end

  context "uses ssl" do
    before(:each) { @ssl = true }
    context "passess callback as block" do
      context "gets valid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-block-valid-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", &@callback)
                
                @after_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq 'OK'
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-block-valid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", &@callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq '[0,"Non 2xx server response."]'
              end
            end
          end
        end
      end
      context "gets invalid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-block-invalid-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", &@callback)

                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                @message_output.seek 0
                @message_output.read.should eq '[0,"Invalid JSON in response."]'
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-block-invalid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", &@callback)

                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                @message_output.seek 0
                @message_output.read.should eq '[0,"Invalid JSON in response."]'
              end
            end
          end
        end
      end
    end
    context "passess callback as parameter" do
      context "gets valid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-parameter-valid-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", :callback => @callback)

                @after_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq 'OK'
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-parameter-valid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", :callback => @callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq '[0,"Non 2xx server response."]'
              end
            end
          end
        end
      end
      context "gets invalid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-parameter-invalid-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", :callback => @callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                @message_output.seek 0
                @message_output.read.should eq '[0,"Invalid JSON in response."]'
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-ssl-parameter-invalid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => true, :http_sync => true, :channel => "demo", :callback => @callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                @message_output.seek 0
                @message_output.read.should eq '[0,"Invalid JSON in response."]'
              end
            end
          end
        end
      end
    end
  end
  context "uses non-ssl" do
    before(:each) { @ssl = false }
    context "passess callback as block" do
      context "gets valid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-block-valid-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", &@callback)
                
                @after_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq 'OK'
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-block-valid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", &@callback)

                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq '[0,"Non 2xx server response."]'
              end
            end
          end
        end
      end
      context "gets invalid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-block-invalid-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", &@callback)
                
                eventually do
                  @after_error_callback.should eq true
                  @response_output.seek 0
                  @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                  @message_output.seek 0
                  @message_output.read.should eq '[0,"Invalid JSON in response."]'
                end
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-block-invalid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", &@callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                @message_output.seek 0
                @message_output.read.should eq '[0,"Invalid JSON in response."]'
              end
            end
          end
        end
      end
    end
    context "passess callback as parameter" do
      context "gets valid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-parameter-valid-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", :callback => @callback)
                
                @after_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq 'OK'
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-parameter-valid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", :callback => @callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq "{\"status\": 200, \"message\": \"OK\", \"service\": \"Presence\", \"uuids\": [\"rubytest\"], \"occupancy\": 1}"
                @message_output.seek 0
                @message_output.read.should eq '[0,"Non 2xx server response."]'
              end
            end
          end
        end
      end
      context "gets invalid json in response" do
        context "gets status 200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-parameter-invalid-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", :callback => @callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                @message_output.seek 0
                @message_output.read.should eq '[0,"Invalid JSON in response."]'
              end
            end
          end
        end
        context "gets status non-200 in response" do
          context "uses sync connection" do
            it 'works fine' do
              VCR.use_cassette("integration/here_now/here_now-nonssl-parameter-invalid-non-200-sync", :record => :none) do
                @pn.here_now(:ssl => false, :http_sync => true, :channel => "demo", :callback => @callback)
                
                @after_error_callback.should eq true
                @response_output.seek 0
                @response_output.read.should eq '{"uuids":["rubytests"],"occupancy":1'
                @message_output.seek 0
                @message_output.read.should eq '[0,"Invalid JSON in response."]'
              end
            end
          end
        end
      end
    end
  end
end
