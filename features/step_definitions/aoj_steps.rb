require 'clicoder/aoj'

Given /^in a problem directory of number (\d+)/ do |problem_number|
  aoj = Clicoder::AOJ.new(problem_number)
  aoj.start
  Dir.chdir(aoj.work_dir)
end

Given 'there is no Makefile rule "build"' do
end
