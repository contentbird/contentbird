describe Platform do

  describe '#new' do

    it 'retreives heroku credentials, connect to Heroku via its ruby client and set the default env' do
      with_heroku_env 'user', 'pwd', 'dev' do |heroku_mock|
        platform = Platform.new
        platform.client.should eq heroku_mock
        platform.env.should eq 'dev'
      end
    end

  end

  describe '#env=' do |heroku_mock|
    it "changes the current env used" do
      with_heroku_env 'user', 'pwd', 'dev' do
        platform = Platform.new
        expect{platform.env='test'}.to change{platform.env}.from('dev').to('test')
      end
    end
  end

  describe 'ps' do
    it 'should ask heroku for the processes on the current env' do
      with_heroku_env 'user', 'pwd', 'dev' do |heroku_mock|
        platform = Platform.new
        heroku_mock.should_receive(:get_ps).with('dev').and_return double('heroku_response', body: 'my processes')
        platform.ps.should eq 'my processes'
      end
    end
    it 'should filter the process type if this info was passed as a parameter' do
      with_heroku_env 'user', 'pwd', 'dev' do |heroku_mock|
        platform = Platform.new
        heroku_mock.should_receive(:get_ps).with('dev').and_return double('heroku_response', body: [{'process' => 'photo_worker.1'}, {'process' => 'web.1'}])
        platform.ps('web').should eq [{'process' => 'web.1'}]
      end
    end
  end

  describe 'ps_scale' do
    it 'should ask heroku to scale the given process type to the given amount of process' do
      with_heroku_env 'user', 'pwd', 'dev' do |heroku_mock|
        platform = Platform.new
        heroku_mock.should_receive(:post_ps_scale).with('dev', 'web', 3).and_return (excon_mock = double('heroku_response', body: '3'))
        platform.ps_scale('web',3).should eq '3'
      end
    end
  end

  describe 'ps_restart' do
    it 'should ask heroku to restart the given process' do
      with_heroku_env 'user', 'pwd', 'dev' do |heroku_mock|
        platform = Platform.new
        heroku_mock.should_receive(:post_ps_restart).with('dev', 'ps' => 'web.1').and_return (excon_mock = double('heroku_response', body: 'ok'))
        platform.ps_restart('web.1').should eq 'ok'
      end
    end
  end

  describe 'ps_count' do
    it 'should ask heroku the number of workers of given type' do
      with_heroku_env 'user', 'pwd', 'dev' do |heroku_mock|
        platform = Platform.new
        heroku_mock.stub(:get_ps).with('dev').and_return(excon_mock = double('heroku_response'))
        excon_mock.stub(:body).and_return [{'process' => 'photo_worker.1'}, {'process' => 'web.1'}, {'process' => 'web.2'}]

        platform.ps_count.should eq 3
        platform.ps_count('web').should eq 2
        platform.ps_count('photo_worker').should eq 1
      end
    end
  end

  describe 'web scaling' do
    before do
      with_heroku_env 'user', 'pwd', 'dev' do |heroku_mock|
        @platform = Platform.new
      end
    end

    describe '#throughput' do

      before do
        now         = freeze_time
        end_date    = I18n.l(now, format: :z)
        begin_time  = I18n.l(5.minutes.ago, format: :z)
        @query      = { 'metrics[0]' => 'WebFrontend/QueueTime',
                        'field'      => 'calls_per_minute',
                        'begin'      => begin_time,
                        'end'        => end_date }
        @header     = {'Accept' => '*/*', 'User-Agent' => 'Ruby'}
      end

      it 'should ask new relic API about the average throughput on last 5 minutes and return the average throughput' do
        expected_response_body = '[{"name":"x","calls_per_minute":320.30},{"name":"x","calls_per_minute":280.70}]'

        with_constants(:ENV => { 'NEW_RELIC_API_KEY' => 'mysecretkey' }) do
          stub_http_request(:get, "#{NEWRELIC_API_URL}/data.json").with(query: @query, headers: @header).to_return(body: expected_response_body, status: 200)
          @platform.throughput.should eq 300
        end
      end

      it 'returns nil if newrelic returns less than 2 non 0 throughput score' do
        expected_response_body = '[{"name":"x","calls_per_minute":320.30}, {"name":"x","calls_per_minute":0.00}]'

        with_constants(:ENV => { 'NEW_RELIC_API_KEY' => 'mysecretkey' }) do
          stub_http_request(:get, "#{NEWRELIC_API_URL}/data.json").with(query: @query, headers: @header).to_return(body: expected_response_body, status: 200)
          @platform.throughput.should be_nil
        end
      end

      it 'returns nil if newrelic never answers' do
        with_constants(:ENV => { 'NEW_RELIC_API_KEY' => 'mysecretkey' }) do
          stub_http_request(:get, "#{NEWRELIC_API_URL}/data.json").with(query: @query, headers: @header).to_timeout
          @platform.throughput.should be_nil
        end
      end

      it 'returns nil if newrelic answers an http error code' do
        with_constants(:ENV => { 'NEW_RELIC_API_KEY' => 'mysecretkey' }) do
          stub_http_request(:get, "#{NEWRELIC_API_URL}/data.json").with(query: @query, headers: @header).to_return(body: 'this is an error', status: 500)
          @platform.throughput.should be_nil
        end
      end

    end

    describe '#web_auto_scaling_activated?' do
      it 'should return according to AppSetting[scale_auto_activated]' do
        @platform.web_auto_scaling_activated?.should be_false
        AppSetting.stub(:[]).with('scale_auto_activated').and_return 'false'
        @platform.web_auto_scaling_activated?.should be_false
        AppSetting.stub(:[]).with('scale_auto_activated').and_return 'true'
        @platform.web_auto_scaling_activated?.should be_true
        AppSetting.stub(:[]).with('scale_auto_activated').and_return 'some_trash'
        @platform.web_auto_scaling_activated?.should be_false
      end
    end

    describe '#activate_web_auto_scaling #desactivate_web_auto_scaling' do
      it 'should set AppSetting[:scale_auto_activated] to false' do
        AppSetting.create(key: 'scale_auto_activated', value: 'false')
        expect{@platform.activate_web_auto_scaling}.to change{@platform.web_auto_scaling_activated?}.from(false).to(true)
        expect{@platform.desactivate_web_auto_scaling}.to change{@platform.web_auto_scaling_activated?}.from(true).to(false)
      end
    end

    describe '#can_autoscale_web_workers?' do
      it 'returns true if all 3 auto scale settings attributes are set' do
        @platform.stub(:max_throughput_per_web_worker).and_return 120
        @platform.stub(:max_web_workers).and_return               10
        @platform.stub(:min_web_workers).and_return               2
        @platform.stub(:extra_web_workers).and_return             1

        @platform.send(:can_autoscale_web_workers?).should be_true
      end

      it 'returns false if one of the 3 auto scale settings attributes is nil' do
        @platform.stub(:max_throughput_per_web_worker).and_return 100
        @platform.stub(:max_web_workers).and_return               3
        @platform.stub(:min_web_workers).and_return               2
        @platform.stub(:extra_web_workers).and_return             nil

        @platform.send(:can_autoscale_web_workers?).should be_false
      end
    end

    describe '#autoscale_web_workers' do
      before do
        @platform.stub(:can_autoscale_web_workers?).and_return(true)
        @platform.stub(:web_auto_scaling_activated?).and_return(true)
        @platform.stub(:max_throughput_per_web_worker).and_return(150)
        @platform.stub(:min_web_workers).and_return(3)
        @platform.stub(:extra_web_workers).and_return(1)
        @platform.stub(:max_web_workers).and_return(5)
      end

      it 'when current throughput is 400 and it has only 3 web workers running, it should scale web workers to 4 and restart web.4' do
        @platform.stub(:ps_count).with('web').and_return(3)
        @platform.stub(:throughput).and_return(400)
        @platform.should_receive(:ps_scale).with('web', 4)
        @platform.should_receive(:ps_restart).with('web.4')

        @platform.autoscale_web_workers
      end

      it 'when current throughput if 800 and it has only 3 web workers running, it should scale web workers to 5 and restart web.4 and web.5' do
        @platform.stub(:ps_count).with('web').and_return(3)
        @platform.stub(:throughput).and_return(800)
        @platform.should_receive(:ps_scale).with('web',5)
        @platform.should_receive(:ps_restart).with('web.4')
        @platform.should_receive(:ps_restart).with('web.5')

        @platform.autoscale_web_workers
      end

      it 'when current throughput if 400 and it has already 4 web workers running, it should not scale nor restart any web worker' do
        @platform.stub(:ps_count).with('web').and_return(4)
        @platform.stub(:throughput).and_return(400)
        @platform.should_receive(:ps_scale).never
        @platform.should_receive(:ps_restart).never
        @platform.autoscale_web_workers
      end

      it 'when current throughput if 190 and it has already 4 web workers running, it should scale down to 3 web workers nor restart any web worker' do
        @platform.stub(:ps_count).with('web').and_return(4)
        @platform.stub(:throughput).and_return(190)
        @platform.should_receive(:ps_scale).with('web',3)
        @platform.should_receive(:ps_restart).never
        @platform.autoscale_web_workers
      end

      it 'when current throughput if 50 and it has already 3 web workers running, it should not scale' do
        @platform.stub(:ps_count).with('web').and_return(3)
        @platform.stub(:throughput).and_return(50)
        @platform.should_receive(:ps_scale).never

        @platform.autoscale_web_workers
      end

      it 'when current throughput is 400 and it has already 6 web workers running, it should not scale' do
        @platform.stub(:ps_count).with('web').and_return(6)
        @platform.stub(:throughput).and_return(400)
        @platform.should_receive(:ps_scale).never

        @platform.autoscale_web_workers
      end

      it 'when current throughput is 400 and it has only 1 web worker running, it should not scale' do
        @platform.stub(:ps_count).with('web').and_return(1)
        @platform.stub(:throughput).and_return(400)
        @platform.should_receive(:ps_scale).never

        @platform.autoscale_web_workers
      end

      it 'should do nothing and return false if web workers auto scaling is disabled' do
        @platform.stub(:web_auto_scaling_activated?).and_return(false)
        @platform.stub(:ps_count).never
        @platform.stub(:throughput).never
        @platform.should_receive(:ps_scale).never

        @platform.autoscale_web_workers.should be_false
      end

      it 'should do nothing if throughput is nil (ie newrelic error, no data...)' do
        @platform.stub(:ps_count).with('web').and_return(4)
        @platform.stub(:throughput).and_return(nil)
        @platform.should_receive(:ps_scale).never

        @platform.autoscale_web_workers
      end

    end

  end

  def with_heroku_env user, password, env, heroku_args={}, &block
    with_constants(:ENV => {  'APP_NAME' => env,
                              'HEROKU_USER' => user,
                              'HEROKU_PASSWORD' => password}) do
      heroku_mock = double("heroku_client", heroku_args)
      Heroku::API.stub(:new).with(username: user, password: password).and_return(heroku_mock)
      yield heroku_mock
    end
  end

end