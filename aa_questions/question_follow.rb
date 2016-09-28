require_relative 'model_base'

class QuestionFollow < Base
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.find_by_question_id(question_id)
    follows = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_id = ?
    SQL
    raise "Question #{question_id} not found" unless follows.length > 0
    follows.map { |follow| QuestionFollow.new(follow) }
  end

  def self.find_by_user_id(user_id)
    follows = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        user_id = ?
    SQL
    raise "User_id #{user_id} not found" unless follows.length > 0
    follows.map { |follow| QuestionFollow.new(follow) }
  end

  def self.followers_for_question_id(question_id)
    users = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL
    raise "No followers for Question ID #{question_id}" unless users.length > 0
    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL
    raise "No questions followed by user id #{user_id}" unless questions.length > 0
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    return nil unless n.is_a?(Integer)
    return nil if n <= 0
    questions = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    questions.map {|question| Question.new(question)}
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database." if @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id, @id)
      UPDATE
        question_follows
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end

end
