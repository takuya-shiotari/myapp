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

# @param junit_xml_file_paths [Array<String>]
# @return [Array<Hash{Symbol => String}>]
def generate_table_rows(junit_xml_file_paths)
  junit_xml_file_paths.flat_map do |junit_xml_file_path|
    Nokogiri(File.open(junit_xml_file_path)).css('testsuite testcase:has(failure)').map do |elem|
      {
        file: build_github_file_link(elem.attr('file')),
        name: elem.attr('name'),
        message: elem.css('failure').first.text,
        count: elem.css('failure').count.to_s,
      }
    end
  end
end

rows = generate_table_rows(Dir[ENV.fetch('JUNIT_XML_FILE_PATH_PATTERN')])

f.puts '## Flaky tests'

if rows.size > 0
  output_table_row(f, %w[File Name Message Count], header: true)
  rows.each { |row| output_table_row(f, row.values_at(:file, :name, :message, :count)) }
else
  f.puts ':white_check_mark: no flaky test'
end
