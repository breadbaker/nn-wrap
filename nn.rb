


# indexes = train[0].length
# maxes = Array.new(indexes, 0)

# (0...indexes).each do |index|
#     train.each do |wine|
#         floated = wine[index].to_f
#         maxes[index] = maxes[index] < floated ? floated : maxes[index]
#     end
# end

# normalized_outputs = []
# normalized_inputs = []
# train.each do |wine|
#     wine_normalized = []
#     wine = wine.each_with_index do |value, index|
#         value = value.to_f
#         if index == wine.length - 1
#             normalized_outputs << value
#         else
#             wine_normalized << (value / maxes[index])
#         end
#     end

#     normalized_inputs << wine_normalized
# end

# min = normalized_outputs.min
# max = normalized_outputs.max
# num_outputs = (max - min).to_i
# normalized_outputs = normalized_outputs.map do |el|
#     output = Array.new(num_outputs,0)
#     output[num_outputs - el] = 1

#     output
# end
require 'ruby-fann'
require "ai4r"

# epochs = 2000
# neuron_setup = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6]
# num_inputs =normalized_inputs[0].length
# train = RubyFann::TrainData.new(:inputs=>normalized_inputs, :desired_outputs=>normalized_outputs)
# fann = RubyFann::Standard.new(:num_inputs=> num_inputs, :hidden_neurons=>neuron_setup, :num_outputs=>num_outputs)
# fann.train_on_data(train, epochs, 10, 0.1) # 1000 max_epochs, 10 errors between reports and 0.1 desired MSE (mean-squared-error)

class Array
  def safe_transpose
    result = []
    max_size = self.max { |a,b| a.size <=> b.size }.size
    max_size.times do |i|
      result[i] = Array.new(self.first.size)
      self.each_with_index { |r,j| result[i][j] = r[i] }
    end
    result
  end
end

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class NN

  attr_reader :train, :test, :maxes, :fann
  def initialize(opt = {})
    @file_path ||= './winequality-red.csv'
    @epochs ||= 2000
    @neuron_setup ||= [5, 10, 5]
    @results_path ||= './results'
    @pre_scramble ||= false
    @splitter ||= ';'
    @fann_network ||= true
    @mse ||= 0.1
    @errors_between ||= 10
    @special_normalize ||= {}
  end

  def run
    get_data
    run_training

    run_testing
  end

  def run_training
    norm = normalize(@train)
    puts "normalized train"

    num_inputs = norm[:normalized_inputs][0].length
    num_outputs = norm[:normalized_outputs][0].length
    if @fann_network
      puts "num outputs #{num_outputs}"
      train = RubyFann::TrainData.new(:inputs=>norm[:normalized_inputs], :desired_outputs=>norm[:normalized_outputs])
      @fann = RubyFann::Standard.new(:num_inputs=> num_inputs, :hidden_neurons=>@neuron_setup, :num_outputs=>num_outputs)
      @fann.train_on_data(train, @epochs, @errors_between, @mse) # 1000 max_epochs, 10 errors between reports and 0.1 desired MSE (mean-squared-error)
    else
      setup = [num_inputs]
      setup << @neuron_setup
      setup << num_outputs
      setup = setup.flatten
      @fann = Ai4r::NeuralNetwork::Backpropagation.new(setup)

      index = 0

      @epochs.times do |t|
        index = (index == norm[:normalized_inputs].length) ? 0 : index
        @fann.train(norm[:normalized_inputs][index], norm[:normalized_outputs][index])
        index += 1
      end
    end
  end

  def get_data
    lines = []
    File.open(@file_path, "r") do |f|
      f.each_line do |line|
        lines << line.split(@splitter)
      end
    end

    puts "file loaded #{lines.length} lines"

    lines = check_if_title_row(lines)

    lines = lines.shuffle if @pre_scramble

    train_size = @train_size || 2 * (lines.length / 3)
    @train = lines.slice(2, train_size)
    test_size = @test_size || lines.length / 3
    @test = lines.slice(train_size + 10, test_size)
  end

  # works only if dataset has at least on continuous column
  def check_if_title_row(lines)
    drop_line = false
    lines[1].each_with_index do |el, index|
      if el.is_number? && !lines[0][index].is_number?
        drop_line = true
      end
    end
    if drop_line
      puts "dropped row #{lines.shift()}"
    end

    lines
  end

  def normalize(data)
    column_groups = data.safe_transpose
    puts "transposed"

    # puts column_groups[0][0]
    normalized_column_groups = []
    normalized_outputs = []

    @match_index ||= data[0].length - 1
    puts "data0 #{data[0]}"
    puts "match index #{@match_index}"
    column_groups.each_with_index do |column, index|
      if index == @match_index
        normalized_outputs = normalize_column(column, index, true)
      else
        normalized_column_groups << normalize_column(column, index, false)
      end

      # puts "normalized #{index}"
    end
    # puts "retransposing #{normalized_column_groups.length} rows with #{normalized_column_groups[0].length} columns"

    data_groups_normalized = normalized_column_groups.safe_transpose

    # puts "retransposed #{data_groups_normalized.length} rows"

    normalized_inputs = data_groups_normalized.map do |group|
      group.flatten.compact
    end

    {
      normalized_outputs: normalized_outputs,
      normalized_inputs: normalized_inputs
    }
  end

  def normalize_column(data_group, index, match)
    return self.send(@special_normalize[index], data_group, index) if @special_normalize[index]

    return normalize_numeric(data_group, index) if data_group[0].is_number? && !match

    return normalize_descrete(data_group, index)
  end

  def normalize_numeric(data_group, index)
    data_group = data_group.map do |el|
      el.to_f
    end
    max = data_group.max
    min = data_group.min

    puts "index #{index} max #{max}"
    puts "index #{index} min #{min}"

    normalized = data_group.map do |el|
      [(el - min) / (max - min)]
    end

    puts "data #{data_group[0]}  norm #{normalized[0]}"

    normalized
  end

  def normalize_descrete(data_group, index)
    uniq = data_group.uniq

    data_group.map do |el|
      options = Array.new(uniq.length, 0)
      options[uniq.index(el)] = 1

      options
    end
  end

  def run_testing
    norm = normalize(@test)
    puts "normalized test"
    correct = 0
    wrong =0
    norm[:normalized_inputs].each_with_index do |input_group, index|
      if @fann_network
        output = @fann.run(input_group)
      else
        output = @fann.eval(input_group)
      end
      output_index = output.each_with_index.max[1]
      correct_output_index = norm[:normalized_outputs][index].each_with_index.max[1]
      if output_index == correct_output_index
        correct += 1
      else
        wrong += 1
      end
    end

    puts "raw input #{@test[0]}"
    puts "num inputs #{norm[:normalized_inputs][0].length}"
    puts "num outputs #{norm[:normalized_outputs][0].length}"
    puts "normalized input #{norm[:normalized_inputs][0]}"
    puts "normalized output #{norm[:normalized_outputs][0]}"
    puts "computed output #{@fann.run(norm[:normalized_inputs][0])}"

    log(correct, wrong)
  end

  def log(correct, wrong)
    log_file = File.open(@results_path, "a")
    log_file.puts "ratio #{correct.to_f/(wrong+correct)} neuron setup #{@neuron_setup} epochs #{@epochs} correct #{correct} wrong #{wrong}  #{Time.now}"
    puts "ratio #{correct.to_f/(wrong+correct)} neuron setup #{@neuron_setup} epochs #{@epochs} correct #{correct} wrong #{wrong}  #{Time.now}"
    log_file.close
  end

end