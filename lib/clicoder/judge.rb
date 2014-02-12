module Clicoder
  class Judge
    def judge(file1, file2)
      diff_judge(file1, file2)
    end

    def diff_judge(file1, file2)
      File.read(file1) == File.read(file2)
    end
  end
end
