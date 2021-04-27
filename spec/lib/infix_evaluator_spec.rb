# frozen_string_literal: true

require 'infix_evaluator'

describe InfixEvaluator do
  describe '.sanitize' do
    it 'filters out alphabetic words' do
      expect(described_class.sanitize('what is 1+1')).to eq('1+1')
    end

    it 'filters out alphabetic words (even if they contain a digit or operator' do
      expect(described_class.sanitize('wh4at i+s 1+1')).to eq('1+1')
    end

    it 'filters out question marks at end' do
      expect(described_class.sanitize('what is 1+1???')).to eq('1+1')
    end
  end

  describe '.tokenize' do
    it 'converts unary - to -1 *' do
      expect(described_class.tokenize('-1')).to eq([-1, '*', 1])
    end

    it 'converts - to + -1 *' do
      expect(described_class.tokenize('1-1')).to eq([1, '+', -1, '*', 1])
    end

    it 'converts decimals & integers' do
      expect(described_class.tokenize('2.34+1')).to eq([2.34, '+', 1])
    end

    it 'converts operators' do
      expect(described_class.tokenize(%w[- + * × / ÷ ^ ( )].join)).to eq([-1] + %w[* + * × / ÷ ^ ( )])
    end
  end

  # Not attempting to be exhaustive. Mostly sanity checking.
  describe '.convert_to_rpn' do
    it 'raises on unmatched ( parens' do
      expect { described_class.convert_to_rpn(['(']) }.to raise_error(ArgumentError)
    end

    it 'raises on unmatched ) parens' do
      expect { described_class.convert_to_rpn([')']) }.to raise_error(ArgumentError)
    end

    it 'sanely converts addition' do
      expect(described_class.convert_to_rpn([1, '+', 1])).to eq([1, 1, '+'])
    end

    it 'sanely converts subtraction' do
      expect(described_class.convert_to_rpn([1, '-', 1])).to eq([1, 1, '-'])
    end

    it 'sanely converts multiplication' do
      expect(described_class.convert_to_rpn([1, '*', 2])).to eq([1, 2, '*'])
    end

    it 'sanely converts division' do
      expect(described_class.convert_to_rpn([1, '/', 2])).to eq([1, 2, '/'])
    end

    it 'sanely converts exponentiation' do
      expect(described_class.convert_to_rpn([1, '^', 2])).to eq([1, 2, '^'])
    end

    it 'preserves order of precedence' do
      expect(described_class.convert_to_rpn([1, '+', 1, '/', 2])).to eq([1, 1, 2, '/', '+'])
    end

    it 'honors associativity when precedence is same & right associative' do
      expect(described_class.convert_to_rpn([2, '^', 2, '^', 4])).to eq([2, 2, 4, '^', '^'])
    end

    it 'honors parenthesis when precendence is inverted' do
      expect(described_class.convert_to_rpn([2, '*', '(', 3, '+', 4, ')'])).to eq([2, 3, 4, '+', '*'])
    end

    it 'sanely converts a complex expression' do
      expression = ['(', 5, '+', 3, ')', '^', 12, '*', 7, '/', 3, '+', -1, '*', 4]
      expect(described_class.convert_to_rpn(expression)).to eq([5, 3, '+', 12, '^', 7, '*', 3, '/', -1, 4, '*', '+'])
    end
  end

  describe '.evaluate_rpn' do
    it 'raises if no expression' do
      expect { described_class.evaluate_rpn([]) }.to raise_error(ArgumentError)
    end

    it 'raises if not enough operands' do
      expect { described_class.evaluate_rpn([1, '*']) }.to raise_error(ArgumentError)
    end

    it 'can eval just a number' do
      expect(described_class.evaluate_rpn([1])).to eq(1)
    end

    it 'can eval just a negative number' do
      expect(described_class.evaluate_rpn([-1])).to eq(-1)
    end

    it 'can eval a decimal' do
      expect(described_class.evaluate_rpn([-1.56])).to eq(-1.56)
    end

    it 'can eval addition' do
      expect(described_class.evaluate_rpn([1, 2, '+'])).to eq(3)
    end

    it 'can eval multiplication' do
      expect(described_class.evaluate_rpn([-5, 2, '*'])).to eq(-10)
    end

    it 'can eval division' do
      expect(described_class.evaluate_rpn([10, 2, '÷'])).to eq(5)
    end

    it 'can eval exponentiation' do
      expect(described_class.evaluate_rpn([10, 2, '^'])).to eq(100)
    end

    it 'can evaluate complex expression' do
      expect(described_class.evaluate_rpn([5, 3, '+', 2, '^', 7, '*', 2, '/', -1, 4, '*', '+'])).to eq(220)
    end
  end

  def generate_random_arithmetic_expression
    ops = %w[- + * / ^]
    return Random.rand(3).to_f + 1 if Random.rand(100) < 55

    generate_random_arithmetic_expression.to_s + ops.sample(1)[0] + generate_random_arithmetic_expression.to_s
  end

  context 'sanity checking via random expressions & ruby eval' do
    it 'check' do
      4096.times do
        exp = generate_random_arithmetic_expression.to_s

        ruby_result = eval(exp.gsub('^', '**')) # rubocop:disable Security/Eval
        result = described_class.new(exp).result

        next if ruby_result.nan? || result.nan?

        expect(ruby_result).to eq(result)
      end
    end
  end
end
