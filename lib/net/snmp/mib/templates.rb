module Net::SNMP::MIB
  module Templates
    DESCRIBE = '
<% nodes.each do |node| -%>
<%= node.module.nil? ? "" : "#{node.module.name}::" %><%= node.label %>
  - oid:       <%= node.oid %>
  - type:      <%= node.type %>
  - file:      <%= node.module.file unless node.module.nil? %>
  - descr:     <%= "\"#{node.description}\"" %>
  - enums:     <%=
  if !(node.enums.count == 0)
    node.enums.map { |e| "#{e[:label]}(#{e[:value]})" }.join(", ")
  else
    "NONE"
  end
%>
  - parent:    <%= "#{node.parent.label}(#{node.parent.oid})" unless node.parent.nil? %>
  - peers:     <%= node.peers.map { |n| "#{n.label}(#{n.subid})"}.join(", ") %>
  - next:      <%= node.next.oid unless node.next.nil? %>
  - next_peer: <%= node.next_peer.oid unless node.next_peer.nil? %>
  - children:  <%=
  if node.children.count > 0
    node.children.map { |n| "#{n.label}(#{n.subid})"}.join(", ")
  else
    "NONE"
  end
%>
<% end -%>
'.sub!("\n", "") # Remove leading newline

    JSON = json_template = '
[
<% nodes.each_with_index { |node, index| -%>
<%= ",\n" if index > 0 -%>
  {
    "name": "<%= node.module.nil? ? "" : "#{node.module.name}::" %><%= node.label %>",
    "oid": "<%= node.oid %>",
    "type": <%= node.type %>,
<% if node.enums && node.enums.count > 0 -%>
    "enums": { <%= node.enums.map { |enum| "\"#{enum[:label]}\": #{enum[:value]}" }.join(", ") %> },
<% end -%>
    "parent": <%= node.parent ? %Q["#{node.parent.oid}"] : "undefined" %>
  }<% } -%>

]
'.sub!("\n", "")
  end
end
