module ToyGit
  class Command
    def initialize(repo)
      @repo = repo

      @repo.rugged_repo.config['notes.rewriteRef'] = 'refs/notes/commits'
    end

    def list
      head_hash = @repo.rugged_repo.head.target.oid
      @repo.commits.each do |commit|
        hash = commit.rugged_commit.oid
        star = (head_hash == hash ? '*' : '')
        puts "#{commit.toyid}#{star}\t"\
          + "#{hash[0,7]}\t"\
          + commit.summary
      end
    end

    def goto(toyid)
      unless @repo.rugged_repo.head.name == 'refs/heads/master'
        raise 'Invalid branch: switch to the "master" branch first'
      end
      commit = @repo.commit_from_toyid(toyid)
      sha = commit.rugged_commit.oid
      name = "ToyFix-#{sha}"
      `git checkout -b #{name} #{sha}`
    end

    def return
      name = @repo.rugged_repo.head.name
      unless name =~ /refs\/heads\/ToyFix-([0-9a-f]{4,})/
        raise 'Invalid branch: switch to a ToyGit branch'
      end
      base = $1
      `git rebase #{base} master --onto #{name} && git branch -d ToyFix-#{base}`
    end

    def delete(toyid)
      unless @repo.rugged_repo.head.name == 'refs/heads/master'
        raise 'Invalid branch: switch to the "master" branch first'
      end
      commit = @repo.commit_from_toyid(toyid)
      sha = commit.rugged_commit.oid
      `git rebase #{sha} --onto #{sha}~`
    end

    def show(toyid)
      commit = @repo.commit_from_toyid(toyid)
      puts commit.summary
      commit.info.each do |label, text|
        puts "#{label}:"
        puts text
      end
      commit.hunks.each do |hunk|
        puts hunk.path
        puts hunk.header
        hunk.lines.each { |line| puts line }
      end
    end
  end
end
