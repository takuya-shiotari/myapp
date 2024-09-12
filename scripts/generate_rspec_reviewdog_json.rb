require 'nokogiri'

$LOAD_PATH.unshift 'spec'
ENV['SKIP_DB_MIGRATION'] = '1'
require 'rails_helper'

# RSpecのExampleGroupを再帰的に辿り、全てのExampleを取得する
# @param example_group [RSpec::Core::ExampleGroup]
# @return [Array<RSpec::Core::Example>]
def collect_all_examples(example_group)
  example_group.examples + example_group.children.flat_map { collect_all_examples(_1) }
end

# ExampleGroupからfull_descriptionとline_numberの対応関係を生成する
# @param example_group [RSpec::Core::ExampleGroup]
# @return [Hash{String => Integer}]
def map_description_to_line_number(example_group)
  collect_all_examples(example_group)
    .each_with_object({}) { |example, obj| obj[example.metadata[:full_description]] = example.metadata[:line_number] }
end

# キャッシュを利用して、ファイルパスに対応するfull_descriptionとline_numberの対応関係を生成する
# @param path [String]
# @return [Proc]
def cached_description_to_line_number
  cache = {}
  ->(path) {
    cache[path] ||= begin
      example_group = eval(File.read(path)) # rubocop:disable Security/Eval
      map_description_to_line_number(example_group)
    end
  }
end

# JUnit XMLファイルからRDFormatのデータを生成する
# @param junit_xml_file_path [String]
# @return [Array<Hash>]
def parse_junit_failures(junit_xml_file_path)
  description_mapper = cached_description_to_line_number
  Nokogiri(File.open(junit_xml_file_path)).css('testsuite testcase failure').map do |failure_elem|
    elem = failure_elem.parent
    path = elem.attr('file')
    description_to_line = description_mapper.call(path)
    {
      message: failure_elem.text,
      location: {
        path: path,
        range: {
          start: {
            line: description_to_line[elem.attr('name')]
          }
        }
      }
    }
  end
end

File.open(ENV.fetch('REVIEWDOG_JSON_FILE_PATH'), 'w') do |f|
  Dir[ENV.fetch('JUNIT_XML_FILE_PATH_PATTERN')].each do |junit_xml_file_path|
    rows = parse_junit_failures(junit_xml_file_path)
    f.puts(rows.map(&:to_json).join("\n")) if rows.present?
  end
end
