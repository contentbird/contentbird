require 'spec_helper'

describe Scalable do
  before do
    @config = { photo:    {min_workers: 0, max_workers: 1, job_threshold: 1, queues: 'crop_avatar,photos' },
                default:  {min_workers: 0, max_workers: 1, job_threshold: 1, queues: '_first_confirmations,data_exports,...' }
              }
  end

  describe 'acts_as_scalable' do
    it 'sets min_workers, max_workers, job_threshold and queues for the given worker_type according to SCALER_CONFIG' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end

        ScalableJob.min_workers.should eq @config[:photo][:min_workers]
        ScalableJob.max_workers.should eq @config[:photo][:max_workers]
        ScalableJob.job_threshold.should eq @config[:photo][:job_threshold]
        ScalableJob.queues.should eq ['crop_avatar','photos']

      end
    end

    it 'without params, sets min_workers, max_workers, job_threshold and queues for the default worker_type' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable
        end

        ScalableJob.min_workers.should eq @config[:default][:min_workers]
        ScalableJob.max_workers.should eq @config[:default][:max_workers]
        ScalableJob.job_threshold.should eq @config[:default][:job_threshold]
        ScalableJob.queues.should eq ['_first_confirmations','data_exports','...']
      end
    end
  end

  describe '#job_count' do
    it 'sum the pending jobs in every queues of @queus' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable
        end
        Resque.should_receive(:size).with('_first_confirmations').and_return(3)
        Resque.should_receive(:size).with('data_exports').and_return(1)
        Resque.should_receive(:size).with('...').and_return(0)
        ScalableJob.job_count.should eq 4
      end
    end
  end

  describe '#nb_workers_needed' do
    it 'returns 1 if nb_jobs < job_threshold' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable
        end
        ScalableJob.stub(:job_threshold).and_return(10)
        ScalableJob.stub(:job_count).and_return(8)
        ScalableJob.nb_workers_needed.should eq ScalableJob.min_workers
      end
    end

    it 'returns nb_jobs/threshold+1 if nb_jobs > job_threshold but < max_workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable
        end
        ScalableJob.stub(:max_workers).and_return(5)
        ScalableJob.stub(:job_threshold).and_return(10)
        ScalableJob.stub(:job_count).and_return(27)
        ScalableJob.nb_workers_needed.should eq 3
      end
    end

    it 'returns max_workers if nb_jobs/job_threshold+1 > max_workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable
        end
        ScalableJob.stub(:max_workers).and_return(5)
        ScalableJob.stub(:job_threshold).and_return(10)
        ScalableJob.stub(:job_count).and_return(100)
        ScalableJob.nb_workers_needed.should eq ScalableJob.max_workers
      end
    end

    it 'returns 0 if there is no job and min_workers is 0' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable
        end
        ScalableJob.stub(:min_workers).and_return(0)
        ScalableJob.stub(:job_count).and_return(0)
        ScalableJob.nb_workers_needed.should eq 0
      end
    end
  end

  describe '#scale_up!' do
    it 'does nothing if the needed amount of workers is <= min amount of workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable
        end
        ScalableJob.stub(:nb_workers_needed).and_return(2)
        ScalableJob.stub(:min_workers).and_return(2)
        Platform.any_instance.should_receive(:ps).never
        Platform.any_instance.should_receive(:ps_scale).never
        ScalableJob.scale_up!
      end
    end

    it 'does nothing if it needs more workers than the min, but less or equal than the current amount of workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end
        ScalableJob.stub(:nb_workers_needed).and_return(2)
        ScalableJob.stub(:min_workers).and_return(1)
        Heroku::API.stub(:new).and_return(double("heroku_api"))
        Platform.any_instance.should_receive(:ps).with('photo_worker').once.and_return [{'process' => 'photo_worker.1'}, {'process' => 'photo_worker.2'}]
        Platform.any_instance.should_receive(:ps_scale).never
        ScalableJob.scale_up!
      end
    end

    it 'scales the platform workers if it needs more than the min and more than the current amount of workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end
        ScalableJob.stub(:nb_workers_needed).and_return(3)
        ScalableJob.stub(:min_workers).and_return(1)
        Heroku::API.stub(:new).and_return(double("heroku_api"))
        Platform.any_instance.should_receive(:ps).with('photo_worker').once.and_return [{'process' => 'photo_worker.1'}, {'process' => 'photo_worker.2'}]
        Platform.any_instance.should_receive(:ps_scale).once.with('photo_worker', 3)
        ScalableJob.scale_up!
      end
    end

    it 'does nothing auto scaling is disabled on this environment' do
      with_constants(:SCALER_CONFIG => @config) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end
        Platform.any_instance.should_receive(:ps).with('photo_worker').never
        Platform.any_instance.should_receive(:ps_scale).never
        ScalableJob.scale_up!
      end
    end
  end

  describe '#after_enqueue_scale_up' do
    it 'calls scale_up! everytime a job is enqueued in Resque' do
      with_constants(:SCALER_CONFIG => @config) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
          @queue  = :photos
          def perform
            'hello'
          end
        end
        ScalableJob.should_receive(:scale_up!).once
        JobRunner.stub(:can_run?).and_return true
        JobRunner.stub(:synchronous?).and_return false
        JobRunner.run(ScalableJob)
        sleep(0.01)
      end
    end
  end

  describe '#scale_down!' do
    it 'does nothing if the needed amount of workers is <= min_workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end
        ScalableJob.stub(:nb_workers_needed).and_return(1)
        ScalableJob.stub(:min_workers).and_return(1)
        Platform.any_instance.should_receive(:ps).never
        Platform.any_instance.should_receive(:ps_scale).never
        ScalableJob.scale_down!
      end
    end

    it 'does nothing if the needed amount of workers is > min_workers and >= current nb of workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end
        ScalableJob.stub(:nb_workers_needed).and_return(2)
        ScalableJob.stub(:min_workers).and_return(1)
        Heroku::API.stub(:new).and_return(double("heroku_api"))
        Platform.any_instance.should_receive(:ps).with('photo_worker').once.and_return [{'process' => 'photo_worker.1'}, {'process' => 'photo_worker.2'}]
        Platform.any_instance.should_receive(:ps).never
        Platform.any_instance.should_receive(:ps_scale).never
        ScalableJob.scale_down!
      end
    end

    it 'scales down if the needed amount of workers is > min_workers and < current nb of workers' do
      with_constants(:SCALER_CONFIG => @config, :WORKER_AUTOSCALE => true) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end
        ScalableJob.stub(:nb_workers_needed).and_return(1)
        ScalableJob.stub(:min_workers).and_return(0)
        Heroku::API.stub(:new).and_return(double("heroku_api"))
        Platform.any_instance.should_receive(:ps).with('photo_worker').once.and_return [{'process' => 'photo_worker.1'}, {'process' => 'photo_worker.2'}]
        Platform.any_instance.should_receive(:ps_scale).once.with('photo_worker', 1)
        ScalableJob.scale_down!
      end
    end

    it 'does nothing auto scaling is disabled on this environment' do
       with_constants(:SCALER_CONFIG => @config) do
        class ScalableJob
          include Scalable
          acts_as_scalable worker: :photo
        end
        Platform.any_instance.should_receive(:ps).with('photo_worker').never
        Platform.any_instance.should_receive(:ps_scale).never
        ScalableJob.scale_down!
      end
    end

  end

  describe '#def after_perform_scale_down' do
    it 'calls scale_down! everytime a job has finished performing' do
      with_constants(:SCALER_CONFIG => @config) do
        class ScalableJob
          @queue  = :photos
          include Scalable
          acts_as_scalable worker: :photo
          def perform
            'hello'
          end
        end
        ScalableJob.should_receive(:scale_down!).once
        ScalableJob.after_perform_scale_down
      end
    end
  end
end