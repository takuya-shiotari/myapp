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
  return path if ENV.fetch('GITHUB_SHA', nil) || ENV.fetch('GITHUB_REPOSITORY')

  url = URI.parse("https://github.com/#{ENV.fetch('GITHUB_REPOSITORY')}/blob/#{ENV.fetch('GITHUB_SHA')}/#{path}").normalize.to_s
  "[#{path}](#{url})"
end

f.puts '## Flaky tests'

output_table_row(f, %w[File Name Message], header: true)

Dir[ENV.fetch('JUNIT_XML_FILE_PATH_PATTERN')].each do |junit_xml_file_path|
  Nokogiri(File.open(junit_xml_file_path)).css('testsuite testcase:has(failure)').map do |elem|
    output_table_row(f, [build_github_file_link(elem.attr('file')), elem.attr('name'), elem.css('failure').text])
  end
end
