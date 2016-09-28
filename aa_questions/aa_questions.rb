require 'sqlite3'
require 'singleton'
['question_like','question','reply','user','question_follow'].each do |mod|
  require_relative mod
end

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end


end
