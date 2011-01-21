#!/usr/bin/ruby

# file: polyrex-createobject.rb

require 'polyrex-schema'
require 'rexle'

class PolyrexCreateObject

  attr_accessor :id, :parent_node
  
  def initialize(schema, id='1')
    @id = id

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

    create_node(@parent_node, @rpaths['#{xpath}'], params, id).element('records')
    blk.call(self) if block_given?

    self
  end
)
    end

    name, xpath = names[-1]
    
    methodx << %Q(
def #{name}(params={}, id=nil,&blk)
  self.record = @parent_node.element('records') unless @parent_node.name == 'records'
  self.record = create_node(@parent_node, @rpaths['#{xpath}'], params, id).element('records')        
  blk.call(self) if block_given?

  self
end
)

    self.instance_eval(methodx.join("\n"))
    
  end

  def create_node(parent_node, child_schema, params={}, id=nil)
    record = Rexle.new PolyrexSchema.new(child_schema).to_s
    @id = id if id

    record.root.add_attribute({'id' => @id.to_s.clone})
    if @id.to_i.to_s == @id.to_s then
      @id = @id.to_s.succ
    else
      @id = @parent_node.element('count(//@id)').to_i + 2
    end

    a = child_schema[/[^\[]+(?=\])/].split(',')
    a.each do |field_name|  
      field = record.element('summary/' + field_name)
      field.text = params[field_name.to_sym]
    end

    parent_node.add record.root

  end


  def xpath_to_rpath(xpath)
    xpath.split('/').each_slice(2).map(&:last).join('/').gsub(/\[[^\]]+\]/,'')
  end

end