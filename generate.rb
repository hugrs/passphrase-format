#!/usr/bin/env ruby
require 'securerandom'
require 'optparse'
require 'ostruct'
require 'stringio'


DLM = '/'  # Token delimiter
DEFAULTS = {
  wordlist: 'eff_large_wordlist.txt',
  symbols: %q(!'@#$%&*-_=+/:.,";?~),
  format: "(#{DLM}w )*6",
  count: 1
}

# https://stackoverflow.com/questions/2650517/count-the-number-of-lines-in-a-file-without-reading-entire-file-into-memory
def file_nb_lines(filename)
  File.foreach(filename).reduce(0) {|acc, line| acc += 1}
end

def pick_random_word(wordlist)
  File.open(wordlist, 'r') {|file|
    # Pick a random number N then read N lines from the file
    SecureRandom.random_number(file_nb_lines wordlist).times { file.readline }
    # Return the next line
    file.readline.split("\t")[1].strip
  }
end

def random_element_in_array(array)
  array[SecureRandom.random_number(array.length)]
end

def parse_command_line(args)
  options = OpenStruct.new
  options.format      = DEFAULTS[:format]
  options.wordlist    = DEFAULTS[:wordlist]
  options.symbols     = DEFAULTS[:symbols]
  options.count       = DEFAULTS[:count]

  puts "WARNING: No options provided! Using default parameters.\n"\
    "See --help for more information.\n\n" if args.empty?

  opt_parser = OptionParser.new {|opts|
    opts.banner = "Usage: #{File.basename($0)} [options]"
    opts.separator ""
    opts.separator "Options:"

    opts.on("-F FORMAT",
        "Specify the format of the generated passphrase",
        "\t(default\: #{options.format})",
        "available flags are:",
        "#{DLM}w => a word from the wordlist",
        "#{DLM}d => a digit [0-9]",
        "#{DLM}s => a symbol from the string SYMBOLS",
        "#{DLM}c => a random character (letter, digit or symbol)",
        "Example: 'pass#{DLM}d#{DLM}d#{DLM}d_#{DLM}w #{DLM}w #{DLM}w'") do |format|
      options.format = format
    end

    opts.on("-w PATH\/TO\/WORDLIST",
        "Pick words from the specified wordlist",
        "\t(default\: #{options.wordlist})") do |list|
      options.wordlist = list
    end

    opts.on("-s SYMBOLS",
        "Specify a string of symbols to pick from",
        "\t(default\: #{options.symbols})") do |list|
      options.symbols = list
    end

    opts.on("-c N",
        "Number of passphrases to generate") do |count|
      options.count = count.to_i
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  }
  opt_parser.parse!(args)
  options
end


options = parse_command_line(ARGV)
format = options.format
tokens = {
  'w' => lambda { pick_random_word(options.wordlist) },
  's' => lambda { random_element_in_array(options.symbols) },
  'd' => lambda { SecureRandom.random_number(10).to_s },
  'c' => lambda {
    # Concat digits, letters and symbols into a single array
    full_list = [('0'..'9').to_a, ('a'..'z').to_a, ('A'..'Z').to_a, options.symbols.chars].reduce([], :concat)
    random_element_in_array(full_list)
  }
}

# Replace all "*n" in format string
# example: '(/w)*3' => '/w/w/w'
preprocessing = /(#{DLM}\w|\([#{DLM}\w\s]*\))\*(\d+)/
while format.match(preprocessing) {|m|
    match = m[1].to_s
    # strip surrounding parentheses
    if match[0] == '(' && match[-1] == ')'
      match = match.slice(1 ... -1)
    end
    # Replace from <beginning of match> to <end of match>
    # with the token copied n times
    format[m.begin(0) ... m.end(0)] = match * m[2].to_i
  }
end

# Generate <count> passphrases
options.count.times do
  token_regex = /#{DLM}[#{tokens.keys.join}]/
  # Replace all tokens in the format string with their random value
  # and display the result
  puts format.gsub(token_regex) {|m|
    tokens[m[1]].call
  }
end
