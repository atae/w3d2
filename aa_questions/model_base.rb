require 'byebug'

class Base
  DATABASES = {:User => 'users',
              :Question => 'questions',
              :QuestionLike => 'question_likes',
              :Reply => 'replies',
              :QuestionFollow => 'question_follows'}

  def self.all
    object_type = self.to_s.to_sym
    data = QuestionDBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{DATABASES[object_type]}
    SQL
    data.map {|datum| self.new(datum)}
  end

  def self.find_by_id(id)
    object_type = self.to_s.to_sym
    datum = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{DATABASES[object_type]}
      WHERE
        id = ?
    SQL
    return self.new(datum[0])
  end

  def create
    object_type = self.to_s.to_sym
    ivars = self.instance_variables
    values = []
      ivars.each do |ivar|
        values << ivar
      end

    ivars.delete(:@id)
    len = ivars.length
    qmarks = (['?']*len).join(', ')
    column_string = ivars.join(', ').gsub('@','')
    ivar_string = ivars.join(', ')
    puts column_string
    puts ivar_string
    raise "#{self} already in database." if @id
    QuestionDBConnection.instance.execute(<<-SQL, *ivars)
      INSERT INTO
        #{DATABASES[object_type]} (#{column_string})
      VALUES
        (ivar_string)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  # def update
  #   raise "#{self} not in database" unless @id
  #   QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id, @body, @parent_id, @id)
  #     UPDATE
  #       replies
  #     SET
  #       user_id = ?, question_id = ?, @body = ?, @parent_id = ?
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
end
