#!/usr/bin/env ruby

require 'bundler/setup'

require 'fileutils'

require 'active_record'

APPLE_EPOCH = Time.gm(2001,1,1).to_i

ActiveRecord::Base.establish_connection adapter: 'sqlite3',
                                        database: File.expand_path('~/Library/Containers/com.apple.Notes/Data/Library/Notes/NotesV2.storedata')

class Note < ActiveRecord::Base
  self.table_name = 'ZNOTE'

  belongs_to :body, primary_key: :Z_PK, foreign_key: :ZBODY
  default_scope { order('ZDATECREATED ASC') }

  def created_at
    Time.at(self.ZDATECREATED + APPLE_EPOCH)
  end
end

class Body < ActiveRecord::Base
  self.table_name = 'ZNOTEBODY'

  # belongs_to :note, primary_key: :Z_PK, foreign_key: :ZNOTE

  alias_attribute :html_string, :ZHTMLSTRING
end

FileUtils.mkdir_p 'output'

Note.all.each.with_index(1) do |note, index|
  file = File.new "output/#{index}.html", 'w'
  file.write "<!-- #{note.created_at} -->" + "\n"
  file.write note.body.html_string + "\n"
  file.close
end
