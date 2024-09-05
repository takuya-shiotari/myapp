require 'nokogiri'

$LOAD_PATH.unshift 'spec'
ENV['SKIP_DB_MIGRATION'] = '1'
require 'rails_helper'

# @param example_group [RSpec::Core::ExampleGroup]
# @return [Array<RSpec::Core::Example>]
def traverse_example_group(example_group)
  example_group.examples + example_group.children.map(&method(:traverse_example_group)).flatten
end

# @param example_group [RSpec::Core::ExampleGroup]
# @return [Hash{String => Integer}]
def generate_full_description_to_line_number(example_group)
  traverse_example_group(example_group)
    .each_with_object({}) { |example, obj| obj[example.metadata[:full_description]] = example.metadata[:line_number] }
end

# @param path [String]
# @return [Hash{String => Integer}]
def full_description_to_line_number_generator
  obj = {}
  ->(path) {
    return obj[path] if obj[path]

    example_group = eval(File.open(path).read)
    obj[path] = generate_full_description_to_line_number(example_group)
  }
end

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
        path: path,
        range: {
          start: {
            line: full_description_to_line_number[elem.attr('name')]
          }
        }
      }
    }
  end
end

File.open(ENV['REVIEWDOG_JSON_FILE_PATH'], 'w') do |f|
  Dir.glob(ENV['JUNIT_XML_FILE_PATH_PATTERN']).each do |junit_xml_file_path|
    rows = generate_reviewdog_rows(junit_xml_file_path)
    f.puts(rows.map(&:to_json).join("\n")) if rows.present?
  end
end
