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

    def summary
      "[#{@chapter}] #{@step}"
    end

    def info
      blocks = {}
      label = ''
      details = @rugged_commit.message.lines[2..-1]
      return blocks if details.nil?
      details.each do |line|
        if line =~ /^([[:alnum:]]+):$/
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

    def patch
      diff.patch.force_encoding('utf-8')
    end

    def parent
      @rugged_commit.parents[0]
    end

    private

    def diff
      parent.diff(@rugged_commit, DIFF_OPTIONS)
    end
  end
end
