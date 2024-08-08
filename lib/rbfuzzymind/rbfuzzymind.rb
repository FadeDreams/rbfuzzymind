
class FuzzySet
  attr_reader :name, :membership_function

  def initialize(name, &membership_function)
    @name = name
    @membership_function = membership_function
  end

  def membership_degree(x)
    membership_function.call(x)
  end

  def union(other_set)
    FuzzySet.new("Union(#{name}, #{other_set.name})") do |x|
      [membership_function.call(x), other_set.membership_function.call(x)].max
    end
  end

  def intersection(other_set)
    FuzzySet.new("Intersection(#{name}, #{other_set.name})") do |x|
      [membership_function.call(x), other_set.membership_function.call(x)].min
    end
  end

  def complement
    FuzzySet.new("Complement(#{name})") do |x|
      1 - membership_function.call(x)
    end
  end

  def normalize
    FuzzySet.new("Normalized(#{name})") do |x|
      membership_function.call(x) / [1, membership_function.call(x)].max
    end
  end

  def centroid(min_val, max_val, step = 0.01)
    numerator = 0
    denominator = 0
    x = min_val

    while x <= max_val
      mu = membership_function.call(x)
      numerator += x * mu
      denominator += mu
      x += step
    end

    denominator == 0 ? 0 : numerator / denominator
  end
end

class FuzzyRule
  attr_reader :condition, :consequence, :weight

  def initialize(condition, consequence, weight = 1)
    @condition = condition
    @consequence = consequence
    @weight = weight
  end

  def evaluate(inputs)
    if condition.call(inputs)
      result = if consequence.is_a?(FuzzySet)
        consequence
      elsif consequence.respond_to?(:call)
        consequence.call(inputs)
      else
        consequence
      end
      { "result" => result, "weight" => weight }
    else
      nil
    end
  end
end

class InferenceEngine
  def initialize(rules)
    @rules = rules
  end

  def infer(inputs)
    results = @rules.map do |rule|
      rule.evaluate(inputs)
    end.compact

    aggregate_results(results)
  end

  def aggregate_results(results)
    return 'Low Priority' if results.empty?

    total_weight = 0
    weighted_sum = 0

    results.each do |result|
      weighted_sum += priority_mapping(result['result']) * result['weight']
      total_weight += result['weight']
    end

    if total_weight > 0
      reverse_priority_mapping(weighted_sum / total_weight)
    else
      'Low Priority'
    end
  end

  def priority_mapping(priority)
    { 'Urgent' => 3, 'High Priority' => 2, 'Medium Priority' => 1 }.fetch(priority, 0)
  end

  def reverse_priority_mapping(score)
    case score
    when 2.5..Float::INFINITY
      'Urgent'
    when 1.5...2.5
      'High Priority'
    when 0.5...1.5
      'Medium Priority'
    else
      'Low Priority'
    end
  end

  def get_fuzzy_set_consequences
    @rules.select { |rule| rule.consequence.is_a?(FuzzySet) }.map(&:consequence)
  end

  def defuzzify_centroid(min_val, max_val, step = 0.01)
    numerator = 0
    denominator = 0
    fuzzy_sets = get_fuzzy_set_consequences
    x = min_val

    while x <= max_val
      mu = fuzzy_sets.map { |fs| fs.membership_degree(x) || 0 }.max || 0
      numerator += x * mu
      denominator += mu
      x += step
    end

    denominator == 0 ? 0 : numerator / denominator
  end


  def defuzzify_mom(min_val, max_val, step = 0.01)
    max_mu = 0
    sum_x = 0
    count = 0
    fuzzy_sets = get_fuzzy_set_consequences
    x = min_val

    while x <= max_val
      mu = fuzzy_sets.map { |fs| fs.membership_degree(x) }.max
      if mu > max_mu
        max_mu = mu
        sum_x = x
        count = 1
      elsif mu == max_mu
        sum_x += x
        count += 1
      end
      x += step
    end

    count == 0 ? 0 : sum_x / count
  end

  def defuzzify_bisector(min_val, max_val, step = 0.01)
    total_area = 0
    left_area = 0
    bisector = min_val
    fuzzy_sets = get_fuzzy_set_consequences
    x = min_val

    while x <= max_val
      mu = fuzzy_sets.map { |fs| fs.membership_degree(x) }.max
      total_area += mu * step
      x += step
    end

    x = min_val
    while x <= max_val
      mu = fuzzy_sets.map { |fs| fs.membership_degree(x) }.max
      left_area += mu * step
      if left_area >= total_area / 2
        bisector = x
        break
      end
      x += step
    end

    bisector
  end
end
