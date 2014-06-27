#!/usr/bin/env ruby

# file: polyrex-createobject.rb


require 'rexle'
require 'polyrex-schema'


class PolyrexCreateObject

  attr_accessor :parent_node
  attr_reader :obj


  def initialize(schema, id='1')

    @@id = id

    raise "missing schema" unless schema

    @schema = schema[/\/.*$/][1..-1]
    a = PolyrexSchema.new(schema).to_a
    @obj = attach_create_handlers(a[0])

    @obj.class_eval do 
      def record=(node)
        @parent_node = node
      end
    end

    self.instance_eval " def #{@obj.name.downcase}(h={}, id=@@id, &blk)

      new_parent = create_node(@parent_node, @schema, h, id).element('records')

      obj = @obj.new
      obj.record = new_parent
      obj.instance_variable_set(:@schema, @schema[/\\/(.*$)/,1])
      
      if block_given? then
        blk.call obj
      else
        obj
      end
    end
    "    

  end
  
  def id=(s)  @@id = s; self end
  def id() @@id end
  
  def record=(node)
    @parent_node = node
  end

  private

  def attach_create_handlers(a)

    #return if PolyrexCreateObject
    class_name = "root".capitalize
    parent_klass = if ObjectSpace.each_object(Class)\
                                      .to_a.map(&:name).include? 'Root' then
      Root
    else
      parent_klass = Object.const_set(class_name,Class.new)
    end
    result = scan parent_klass, a
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

    if params.length > 0 then
      a = child_schema[/[^\[]+(?=\])/].split(',')

      summary = record.root.element('summary')
      a.each do |field_name|  
        field = summary.element(field_name.strip)
        field.text = params[field_name.strip.to_sym]
      end
    end

    parent_node.add record.root

  end

  def scan(parent, list)

    cname = list.shift
    args = list

    r = []

    fields = []
    fields << args.shift while args.first.is_a? Symbol

    class_name = cname.capitalize

    klass = if ObjectSpace.each_object(Class)\
                              .to_a.map(&:name).include? class_name.to_s then
      Object.const_get class_name
    else
      Object.const_set(class_name,Class.new)
    end

    parent.class_eval do

      define_method :create_node do |parent_node, child_schema, 
                                                            params={}, id=nil|

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

      end # end of define_method :create_node

      define_method cname do |h, id=nil, &blk|

        id ||= @@id
        local_schema = "%s[%s]" % [cname, fields.join(',')]        
        new_parent = create_node(@parent_node, local_schema, h, id)\
                                                            .element('records')
        
        obj = klass.new

        def obj.record=(node)
          @parent_node = node
        end


        obj.record = new_parent
        #if block_given? then
        if blk then
          blk.call obj  
        else
          obj
        end
        self
      end
    end

    return klass unless args.any?

    next_rec = args.shift

    if next_rec.first.is_a? Array then

      remaining = scan(parent, *args) unless args.length < 1

      next_rec.each do |x| 

        child_klass = scan(klass,x)

        if remaining then

          child_klass.class_eval do

            define_method remaining.name.downcase.to_sym do |h, id=nil, &blk|

              id ||= @@id
              local_schema = "%s[%s]" % [record, fields.join(',')]

              new_parent = create_node(@parent_node, local_schema, 
                                                 params, id).element('records')
              obj = remaining.new
              obj.record = new_parent
              yield obj

              self
            end
          end
        end
      end

    else

      remaining = scan(klass, *list) unless args.length < 1
      scan(klass, next_rec)
      scan(r, remaining) if remaining
    end

    return klass
  end

end