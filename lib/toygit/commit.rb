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

    def info
      blocks = {}
      label = ''
      @rugged_commit.message.lines[2..-1].each do |line|
        if line =~ /([[:alnum:]]+):/
          label = $1
        else
          unless blocks.include? label
            blocks[label] = ''
          end
          blocks[label] << line
        end
      end
      blocks
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
