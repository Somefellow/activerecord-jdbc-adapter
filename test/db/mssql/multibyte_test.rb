# encoding: utf-8
require 'jdbc_common'
require 'db/mssql'

class MSSQLMultibyteTest < Test::Unit::TestCase
  include MultibyteTestMethods

  def setup
    MigrationSetup.setup!
  end

  def teardown
    MigrationSetup.teardown!
  end

  def test_select_multibyte_string
    Entry.create!(:title => 'テスト', :content => '本文')
    if ar_version('4.0')
      entry = Entry.last
    else
      entry = Entry.find(:last)
    end
    assert_equal "テスト", entry.title
    assert_equal "本文", entry.content
    assert_equal entry, Entry.find_by_title("テスト")
  end

  def test_update_multibyte_string
    Entry.create!(:title => "テスト", :content => "本文")
    records = Entry.connection.select_all("select title, content from entries")
    assert_equal "テスト", records.first['title']
    assert_equal "本文", records.first['content']
  end

end
