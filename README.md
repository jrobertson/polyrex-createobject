A Polyrex-createobject example

    require 'requestor'

    eval Requestor.read('http://rorbuilder.info/r/ruby/') {|x| x.require 'polyrex-createobject' }

    obj = PolyrexCreateObject.new('a/b[name]/c[name,count]/d[name,age]')
    doc = Rexle.new('<a><summary/><records><b><summary><name>123</name></summary><records></records></b></records></a>')
    obj.record = doc.root
    obj.b(name: 'fun') do |create|
      create.c(name: 'fun5') do |create|
        create.d name: 'fun7', age: 11
      end
    end

    puts doc.to_s pretty: true

<pre>
<?xml version='1.0' encoding='UTF-8'?>
<a>
  <summary></summary>
  <records>
    <b>
      <summary>
        <name>123</name>
      </summary>
      <records></records>
    </b>
    <b id='2'>
      <summary>
        <name>fun</name>
        <format_mask>[!name]</format_mask>
        <recordx_type>polyrex</recordx_type>
        <schema>b[name]</schema>
      </summary>
      <records>
        <c id='3'>
          <summary>
            <name>fun5</name>
            <count></count>
            <format_mask>[!name] [!count]</format_mask>
            <recordx_type>polyrex</recordx_type>
            <schema>c[name,count]</schema>
          </summary>
          <records>
            <d id='4'>
              <summary>
                <name>fun7</name>
                <age>11</age>
                <format_mask>[!name] [!age]</format_mask>
                <recordx_type>polyrex</recordx_type>
                <schema>d[name,age]</schema>
              </summary>
              <records></records>
            </d>
          </records>
        </c>
      </records>
    </b>
  </records>
</a>
</pre>

polyrex polyrexcreateobject gem testing
