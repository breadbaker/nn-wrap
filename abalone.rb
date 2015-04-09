require './nn.rb'

class Abalone < NN
  def initialize
    @file_path = './abalone.data.txt'
    @results_path = 'abalone_results'
    @splitter = ','
    @match_index = 0
    @neuron_setup = [6, 6]
    @epochs = 3000
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

# require './abalone.rb'

a = Abalone.new
a.run

# a.get_data
# a.get_maxes
# a.run_training