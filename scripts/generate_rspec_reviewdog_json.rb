require 'nokogiri'

$LOAD_PATH.unshift 'spec'
require 'rails_helper'

# RSpecのExampleGroupを再帰的に辿り、全てのExampleを取得する
# @param example_group [RSpec::Core::ExampleGroup]
# @return [Array<RSpec::Core::Example>]
def traverse_example_group(example_group)
  example_group.examples + example_group.children.flat_map(&method(:traverse_example_group))
end

# ExampleGroupからfull_descriptionとline_numberの対応関係を生成する
# @param example_group [RSpec::Core::ExampleGroup]
# @return [Hash{String => Integer}]
def generate_full_description_to_line_number(example_group)
  traverse_example_group(example_group)
    .each_with_object({}) { |example, obj| obj[example.metadata[:full_description]] = example.metadata[:line_number] }
end

# キャッシュを利用して、ファイルパスに対応するfull_descriptionとline_numberの対応関係を生成する
# @param path [String]
# @return [Hash{String => Integer}]
def full_description_to_line_number_generator
  cache = {}
  lambda do |path|
    return cache[path] if cache[path]

    example_group = eval(File.read(path))
    cache[path] = generate_full_description_to_line_number(example_group)
  end
end

# JUnit XMLファイルからReviewdog形式のデータを生成する
# @param junit_xml_file_path [String]
# @return [Array<Hash>]
def generate_reviewdog_rows(junit_xml_file_path)
  generator = full_description_to_line_number_generator
  Nokogiri(File.open(junit_xml_file_path)).css('testsuite testcase failure').map do |failure_elem|
    elem = failure_elem.parent
    path = elem.attr('file')
    full_description_to_line_number = generator.call(path)
    {
      message: failure_elem.text,
      location: {
        path: path
      }
    }
  end
end

File.open(ENV['REVIEWDOG_JSON_FILE_PATH'], 'w') do |f|
  Dir[ENV['JUNIT_XML_FILE_PATH_PATTERN']].each do |junit_xml_file_path|
    rows = generate_reviewdog_rows(junit_xml_file_path)
    f.puts(rows.map(&:to_json).join("\n")) if rows.present?
  end
end
