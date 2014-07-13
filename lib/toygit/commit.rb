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

    def parent
      @rugged_commit.parents[0]
    end

    def chapter_changed_commit(repo, new_chapter, new_parent)
      new_summary = "[#{new_chapter}] #{@step}"
      summary_changed_commit(repo, new_summary, new_parent)
    end

    def step_changed_commit(repo, new_step, new_parent)
      new_summary = "[#{@chapter}] #{new_step}"
      summary_changed_commit(repo, new_summary, new_parent)
    end

    def parent_changed_commit(repo, new_parent)
      modify(repo, { parents: [new_parent] })
    end

    private

    def diff
      @rugged_commit.parents[0].diff(@rugged_commit, DIFF_OPTIONS)
    end

    def summary_changed_commit(repo, summary, parent)
      args = {}

      message_token = @rugged_commit.message.partition("\n")
      message_token[0] = summary
      args[:message] = message_token.join

      unless parent.nil?
        args[:parents] = [parent]
      end

      modify(repo, args)
    end

    def modify(repo, args)
      new_args = @rugged_commit.to_hash.merge(args)
      Rugged::Commit.create(repo, new_args)
    end
  end
end
