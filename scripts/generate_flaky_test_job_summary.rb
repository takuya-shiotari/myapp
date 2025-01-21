require 'nokogiri'

f = ENV['OUTPUT_FILE'] ? File.open(ENV['OUTPUT_FILE'], 'w') : STDOUT

# @param file [IO]
# @param row [Array<String>]
# @param header [Boolean]
def output_table_row(file, row, header: false)
  file.puts "| #{row.map { _1.gsub("\n", '<br>') }.join(' | ')} |"
  file.puts "| #{row.map { _1.gsub(/./, '-') }.join(' | ')} |" if header
end

# @param path [String]
# @return [String]
def build_github_file_link(path)
  return path if ENV.fetch('GITHUB_SHA', nil).nil? || ENV.fetch('GITHUB_REPOSITORY', nil).nil?

  url = URI.parse("https://github.com/#{ENV.fetch('GITHUB_REPOSITORY')}/blob/#{ENV.fetch('GITHUB_SHA')}/#{path}").normalize.to_s
  "[#{path}](#{url})"
end

f.puts '## Flaky tests'

output_table_row(f, %w[File Name Message Count], header: true)

has_flaky_tests = false
Dir[ENV.fetch('JUNIT_XML_FILE_PATH_PATTERN')].each do |junit_xml_file_path|
  Nokogiri(File.open(junit_xml_file_path)).css('testsuite testcase:has(failure)').map do |elem|
    failure_elem = elem.css('failure')
    output_table_row(f, [build_github_file_link(elem.attr('file')), elem.attr('name'), failure_elem.first.text, failure_elem.count.to_s])
    has_flaky_tests = true
  end
end
unless has_flaky_tests
  f.puts ':white_check_mark: no flaky test'
end
