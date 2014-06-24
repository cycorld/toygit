require 'rugged'

module ToyGit
  class Repository
    attr_reader :rugged_repo
    attr_reader :commits

    def initialize(dir = '.')
      path = Rugged::Repository.discover(dir)
      @rugged_repo = Rugged::Repository.new(path)
      prepare
    end

    def commit_from_toyid(toyid)
      i = @commits.find_index { |commit| commit[:toyid] == toyid }
      raise 'Invalid ToyId: %s' % toyid if i.nil?
      @commits[i]
    end

    private

    def prepare
      commits = []

      master = @rugged_repo.ref('refs/heads/master')
      walker = Rugged::Walker.new(@rugged_repo)
      walker.push master.target
      walker.each do |commit|
        raise 'Invalid ToyGit Repository: merge commit %s' % commit.oid if commit.parents.count > 1
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
      give_toyids
      true
    end

    def give_toyids
      prev_chapter = nil
      chapter_number = -1
      step_number = 0
      @commits.each do |commit|
        chapter = commit[:chapter]
        if prev_chapter != chapter
          chapter_number += 1
          step_number = 0
        end
        commit[:toyid] = "#{chapter_number}-#{step_number}"
        prev_chapter = chapter
        step_number += 1
      end
    end
  end
end
