# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest', notification: false do
  watch(%r|^test/(.*)\/?(.*)_test\.rb|)
  watch(%r|^lib/(.*)([^/]+)\.rb|)            { |m| "test/unit/#{m[1]}#{m[2]}_test.rb" }
  watch(%r|^test/test_helper\.rb|)           { "test" }
  watch(%r|^app/controllers/(.*)\.rb|)       { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r|^app/mailers/(.*)\.rb|)           { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r|^app/helpers/(.*)\.rb|)           { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb|)            { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^app/jobs/(.*)([^/]+)\.rb|)       { |m| "test/unit/#{m[1]}#{m[2]}_test.rb" }
  watch(%r|^app/adapters/(.*)([^/]+)\.rb|)   { |m| "test/unit/#{m[1]}#{m[2]}_test.rb" }
end
