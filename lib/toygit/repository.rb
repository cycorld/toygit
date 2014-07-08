require 'rugged'

module ToyGit
  class Repository
    attr_reader :rugged_repo
    attr_reader :commits

    def initialize(dir = '.')
      @rugged_repo = Rugged::Repository.discover(dir)
      prepare
    end

    def commit_from_toyid(toyid)
      i = @commits.find_index { |commit| commit.toyid == toyid }
      raise 'Invalid ToyId: %s' % toyid if i.nil?
      @commits[i]
    end

    private

    def prepare
      history = []

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
        history.push({chapter: chapter, step: step, rugged_commit: commit})
      end

      history.reverse!
      give_toyids(history)
      @commits = history.map do |entry|
        Commit.new(
          entry[:toyid],
          entry[:rugged_commit]
        )
      end
    end

    def give_toyids(history)
      prev_chapter = nil
      chapter_number = -1
      prev_step = nil
      step_number = 0
      action_number = 0
      history.each do |entry|
        chapter = entry[:chapter]
        step = entry[:step]
        if prev_chapter != chapter
          chapter_number += 1
          step_number = 0
          action_number = 0
        elsif prev_step != step
          step_number += 1
          action_number = 0
        else
          action_number += 1
        end
        entry[:toyid] = "#{chapter_number}-#{step_number}-#{action_number}"
        prev_chapter = chapter
        prev_step = step
      end
    end
  end
end
