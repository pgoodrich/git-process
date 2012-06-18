require 'git-lib'
require 'GitRepoHelper'

describe Git::GitLib do

  describe "status" do
    include GitRepoHelper

    before(:each) do
      create_files(['.gitignore'])
      gitlib.commit('initial')
    end


    after(:each) do
      rm_rf(@tmpdir)
    end


    it "should handle added files" do
      create_files(['a', 'b', 'c'])

      gitlib.status.added.should == ['a', 'b', 'c']
    end


    it "should handle a modification on both sides" do
      change_file_and_commit('a', '')

      gitlib.checkout('master', :new_branch => 'fb')
      change_file_and_commit('a', 'hello')

      gitlib.checkout('master')
      change_file_and_commit('a', 'goodbye')

      gitlib.merge('fb') rescue

      status = gitlib.status
      status.unmerged.should == ['a']
      status.modified.should == ['a']
    end


    it "should handle an addition on both sides" do
      gitlib.checkout('master', :new_branch => 'fb')
      change_file_and_commit('a', 'hello')

      gitlib.checkout('master')
      change_file_and_commit('a', 'goodbye')

      gitlib.merge('fb') rescue

      status = gitlib.status
      status.unmerged.should == ['a']
      status.added.should == ['a']
    end


    it "should handle a merge deletion on fb" do
      change_file_and_commit('a', '')

      gitlib.checkout('master', :new_branch => 'fb')
      gitlib.remove('a', :force => true)
      gitlib.commit('removed a')

      gitlib.checkout('master')
      change_file_and_commit('a', 'goodbye')

      gitlib.merge('fb') rescue

      status = gitlib.status
      status.unmerged.should == ['a']
      status.deleted.should == ['a']
    end


    it "should handle a merge deletion on master" do
      change_file_and_commit('a', '')

      gitlib.checkout('master', :new_branch => 'fb')
      change_file_and_commit('a', 'hello')

      gitlib.checkout('master')
      gitlib.remove('a', :force => true)
      gitlib.commit('removed a')

      gitlib.merge('fb') rescue

      status = gitlib.status
      status.unmerged.should == ['a']
      status.deleted.should == ['a']
    end


    it "should return an empty result" do
      gitlib.status.added.should == []
      gitlib.status.deleted.should == []
      gitlib.status.modified.should == []
      gitlib.status.unmerged.should == []
    end

  end

end