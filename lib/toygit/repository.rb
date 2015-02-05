require 'rugged'

module ToyGit
  class Repository
    attr_reader :rugged_repo
    attr_reader :commits

    def initialize(dir = '.')
      @rugged_repo = Rugged::Repository.discover(dir)
      @commits = prepare_commits
    end

    def commit_from_toyid(toyid)
      i = @commits.find_index do |commit|
        commit.toyid and commit.toyid.start_with? toyid
      end
      raise 'Invalid ToyId: %s' % toyid if i.nil?
      @commits[i]
    end

    private

    def prepare_commits
      commits = []

      master = @rugged_repo.ref('refs/heads/master')
      walker = Rugged::Walker.new(@rugged_repo)
      walker.push master.target
      walker.each do |rugged_commit|
        if rugged_commit.parents.count > 1
          raise 'Invalid ToyGit Repository: merge commit %s' % rugged_commit.oid
        end
        commits << Commit.new(rugged_commit)
      end

      commits.reverse
    end
  end
end
