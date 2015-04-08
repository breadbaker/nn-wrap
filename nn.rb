


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


class NN

    attr_reader :train, :test, :maxes, :fann
    def initialize(opt = {})
        @file_path = opt[:file] || './winequality-red.csv'
        @epochs = opt[:epochs] || 2000
        @neuron_setup = opt[:neuron_setup] || [5, 10, 5]
        @results_path = opt[:results_file_path] || './results'
        @match_index = opt[:match_index] || nil
        @splitter = opt[:splitter] || ';'
        @fann_network = opt[:fann_network]
    end

    def run
        get_data
        normalize_data
        run_training
        run_testing
    end

    def get_maxes
        points = @train[0].length
        @maxes = Array.new(points, 0)

        @match_index ||= points - 1

        (0...points).each do |index|
            @train.each do |wine|
                floated = wine[index].to_f
                @maxes[index] = @maxes[index] < floated ? floated : @maxes[index]
            end
        end
    end

    def run_training
        norm = normalize(@train)

        if @fann_network
            train = RubyFann::TrainData.new(:inputs=>norm[:normalized_inputs], :desired_outputs=>norm[:normalized_outputs])
            @fann = RubyFann::Standard.new(:num_inputs=> norm[:num_inputs], :hidden_neurons=>@neuron_setup, :num_outputs=>norm[:num_outputs])
            @fann.train_on_data(train, @epochs, 10, 0.1) # 1000 max_epochs, 10 errors between reports and 0.1 desired MSE (mean-squared-error)
        else
            setup = [norm[:num_inputs]]
            setup << @neuron_setup
            setup << norm[:num_outputs]
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

        @train = lines.slice(2, 2 * (lines.length / 3))
        @test = lines.slice(2 * (lines.length / 3 + 1), lines.length - 1)
    end

    def normalize(group)
        normalized_inputs = []
        outputs = []
        group.each do |item|
            item_normalized = []
            item = item.each_with_index do |value, index|
                if index == @match_index
                    outputs << value
                else
                    value = value.to_f
                    item_normalized << (value / @maxes[index])
                end
            end

            normalized_inputs << item_normalized
        end

        normalized_outputs = map_outputs(outputs)
        {
            normalized_inputs: normalized_inputs,
            normalized_outputs: normalized_outputs,
            num_outputs: normalized_outputs[0].length,
            num_inputs: normalized_inputs[0].length
        }
    end

    def run_testing
        norm = normalize(@test)
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

        log(correct, wrong)
    end

    def log(correct, wrong)
        log_file = File.open(@results_path, "a")
        log_file.puts "ratio #{correct.to_f/(wrong+correct)} neuron setup #{@neuron_setup} epochs #{@epochs} correct #{correct} wrong #{wrong}"
        log_file.close
    end

    def map_outputs(outputs)
        outputs = outputs.map do |el|
            el.to_f
        end
        min = outputs.min
        max = outputs.max
        num_outputs = (max - min).to_i
        normalized_outputs = outputs.map do |el|
            output = Array.new(num_outputs,0)
            output[num_outputs - el] = 1

            output
        end

        normalized_outputs
    end

end