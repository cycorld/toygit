require 'rugged'

module ToyGit
  class Command
    def initialize
      path = Rugged::Repository.discover('.')
      @repo = Rugged::Repository.new(path)
      @repo.config['notes.rewriteRef'] = 'refs/notes/commits'
      prepare
    end

    def list
      @commits.each do |commit|
        puts "#{commit[:toyid]}\t[#{commit[:chapter]}] #{commit[:step]}"
      end
    end

    def goto(toyid)
      unless @repo.head.name == 'refs/heads/master'
        raise 'Invalid branch: switch to the "master" branch first'
      end
      commit = commit_from_toyid(toyid)
      sha = commit[:rugged_commit].oid
      name = "ToyFix-#{sha}"
      `git checkout -b #{name} #{sha}`
    end

    def return
      name = @repo.head.name
      unless name =~ /refs\/heads\/ToyFix-([0-9a-f]{4,})/
        raise 'Invalid branch: switch to a ToyGit branch'
      end
      base = $1
      `git rebase #{base} master --onto #{name} && git branch -d ToyFix-#{base}`
    end

    def delete(toyid)
      unless @repo.head.name == 'refs/heads/master'
        raise 'Invalid branch: switch to the "master" branch first'
      end
      commit = commit_from_toyid(toyid)
      sha = commit[:rugged_commit].oid
      `git rebase #{sha} --onto #{sha}~`
    end

    private

    def prepare
      commits = []

      master = @repo.ref('refs/heads/master')
      walker = Rugged::Walker.new(@repo)
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

    def commit_from_toyid(toyid)
      i = @commits.find_index { |commit| commit[:toyid] == toyid }
      raise 'Invalid ToyId: %s' % toyid if i.nil?
      @commits[i]
    end
  end
end
