require './nn.rb'

class Wine < NN

end
        # @file_path = opt[:file] || './winequality-red.csv'
        # @epochs = opt[:epochs] || 2000
        # @neuron_setup = opt[:neuron_setup] || [5, 10, 5]
        # @results_path = opt[:results_file_path] || './results'
        # @proc = opt[:proc] ||  Proc.new { |el| el }
        # @match_index = opt[:match_index]
        # @splitter = opt[:splitter] || ';'

# require './Wine.rb'

a = Wine.new({
  neuron_setup: [8],
  epochs: 50,
  fann_network: true
  })
a.run

# a.get_data
# a.get_maxes
# a.run_training