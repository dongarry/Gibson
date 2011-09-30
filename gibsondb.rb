require 'rubygems'
require 'active_record'


ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => ":memory:"
)

ActiveRecord::Schema.define do
    create_table :gibsondb do |table|
        table.column :rec_id,           :integer
        table.column :filename,         :string
        table.column :no_of_words,      :integer
        table.column :no_of_sentences,  :integer
        table.column :inverted_file,    :string
        table.column :ferret_terms,     :string
        table.column :wordnet,          :string
        table.column :summary     ,     :string
        table.column :notes       ,     :string
        table.column :verbs       ,     :string
        table.column :nouns       ,     :string
        table.column :wordnet_rep ,     :string
    end
end

class Gibson_rec < ActiveRecord::Base
  set_table_name :gibsondb
end
