require 'csv'

LINE_PATTERN = /^(?:.+) x (?<ops>.+) ops\/sec ±(?<error>.+) \((?<runs>.+) runs sampled\)$/

def extract_pieces(line)
  LINE_PATTERN.match(line)
end

File.open 'table.html', 'w' do |html|
  CSV.open 'benchmark.csv', 'wb' do |csv|
    csv << [
      'pairs',
      'object assign ops',
      'object assign error',
      'object assign runs',
      'spread ops',
      'spread error',
      'spread runs',
    ]

    html.write <<~HTML
      <table>
        <theader>
          <tr>
            <th rowspan="2">Pairs</th>
            <th colspan="3">Array#reduce with Object.assign</th>
            <th colspan="3">Array#reduce with spread</th>
          </tr>
          <tr>
            <th>Operations/Second</th>
            <th>Margin of Error</th>
            <th>Runs Sampled</th>
            <th>Operations/Second</th>
            <th>Margin of Error</th>
            <th>Runs Sampled</th>
          </tr>
        </theader>
        <tbody>
    HTML

    File.open 'benchmark.log', 'r' do |file|
      file.each_line.each_slice(6).each do |lines|
        number_of_pairs = lines[0][/\d+/].to_i
        object_assign = extract_pieces(lines[2])
        spread = extract_pieces(lines[3])

        csv << [
          number_of_pairs,
          *object_assign.captures,
          *spread.captures,
        ]

        html.write <<~HTML
          <tr>
            <td>#{number_of_pairs}</td>
            #{object_assign.captures.map { |c| "<td>#{c}</td>" }.join("\n")}
            #{spread.captures.map { |c| "<td>#{c}</td>" }.join("\n")}
          </tr>
        HTML
      end
    end

    html.write <<~HTML
        </tbody>
      </table>
    HTML
  end
end
