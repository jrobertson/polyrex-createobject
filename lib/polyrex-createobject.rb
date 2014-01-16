#!/usr/bin/env ruby

# file: polyrex-createobject.rb

require 'polyrex-schema'
require 'rexle'


class PolyrexCreateObject

  attr_accessor :parent_node
  
  def initialize(schema, id='1')
    @@id = id

    @schema = schema

    if @schema then
      a = @schema.split('/')        
      @rpaths = (a.length).times.inject({}) do |r| 
        r.merge ({a.join('/').gsub(/\[[^\]]+\]/,'') => a.pop}) 
      end

      values = @rpaths.values.reverse

      @rpaths.keys.reverse.each.with_index do |key,i |
        @rpaths[key] = values[i..-1].join('/')
      end

      names = @rpaths.to_a[0..-2].map {|k,v| [v[/[^\[]+/], k]}
      
      attach_create_handlers(names)
    end
  end
  
  def id=(s)  @@id = s; self end
  def id() @@id end
  
  def record=(node)
    @parent_node = node
  end

  def attach_create_handlers(names)
    methodx = names[0..-2].map do |name, xpath|

# nested records
%Q(
  def #{name}(params={}, id=nil,&blk) 

    id ||= @@id
    orig_parent = @parent_node
    new_parent = create_node(@parent_node, @rpaths['#{xpath}'], params, id).element('records')

    if block_given? then
      self.record = new_parent
      blk.call(self) 
    end

    self.record = orig_parent

    self
  end
)
    end

    name, xpath = names[-1]

# top record    
    methodx << %Q(
def #{name}(params={}, id=nil,&blk)
  id ||= @@id
  orig_parent = @parent_node
  self.record = @parent_node.element('records') unless @parent_node.name == 'records'
  self.record = create_node(@parent_node, @rpaths['#{xpath}'], params, id).element('records')        
  blk.call(self) if block_given?
  self.record = orig_parent

  self
end
)

    self.instance_eval(methodx.join("\n"))
    
  end

  def create_node(parent_node, child_schema, params={}, id=nil)


    buffer = PolyrexSchema.new(child_schema[/^[^\/]+/]).to_s
    record = Rexle.new buffer     

    if id then
      @@id.succ!
    else
      if @@id.to_i.to_s == @@id.to_s then
        @@id.succ!
      else
        @@id = @parent_node.element('count(//@id)').to_i + 2
      end
    end

    record.root.add_attribute({'id' => @@id.to_s.clone})

    a = child_schema[/[^\[]+(?=\])/].split(',')

    summary = record.root.element('summary')
    a.each do |field_name|  
      field = summary.element(field_name.strip)
      field.text = params[field_name.strip.to_sym]
    end

    parent_node.add record.root

  end


  def xpath_to_rpath(xpath)
    xpath.split('/').each_slice(2).map(&:last).join('/').gsub(/\[[^\]]+\]/,'')
  end

end