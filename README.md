# passphrase-format

    Usage: generate.rb [options]
    
    Options:
        -F, --format FORMAT              Specify the format of the generated passphrase
                                         	(default: \w \w \w \w \w \w)
                                         available flags are:
                                         \w => a word from the wordlist
                                         \d => a digit [0-9]
                                         \s => a symbol from the string SYMBOLS
                                         Example: 'pass\d\d\d_\w \w \w'
        -w, --wordlist PATH/TO/WORDLIST  Pick words from the specified wordlist
                                         	(default: eff_large_wordlist.txt)
        -s, --symbols SYMBOLS            Specify a string of symbols to pick from
                                         	(default: !'@#$%&*-_=+/:.,";?)
        -c, --count N                    Number of passphrases to generate
        -h, --help                       Show this message

This tool generates passphrases based on a format string, similar to printf syntax.

Examples:

    $./generate.rb -F '\w \w \w \w \w \w'
    pancake salute ducky corral uncloak graded

    $./generate.rb -F '\w\d\s\w\d\s\w\d\s'
    subzero6!upheaval3@faculty0?

