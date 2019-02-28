require 'test_helper'
require 'db/mssql'

class MSSQLColumnDateAndTimeTypesTest < Test::Unit::TestCase
  class CreateDateAndTimeTypes < ActiveRecord::Migration
    def self.up
      create_table 'date_and_time_types', force: true do |t|
        t.column :my_date, :date
        t.column :my_date_one, :date, null: false, default: '23/06/1912'

        t.column :my_datetime, :datetime
        t.column :my_datetime_one, :datetime,  null: false, default: '2019-02-28 05:59:06.789'

        t.column :my_smalldatetime, :smalldatetime
        t.column :my_smalldatetime_one, :smalldatetime,  null: false, default: '2019-02-28 05:59:06'

        t.column :my_time, :time
        t.column :my_time_one, :time,  null: false, default: '2019-02-28 05:59:06.456789'
      end
    end

    def self.down
      drop_table 'date_and_time_types'
    end
  end

  class DateAndTimeTypes < ActiveRecord::Base
    self.table_name = 'date_and_time_types'
  end

  def self.startup
    CreateDateAndTimeTypes.up
  end

  def self.shutdown
    CreateDateAndTimeTypes.down
    ActiveRecord::Base.clear_active_connections!
  end

  Type = ActiveRecord::ConnectionAdapters::MSSQL::Type

  def test_date_with_defaults
    column = DateAndTimeTypes.columns_hash['my_date']

    assert_equal :date,    column.type
    assert_equal true,     column.null
    assert_equal 'date',   column.sql_type
    assert_equal nil,      column.default

    type = DateAndTimeTypes.connection.lookup_cast_type(column.sql_type)
    assert_instance_of Type::Date, type
  end

  def test_date_custom
    column = DateAndTimeTypes.columns_hash['my_date_one']

    assert_equal :date,        column.type
    assert_equal false,        column.null
    assert_equal 'date',       column.sql_type
    assert_equal '1912-06-23', column.default

    type = DateAndTimeTypes.connection.lookup_cast_type(column.sql_type)
    assert_instance_of Type::Date, type
  end

  def test_datetime_with_defaults
    column = DateAndTimeTypes.columns_hash['my_datetime']

    assert_equal :datetime,  column.type
    assert_equal true,       column.null
    assert_equal 'datetime', column.sql_type
    assert_equal nil,        column.default

    type = DateAndTimeTypes.connection.lookup_cast_type(column.sql_type)
    assert_instance_of Type::DateTime, type
  end

  def test_datetime_custom
    column = DateAndTimeTypes.columns_hash['my_datetime_one']

    assert_equal :datetime,                    column.type
    assert_equal false,                        column.null
    assert_equal 'datetime',                   column.sql_type
    assert_equal '2019-02-28 05:59:06.456789', column.default

    type = DateAndTimeTypes.connection.lookup_cast_type(column.sql_type)
    assert_instance_of Type::DateTime, type
  end

  def test_smalldatetime_with_defaults
    column = DateAndTimeTypes.columns_hash['my_smalldatetime']

    assert_equal :smalldatetime,    column.type
    assert_equal true,              column.null
    assert_equal 'smalldatetime',   column.sql_type
    assert_equal nil,               column.default

    type = DateAndTimeTypes.connection.lookup_cast_type(column.sql_type)
    assert_instance_of Type::SmallDateTime, type
  end

  def test_smalldatetime_custom
    column = DateAndTimeTypes.columns_hash['my_smalldatetime_one']

    assert_equal :smalldatetime,               column.type
    assert_equal false,                        column.null
    assert_equal 'smalldatetime',              column.sql_type
    assert_equal '2019-02-28 05:59:06.456789', column.default

    type = DateAndTimeTypes.connection.lookup_cast_type(column.sql_type)
    assert_instance_of Type::SmallDateTime, type
  end
end
