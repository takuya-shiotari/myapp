require 'time'
require 'nokogiri'

testcases_by_name = Hash.new { |h, k| h[k] = [] }
Dir[ENV.fetch('JUNIT_XML_FILE_PATH_PATTERN')].each do |junit_xml_file_path|
  Nokogiri(File.open(junit_xml_file_path)).css('testsuite testcase').map do |elem|
    testcases_by_name[elem.attr('name')] << elem
  end
end

builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
  uniq_testcases = testcases_by_name.map do |name, testcases|
    uniq_testcase = testcases.first.dup
    uniq_testcase.children.remove
    testcases.map(&:children).reduce(:+).css('failure').uniq(&:text).each do |failure_elem|
      flaky_failure_elem = Nokogiri::XML::Node::new('flakyFailure', xml.doc)
      flaky_failure_elem['message'] = failure_elem['message']
      flaky_failure_elem['type'] = failure_elem['type']
      uniq_testcase.add_child(failure_elem)
      uniq_testcase.add_child(flaky_failure_elem)
    end
    uniq_testcase.set_attribute('time', testcases.map { _1.attr('time').to_f }.sum.fdiv(testcases.size).to_s)
    uniq_testcase
  end
  attrs = {
    tests: uniq_testcases.size,
    skipped: 0,
    failures: uniq_testcases.reject { _1.children.empty? }.size,
    errors: 0,
    time: uniq_testcases.map { _1.attr('time').to_f }.sum,
    timestamp: Time.now.iso8601
  }
  xml.testsuite(**attrs) do
    uniq_testcases.each { xml << _1.to_xml }
  end
end

puts builder.to_xml
