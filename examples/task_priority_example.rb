
# examples/task_priority_example.rb

# require 'rbfuzzymind'
require_relative '../lib/rbfuzzymind/rbfuzzymind'

# Define fuzzy sets for Urgency
low_urgency = FuzzySet.new('Low Urgency') { |x| [1 - x, 0].max }
medium_urgency = FuzzySet.new('Medium Urgency') { |x| [1 - (x - 0.5).abs * 2, 0].max }
high_urgency = FuzzySet.new('High Urgency') { |x| [x, 0].max }

# Define fuzzy sets for Importance
low_importance = FuzzySet.new('Low Importance') { |x| [1 - x, 0].max }
medium_importance = FuzzySet.new('Medium Importance') { |x| [1 - (x - 0.5).abs * 2, 0].max }
high_importance = FuzzySet.new('High Importance') { |x| [x, 0].max }

# Define fuzzy rules based on urgency and importance
rules = [
  FuzzyRule.new(->(inputs) { low_urgency.membership_degree(inputs[:urgency]) > 0.5 && low_importance.membership_degree(inputs[:importance]) > 0.5 }, 'Low Priority'),
  FuzzyRule.new(->(inputs) { medium_urgency.membership_degree(inputs[:urgency]) > 0.5 && medium_importance.membership_degree(inputs[:importance]) > 0.5 }, 'Medium Priority'),
  FuzzyRule.new(->(inputs) { high_urgency.membership_degree(inputs[:urgency]) > 0.5 || high_importance.membership_degree(inputs[:importance]) > 0.5 }, 'High Priority'),
  FuzzyRule.new(->(inputs) { high_urgency.membership_degree(inputs[:urgency]) > 0.5 && high_importance.membership_degree(inputs[:importance]) > 0.5 }, 'Urgent')
]

# Create an inference engine
engine = InferenceEngine.new(rules)

# Test the inference engine with different inputs
task1 = { urgency: 0.8, importance: 0.7 }
task2 = { urgency: 0.4, importance: 0.6 }
task3 = { urgency: 0.1, importance: 0.3 }

puts "Task 1 Priority: #{engine.infer(task1)}" # Expected output: High Priority or Urgent
puts "Task 2 Priority: #{engine.infer(task2)}" # Expected output: Medium Priority
puts "Task 3 Priority: #{engine.infer(task3)}" # Expected output: Low Priority

# Defuzzification Example
centroid_value = engine.defuzzify_centroid(0, 1)
puts "Defuzzified Centroid Value: #{centroid_value}"
