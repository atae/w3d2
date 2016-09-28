require_relative 'model_base'

class QuestionLike < Base
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.find_by_user_id(user_id)
    likes = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        user_id = ?
    SQL
    raise "User ID #{user_id} not found" unless likes.length > 0
    likes.map { |like| QuestionLike.new(like) }
  end

  def self.find_by_question_id(question_id)
    likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL
    raise "Question ID #{question_id} not found" unless likes.length > 0
    likes.map { |like| QuestionLike.new(like) }
  end

  def self.likers_for_question_id(question_id)
    users = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes ON question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL
    raise "Nobody likes Question ID #{question_id}" if users.empty?
    users.map {|user| User.new(user)}
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        users
      JOIN
        question_likes ON question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL
    num_likes[0]["COUNT(*)"]
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL
    raise "User ID #{user_id} does not like any questions" if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    return nil unless n.is_a?(Integer)
    return nil if n <= 0
    questions = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes on question_likes.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    questions.map { |question| Question.new(question) }
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
        question_likes (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id, @id)
      UPDATE
        question_likes
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end

end
