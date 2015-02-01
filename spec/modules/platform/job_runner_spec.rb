require 'spec_helper'

describe JobRunner do
  before do
    @job_mock = double('job')
  end

  describe '#synchronous?' do
    it 'uses ENV var to determine if job must be run synchronously or asynchronously' do
      with_constants(:JOBS_SYNCHRONOUS => true) do
         JobRunner.should be_synchronous
      end
      with_constants(:JOBS_SYNCHRONOUS => false) do
         JobRunner.should_not be_synchronous
      end
    end
  end

  describe '#can_run?' do
    it 'uses ENV var to determine if job must be run/enqueud or not' do
      with_constants(:JOBS_RUN => true) do
         JobRunner.can_run?.should be_true
      end
      with_constants(:JOBS_RUN => false) do
         JobRunner.can_run?.should be_false
      end
    end
  end

  describe '#run' do
    before do
      JobRunner.stub(:can_run?).and_return true
    end

    context 'given jobs are set to run asynchronously' do
      before do
        JobRunner.stub(:synchronous?).and_return false
      end
      it 'enqueues job in resque passing along parameters without running it and return true' do
        Resque.should_receive(:enqueue).with(@job_mock, :test, 'param1', 'param2')
        @job_mock.should_receive(:perform).never

        JobRunner.run(@job_mock, 'param1', 'param2').should be_true
      end

      it 'returns propagate the error if an error is raised while enqueue job' do
        Resque.stub(:enqueue).with(@job_mock, :test, 'param1', 'param2').and_raise('some error')
        @job_mock.should_receive(:perform).never

        expect{JobRunner.run(@job_mock, 'param1', 'param2')}.to raise_error
      end

      it 'returns true and enqueues nothing if can_run? is false' do
        JobRunner.unstub(:can_run?)
        JobRunner.stub(:can_run?).and_return false
        Resque.should_receive(:enqueue).with(@job_mock, :test, 'param1', 'param2').never
        JobRunner.run(@job_mock, 'param1', 'param2').should be_true
      end
    end

    context 'given jobs are set to run synchronously' do
      before do
        JobRunner.stub(:synchronous?).and_return true
      end
      it 'does not enqueue job, run it and return true' do
        Resque.should_receive(:enqueue).with(@job_mock, :test, 'param1', 'param2').never
        @job_mock.should_receive(:perform).with(:test, 'param1', 'param2').once

        JobRunner.run(@job_mock, 'param1', 'param2').should be_true
      end
      it 'returns true and runs nothing if can_run? is false' do
        JobRunner.unstub(:can_run?)
        JobRunner.stub(:can_run?).and_return false
        @job_mock.should_receive(:perform).never
        JobRunner.run(@job_mock, 'param1', 'param2').should be_true
      end
    end

  end

  describe '#run_in' do
    before do
      JobRunner.stub(:can_run?).and_return true
    end
    context 'given jobs are set to run asynchronously' do
      before do
        JobRunner.stub(:synchronous?).and_return false
      end
      it 'enqueues the job in resque passing the delay and return true' do
        Resque.should_receive(:enqueue_in).with(15.hours, @job_mock, :test, 'param1', 'param2')
        @job_mock.should_receive(:perform).never

        JobRunner.run_in(15.hours, @job_mock, 'param1', 'param2').should be_true
      end
    end

    context 'given jobs are set to run synchronously' do
      before do
        JobRunner.stub(:synchronous?).and_return true
      end
      it 'does not enqueue job, run it and return true' do
        Resque.should_receive(:enqueue_in).with(15.hours, @job_mock, :test, 'param1', 'param2').never
        @job_mock.should_receive(:perform).once

        JobRunner.run_in(15.hours, @job_mock, 'param1', 'param2').should be_true
      end
    end

  end


end