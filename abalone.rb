require './nn.rb'

class Abalone < NN
  def map_outputs(outputs)
    uniq = outputs.uniq

    normalized_outputs = outputs.map do |el|
        output = Array.new(uniq.length,0)
        output[uniq.index(el)] = 1

        output
    end

    normalized_outputs
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

a = Abalone.new({ 
  file: './abalone.data.txt', 
  results_file_path: 'abalone_results',
  splitter: ',',
  match_index: 0,
  neuron_setup: [6, 6],
  epochs: 3000
  })
a.run

# a.get_data
# a.get_maxes
# a.run_training