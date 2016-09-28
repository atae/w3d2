require_relative 'model_base'

class User < Base
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_name(fname, lname)
    users = QuestionDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    raise "#{fname} #{lname} not found" unless users.length > 0
    users.map { |user| User.new(user) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  # def create
  #   raise "#{self} already in database." if @id
  #   QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname)
  #     INSERT INTO
  #       users (fname, lname)
  #     VALUES
  #       (?, ?)
  #   SQL
  #   @id = QuestionDBConnection.instance.last_insert_row_id
  # end
  #
  # def update
  #   raise "#{self} not in database" unless @id
  #   QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
  #     UPDATE
  #       users
  #     SET
  #       fname = ?, lname = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end
  #
  # def save
  #   if @id.nil?
  #     create
  #   else
  #     update
  #   end
  # end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    karma = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(question_likes.user_id) /
        CAST(COUNT(DISTINCT questions.id) AS FLOAT) as karma
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.user_id = ?
    SQL
  end

end
