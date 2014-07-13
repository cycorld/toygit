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

    def change(kind, toyid, message)
      unless @repo.rugged_repo.head.name == 'refs/heads/master'
        raise 'Invalid branch: switch to the "master" branch first'
      end

      changed_commit_method = nil
      if kind == :chapter
        changed_commit_method = :chapter_changed_commit
      elsif kind == :step
        changed_commit_method = :step_changed_commit
      else
        raise "Invalid kind: #{kind}"
      end

      phase = :standby
      parent_oid = nil
      @repo.commits.each do |commit|
        start_with = commit.toyid.start_with? toyid
        if phase == :standby and start_with
          phase = :working
        elsif phase == :working and (not start_with)
          phase = :ended
        end

        if phase == :working
          parent_oid = commit.send(
            changed_commit_method,
            @repo.rugged_repo,
            message,
            parent_oid
          )
        elsif phase == :ended
          parent_oid = commit.parent_changed_commit(
            @repo.rugged_repo,
            parent_oid
          )
        end
      end
      raise "Invalid toyid: #{toyid}" if parent_oid.nil?

      @repo.rugged_repo.references.update(
        @repo.rugged_repo.head,
        parent_oid
      )
    end
  end
end
