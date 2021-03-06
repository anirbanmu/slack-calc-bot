# frozen_string_literal: true

# Helper class to do infix evaluation of arithmetic
class InfixEvaluator
  OPERATORS = %w[- + * × / ÷ ^ ( )].freeze
  OPERATORS_ESCAPED = OPERATORS.map(&Regexp.method(:escape))
  OPERATOR_PRECEDENCE = { '+' => 0, '-' => 0,
                          '*' => 1, '×' => 1, '/' => 1, '÷' => 1,
                          '^' => 2 }.freeze
  OPERATOR_ASSOCIATIVITY = { '+' => :left, '-' => :left,
                             '*' => :left, '×' => :left, '/' => :left, '÷' => :left,
                             '^' => :right }.freeze
  OPERATOR_RUBY_SYMBOL = { '+' => :+, '-' => :-,
                           '*' => :*, '×' => :*,
                           '/' => :/, '÷' => :/,
                           '^' => :** }.freeze

  attr_accessor :result

  def initialize(unsanitized)
    @tokens = self.class.sanitize_and_tokenize unsanitized
    raise ArgumentError, 'Malformed expression' if @tokens.empty?

    @rpn = self.class.convert_to_rpn @tokens
    @result = self.class.evaluate_rpn(@rpn)
  end

  def parsed_expression
    @tokens.join(' ')
  end

  def self.sanitize(unsanitized)
    # Eliminate any words that contain anything other than number + operators
    unsanitized.gsub(/\?+$/, '').split.reject { |word| (word =~ /[^\d.#{OPERATORS_ESCAPED.join}]/) }.join
  end

  def self.tokenize(sanitized)
    # Scan for tokens
    tokens = sanitized.scan(/\d+\.{0,1}\d*|#{OPERATORS_ESCAPED.join('|')}/)

    # Convert tokens to number or operator
    tokens.each_with_index.flat_map do |token, i|
      if OPERATORS.any?(&token.method(:eql?))
        if token == '-' # Eliminate unary minus
          next (i.zero? || tokens[i - 1] == '(' ? [Float(-1), '*'] : ['+', Float(-1), '*'])
        end
        next [] if token == '+' && (i.zero? || tokens[i - 1] == '(') # Eliminate unary plus

        next token
      end

      Float(token)
    end
  end

  def self.sanitize_and_tokenize(unsanitized)
    tokenize(sanitize(unsanitized))
  end

  # Convert to reverse polish notation (postfix) via Shunting Yard algorithm
  def self.convert_to_rpn(tokens)
    output = []
    operator_stack = []

    tokens.each do |t|
      if t.is_a?(Numeric)
        output.push t
        next
      end

      if t == '('
        operator_stack.push t
        next
      end

      if t == ')'
        while (op = operator_stack.pop)
          break if op == '('

          output.push op
        end
        raise ArgumentError, 'Unmatched parenthesis' if op != '('

        next
      end

      # Must be an operator

      # Pop operators from operator_stack while precedence is higher than token or precedence is equal but top operator has left associativity
      while (top_op = operator_stack.last)
        break if top_op == '('
        break unless (OPERATOR_PRECEDENCE[top_op] > OPERATOR_PRECEDENCE[t]) || (OPERATOR_PRECEDENCE[top_op] == OPERATOR_PRECEDENCE[t] && OPERATOR_ASSOCIATIVITY[top_op] == :left)

        output.push operator_stack.pop
      end
      operator_stack.push t
    end

    # Unmatched parenthesis
    raise ArgumentError, 'Unclosed parenthesis' if operator_stack.include?('(')

    # Add leftover operators to our output
    output.push(*operator_stack.reverse)
  end

  def self.evaluate_rpn(tokens)
    stack = []
    tokens.each do |t|
      if t.is_a?(Numeric)
        stack.push t
        next
      end

      op2 = stack.pop
      op1 = stack.pop
      raise ArgumentError, 'Malformed expression' if !op1 || !op2

      stack.push op1.send(OPERATOR_RUBY_SYMBOL[t], op2)
    end

    raise ArgumentError, 'Malformed expression' if stack.length != 1

    stack.pop
  end
end
