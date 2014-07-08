module ToyGit
  class Commit
    DIFF_OPTIONS = {
      ignore_whitespace: true
    }

    attr_reader :toyid
    attr_reader :rugged_commit

    def initialize(toyid, rugged_commit)
      @toyid = toyid
      @rugged_commit = rugged_commit
    end

    def summary
      @rugged_commit.message.lines[0]
    end

    def hunks
      hunks = []
      diff.each do |patch|
        patch.each do |hunk|
          hunks << Hunk.new(hunk)
        end
      end
      hunks
    end

    private

    def diff
      @rugged_commit.parents[0].diff(@rugged_commit, DIFF_OPTIONS)
    end
  end
end
