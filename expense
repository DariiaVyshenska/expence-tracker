#! /usr/bin/env ruby
# frozen_string_literal: true

require 'pg'
require 'io/console'

PAD_ID = 3
PAD_DATE = 10
PAD_AMOUNT = 12

# Class that represents a single connection to expenses table & serves
# as interface for interacting tiwh this db table
class ExpenseData
  def initialize
    @connection = PG.connect(dbname: 'expenses')
    setup_schema
  end

  def print_all_rows
    print_full_record_info(all_records)
  end

  def add_a_row(row_info)
    amount = row_info[0]
    memo = row_info[1]
    date = row_info[2]
    abort 'You must provide an amount and memo.' unless amount && memo

    add_expense(amount.to_f, memo, date)
  end

  def search_term(term)
    sql_statement = 'SELECT * FROM expenses WHERE memo ILIKE $1'
    sel_records = @connection.exec_params(sql_statement, ["%#{term}%"])
    print_full_record_info(sel_records)
  end

  def delete_expense(el_id)
    sql_record = find_record_by_id(el_id)

    if sql_record
      sql_delete = 'DELETE FROM expenses WHERE id = $1'
      @connection.exec_params(sql_delete, [el_id])

      puts 'The following expense has been deleted:'
      print_record_rows(sql_record)
    else
      puts "There is no expense with the id '#{el_id}'."
    end
  end

  def delete_all_expenses
    puts 'This will remove all expenses. Are you sure? (y/n)'
    delete_expeses_db if are_you_sure?
  end

  private

  def add_expense(the_amount, the_memo, the_date)
    the_date ||= 'NOW()'
    sql_statement = 'INSERT INTO expenses(amount, memo, created_on) VALUES ($1, $2, $3)'
    @connection.exec_params(sql_statement, [the_amount, the_memo, the_date])
  end

  def setup_schema
    sql_check = <<~SQL
      SELECT COUNT(*) FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = 'expenses';
    SQL
    sql_statment = <<~SQL
      CREATE TABLE expenses (
        id serial PRIMARY KEY,
        amount numeric(6,2) NOT NULL CHECK (amount >= 0.01),
        memo text NOT NULL,
        created_on date NOT NULL
      );
    SQL
    the_check = @connection.exec(sql_check)[0]['count']
    @connection.exec(sql_statment) if the_check == '0'
  end

  def print_full_record_info(the_records)
    nrows = the_records.ntuples
    if nrows.positive?
      puts "There are #{nrows} expenses."
      print_record_rows(the_records)
      print_summary(the_records)
    else
      puts 'There are no expenses.'
    end
  end

  def all_records
    @connection.exec('SELECT * FROM expenses ORDER BY created_on ASC')
  end

  def are_you_sure?
    choice = nil
    loop do
      choice = $stdin.getch.downcase
      break if %w[y n].include?(choice)

      puts "You answered '#{choice}'. This is incorrect input. Please, try again."
    end
    yes?(choice)
  end

  def yes?(choice)
    choice == 'y'
  end

  def delete_expeses_db
    sql_record = 'DELETE FROM expenses'
    @connection.exec(sql_record)
    puts 'All expenses have been deleted.'
  end

  def find_record_by_id(the_id)
    sql_find = 'SELECT * FROM expenses WHERE id = $1'
    sql_record = @connection.exec_params(sql_find, [the_id])
    sql_record.ntuples.positive? ? sql_record : nil
  end

  def print_record_rows(the_records)
    the_records.each do |a_row|
      puts pad_row(a_row)
    end
  end

  def print_summary(the_records)
    puts '-' * 50
    total_sum = the_records.map { |row| row['amount'].to_f }.sum
    total_padding = PAD_ID + PAD_DATE + PAD_AMOUNT + extra_id_len + 1
    puts "Total#{format('%.2f', total_sum).rjust(total_padding)}"
  end

  def extra_id_len
    all_records.map { |row| row['id'].to_i }.max.to_s.size - PAD_ID
  end

  def pad_el(elnt, len = 0)
    elnt.to_s.rjust(len)
  end

  def pad_row(a_row)
    [pad_el(a_row['id'], PAD_ID + extra_id_len),
     pad_el(a_row['created_on'], PAD_DATE),
     pad_el(a_row['amount'], PAD_AMOUNT),
     pad_el(a_row['memo'])].join(' | ')
  end
end

# class that runs the app itself
class CLI
  def initialize
    @application = ExpenseData.new
  end

  def run(params)
    case params.shift
    when 'list' then @application.print_all_rows
    when 'add' then @application.add_a_row(params)
    when 'search' then @application.search_term(params[0])
    when 'delete' then @application.delete_expense(params[0])
    when 'clear' then @application.delete_all_expenses
    else print_help
    end
  end

  def print_help
    help_page = <<~MSG
      An expense recording system

      Commands:

      add AMOUNT MEMO [DATE] - record a new expense
      clear - delete all expenses
      list - list all expenses
      delete NUMBER - remove expense with id NUMBER
      search QUERY - list expenses with a matching memo field
    MSG

    puts help_page
  end
end
#===================== Main body ===============================================

CLI.new.run(ARGV)
