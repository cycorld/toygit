module ToyGit
  class Commit
    DIFF_OPTIONS = {
      ignore_whitespace: true
    }

    attr_reader :toyid
    attr_reader :summary
    attr_reader :rugged_commit

    def initialize(rugged_commit)
      @toyid = parse_toyid rugged_commit.message
      @summary = parse_summary rugged_commit.message
      @rugged_commit = rugged_commit
    end

    def hunks
      hunks = []
      diff.each do |patch|
        patch.each do |hunk|
          hunks << Hunk.new(hunk, parent)
        end
      end
      hunks
    end

    def patch
      diff.patch.force_encoding('utf-8')
    end

    private

    def parse_toyid(message)
      if message =~ /^#{Constant::TOYID}(.+)$/
        $1
      else
        nil
      end
    end

    def parse_summary(message)
      message.lines[0]
    end

    def parent
      @rugged_commit.parents[0]
    end

    def diff
      parent.diff(@rugged_commit, DIFF_OPTIONS)
    end
  end
end
