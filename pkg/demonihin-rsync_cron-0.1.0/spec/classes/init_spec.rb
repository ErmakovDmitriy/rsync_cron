require 'spec_helper'
describe 'rsync_cron' do
  context 'with default values for all parameters' do
    it { should contain_class('rsync_cron') }
  end
end
