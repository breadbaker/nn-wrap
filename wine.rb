require './nn.rb'

class Wine < NN
  def initialize
    @neuron_setup = [8,8]
    @epochs = 5000
    @fann_network = true
    @match_index = 11
    super
  end
end
        # @file_path = opt[:file] || './winequality-red.csv'
        # @epochs = opt[:epochs] || 2000
        # @neuron_setup = opt[:neuron_setup] || [5, 10, 5]
        # @results_path = opt[:results_file_path] || './results'
        # @proc = opt[:proc] ||  Proc.new { |el| el }
        # @match_index = opt[:match_index]
        # @splitter = opt[:splitter] || ';'

# require './Wine.rb'

a = Wine.new
a.run

# a.get_data
# a.get_maxes
# a.run_training