#!/usr/bin/ruby

# file: polyrex-createobject.rb

require 'polyrex-schema'
require 'rexml/document'

class PolyrexCreateObject
  include REXML

  attr_accessor :id
  
  def initialize(schema, id=nil)
    @id = id
    @id ||= 1
    @schema = schema
    a = @schema.split('/')        

    @rpaths = (a.length).times.inject({}) {|r| r.merge ({a.join('/').gsub(/\[[^\]]+\]/,'') => a.pop}) }
    names = @rpaths.to_a[0..-2].map {|k,v| [v[/[^\[]+/], k]}
    
    attach_create_handlers(names)

  end

  def record=(node)
    @parent_node = node
  end

  def attach_create_handlers(names)
    methodx = names[0..-2].map do |name, xpath|
%Q(
  def #{name}(params={}, id=nil,&blk) 
    records = XPath.first(@parent_node,'records')
    self.record = create_node(records, @rpaths['#{xpath}'], params, id)    
    blk.call(self) if blk
    self
  end
)
    end

    name, xpath = names[-1]
    
    methodx << %Q(
def #{name}(params={}, id=nil,&blk)  
  self.record = XPath.first(@parent_node.root,'records')
  self.record = create_node(@parent_node, @rpaths['#{xpath}'], params, id)
  blk.call(self) if blk
  self
end
)

    self.instance_eval(methodx.join("\n"))
    
  end

  def create_node(parent_node, child_schema, params={}, id=nil)

    record = Document.new PolyrexSchema.new(child_schema).to_s
    @id = id if id

    record.root.add_attribute('id', @id.to_s)
    if @id.to_s[/[0-9]/] then
      @id = (@id.to_i + 1).to_s
    else
      @id = XPath.first(@parent_node.root, 'count(//@id)').to_i + 2
    end
    
    a = child_schema[/[^\[]+(?=\])/].split(',')
    a.each do |field_name|  
      field = XPath.first(record.root, 'summary/' + field_name)
      field.text = params[field_name.to_sym]
    end

    parent_node.add record.root

  end


  def xpath_to_rpath(xpath)
    xpath.split('/').each_slice(2).map(&:last).join('/').gsub(/\[[^\]]+\]/,'')
  end

end
