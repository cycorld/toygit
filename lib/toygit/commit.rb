module ToyGit
  class Commit
    DIFF_OPTIONS = {
      ignore_whitespace: true
    }

    attr_reader :toyid
    attr_reader :chapter
    attr_reader :step
    attr_reader :rugged_commit

    def initialize(toyid, chapter, step, rugged_commit)
      @toyid = toyid
      @chapter = chapter
      @step = step
      @rugged_commit = rugged_commit
    end

    def diff
      @rugged_commit.parents[0].diff(@rugged_commit, DIFF_OPTIONS)
    end
  end
end
