require 'clicoder/aoj'

Given /^in a problem directory of number (\d+)/ do |problem_number|
  aoj = Clicoder::AOJ.new(problem_number)
  aoj.start
  Dir.chdir(aoj.work_dir)
end

Then /^an executable should be generated/ do
  expect(File.exists?('a.out')).to be_true
end
