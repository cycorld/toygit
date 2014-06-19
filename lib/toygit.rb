require 'rugged'

module ToyGit
  class Command
    def initialize
      path = Rugged::Repository.discover('.')
      @repo = Rugged::Repository.new(path)
      raise 'Invalid ToyGit Repository' unless verify
    end

    private

    def verify
      commits = []

      master = @repo.ref('refs/heads/master')
      walker = Rugged::Walker.new(@repo)
      walker.push master.target
      walker.each do |commit|
        return false if commit.parents.count > 1
        summary = commit.message.lines[0]
        if summary =~ /\[([[:print:]]+)\][[:space:]]?([[:print:]]*)/
          chapter = $1
          step = $2
        else
          chapter = ''
          step = summary
        end
        commits.push({chapter: chapter, step: step, rugged_commit: commit})
      end

      @commits = commits.reverse
      true
    end
  end
end
