require 'spec_helper'

module Maid
  module Rake
    describe SingleRule do
      subject(:single_rule) { described_class.new name, task }
      let(:name)            { double(:rule_description) }
      let(:task)            { Proc.new {} }

      describe '#initialize' do
        its(:name) { should eq(name) }
        its(:task) { should eq(task) }
      end

      describe '#clean' do
        let(:maid) { double(:maid_instance) }

        before do
          single_rule.maid_instance = maid
        end

        it 'calls #clean on maid_instance' do
          expect(maid).to receive(:clean)
          single_rule.clean
        end
      end

      describe '#maid_instance' do
        let(:maid_instance) { single_rule.maid_instance }

        it 'instantiates a Maid with the proper arguments' do
          expect(Maid).to receive(:new).with(rules_path: '/dev/null')
          maid_instance
        end

        it 'returns a Maid instance' do
          expect(maid_instance).to be_a(Maid)
        end

        it 'memoizes the result' do
          expect(Maid).to receive(:new).once
          maid_instance
          maid_instance
        end
      end

      describe '#define' do
        let(:maid) { double(:maid_instance) }

        before { single_rule.maid_instance = maid }

        it 'defines a single rule upon maid instance' do
          expect(maid).to receive(:rule).with(name, &task)
          single_rule.define
        end

        it 'returns self' do
          allow(maid).to receive(:rule).with(name, &task)
          expect(single_rule.define).to eq(single_rule)
        end
      end

      describe '.perform' do
        subject(:perform) { described_class.perform name, task }
        let(:name)        { double(:name) }
        let(:task)        { Proc.new {} }

        it 'creates an instance' do
          expect(described_class)
            .to receive(:new)
            .with(name, task)
            .and_call_original
          perform
        end

        describe 'instance methods calling' do
          let(:instance) { double(:single_rule).as_null_object }

          before do
            allow(described_class).to receive(:new).and_return(instance)
          end

          it 'calls #define and #clean on instance' do
            expect(instance).to receive(:define)
            expect(instance).to receive(:clean)
            perform
          end
        end
      end

    end
  end
end
