Pod::Spec.new do |s|
  s.name         = "sqlite3-objc"
  s.version      = "0.3"
  s.summary      = "SQLite3 Objective-C wrapper."
  s.homepage     = "https://github.com/youknowone/sqlite3-objc"
  s.license      = 'Public Domain (sqlite3 license)'
  s.author       = { "Jeong YunWon" => "sqlite3objc@youknowone.org" }
  s.source       = { :git => "https://github.com/youknowone/sqlite3-objc.git", :tag => "0.3" }
  s.source_files = 'SQLite/SQLite.h', 'SQLite/SLDatabase.{h|m}', 'SQLite/SLStatement.{h|m}', 'SQLite/SLError.{h|m}'
  s.header_dir   = 'SQLite'
  s.library   = 'sqlite3'
  s.dependency 'cdebug'
  s.requires_arc = false
end
