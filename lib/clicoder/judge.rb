module Clicoder
  class Judge
    def initialize(options)
      @options = options
    end

    def judge(file1, file2)
      if @options[:decimal]
        float_judge(file1, file2, 10**(- @options[:decimal]))
      else
        diff_judge(file1, file2)
      end
    end

    def diff_judge(file1, file2)
      File.read(file1) == File.read(file2)
    end

    def float_judge(file1, file2, absolute_error)
      lines1 = File.read(file1).split($/).map(&:strip)
      floats1 = lines1.map{ |line| line.split(/\s+/).map(&:to_f) }.flatten
      lines2 = File.read(file2).split($/).map(&:strip)
      floats2 = lines2.map{ |line| line.split(/\s+/).map(&:to_f) }.flatten
      floats1.zip(floats2).each do |float1, float2|
        return false if (float1 - float2).abs >= absolute_error
      end
      true
    end
  end
end
