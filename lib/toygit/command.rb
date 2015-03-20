module ToyGit
  class Command
    def initialize(repo)
      @repo = repo
    end

    def list
      head_hash = @repo.rugged_repo.head.target.oid
      @repo.commits.each do |commit|
        star = (head_hash == commit.rugged_commit.oid ? '*' : '')
        toyid = commit.toyid.nil? ? '(null)' : commit.toyid[0,6]
        puts "#{toyid}#{star}\t"\
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
      commit.hunks.each do |hunk|
        puts hunk.path
        puts hunk.header
        hunk.lines.each { |line| puts line }
      end
    end

    def hash(toyid)
      commit = @repo.commit_from_toyid(toyid)
      puts commit.rugged_commit.oid
    end

    def self.init
      toplevel_path = `git rev-parse --show-toplevel`.strip
      prepare_path = File.join(toplevel_path, '.git/hooks/prepare-commit-msg')
      prepare_command = 'toygit prepare "$1"'
      if File.exists? prepare_path
        $stderr.puts '\'prepare-commit-msg\' hook already exists.'
        $stderr.puts "Append \'#{prepare_command}\' to the hook file manually."
        return 1
      end
      File.write(prepare_path, prepare_command + "\n")
      File.chmod(0755, prepare_path)
      return 0
    end

    def self.prepare(commit_msg_file_name)
      commit_msg = File.read(commit_msg_file_name)
      return 0 if commit_msg =~ /^#{ToyGit::Constant::TOYID}(.+)$/

      commit_content = "tree #{`git write-tree`}"
      parent = `git rev-parse "HEAD^0" 2>/dev/null`
      commit_content << "parent #{parent}" if $?.success?
      commit_content << "author #{`git var GIT_AUTHOR_IDENT`}"
      commit_content << "committer #{`git var GIT_COMMITTER_IDENT`}"
      toy_id = `echo "#{commit_content}" | git hash-object -t commit --stdin`
      commit_msg << "\n#{ToyGit::Constant::TOYID}#{toy_id}"
      File.write(commit_msg_file_name, commit_msg)
      return 0
    end
  end
end
