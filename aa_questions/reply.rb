require_relative 'model_base'

class Reply < Base
  attr_accessor :parent_id, :body, :user_id, :question_id
  attr_reader :id

  #finds children replies
  def self.find_by_parent_id(parent_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    raise "parent_id #{parent_id} not found" unless replies.length > 0
    replies.map {|reply| Reply.new(reply)}
  end

  def self.find_by_question_id(question_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    raise "Question #{question_id} not found" unless replies.length > 0
    replies.map {|reply| Reply.new(reply)}
  end

  def self.find_by_user_id(user_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    raise "User #{user_id} not found" unless replies.length > 0
    replies.map {|reply| Reply.new(reply)}
  end

  def initialize(options)
    @user_id = options['user_id']
    @parent_id = options['parent_id']
    @body = options['body']
    @question_id = options['question_id']
    @id = options['id']
  end

  def create
    raise "#{self} already in database." if @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id, @body, @parent_id)
      INSERT INTO
        replies (user_id, question_id, body, parent_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id, @body, @parent_id, @id)
      UPDATE
        replies
      SET
        user_id = ?, question_id = ?, @body = ?, @parent_id = ?
      WHERE
        id = ?
    SQL
  end

  def save
    if @id.nil?
      create
    else
      update
    end
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    raise "No parent reply" if @parent_id.nil?
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    Reply.find_by_parent_id(@id)
  end

end
