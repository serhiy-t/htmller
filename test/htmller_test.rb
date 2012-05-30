require 'test_helper'

class HtmllerTest < ActiveSupport::TestCase
  test "Classes are loaded" do
    hash = Htmller.build_hash '', '<node></node>'
    assert_equal Hash, hash.class
    assert_equal 0, hash.length
  end

  test "Absent node souldn't be added'" do
    hash = Htmller.build_hash "
    set :testnode, :query => '//node', :value => :hash
                              ", ''
    assert_equal false, (hash.has_key? :testnode)
  end

  test "Simple hash node" do
    hash = Htmller.build_hash "
    set :testnode, :query => '//node', :value => :hash
                              ", '<node></node>'
    assert_equal true, (hash.has_key? :testnode)
    assert_equal Hash, hash[:testnode].class
  end

  test "Simple text node" do
    hash = Htmller.build_hash "
    set :testnode, :query => '//node', :value => :text
                              ", '<node>hello, world</node>'
    assert_equal String, hash[:testnode].class
    assert_equal 'hello, world', hash[:testnode]
  end

  test "Text node in hash node" do
    hash = Htmller.build_hash "
    set :testnode, :query => '//node', :value => :hash do
      set :innernode, :query => '//innernode', :value => :text
    end
                              ", '<node><innernode>hello, world</innernode></node>'
    assert_equal 'hello, world', hash[:testnode][:innernode]
  end

  test "Text node postprocessing" do
    hash = Htmller.build_hash "
    hash :testnode, :query => '//node' do
      text :innernode, :query => '//innernode' do |value|
        value + '!'
      end
    end
                              ", '<node><innernode>hello, world</innernode></node>'
    assert_equal 'hello, world!', hash[:testnode][:innernode]
  end

  test "Constant node in hash node" do
    hash = Htmller.build_hash "
    set :testnode, :query => '//node', :value => :hash do
      set :innernode, :const => '!!!'
    end
                              ", '<node></node>'
    assert_equal '!!!', hash[:testnode][:innernode]
  end

  test "Block result node in hash node" do
    hash = Htmller.build_hash "
    set :testnode, :query => '//node', :value => :hash do
      set :innernode, :value => :block do
        'hello'
      end
    end
                              ", '<node></node>'
    assert_equal 'hello', hash[:testnode][:innernode]
  end

  test "List node" do
    hash = Htmller.build_hash "
    set :testnode, :query => '//node/x', :value => :list do
      push :value => :text
    end
                              ", '<node><x>1</x><x>2</x></node>'
    assert_equal Array, hash[:testnode].class
    assert_equal 2, hash[:testnode].length
    assert_equal '1', hash[:testnode][0]
    assert_equal '2', hash[:testnode][1]
  end

  test "Load rules from files" do
    hash = Htmller.build_hash :test_rules, '<node>hello</node>'

    assert_equal 'hello', hash[:test]
  end

  test "Get info from attribute" do
    hash = Htmller.build_hash "
      set :testnode, :query => '//node', :value => :attr_id
                              ", '<node id="hello">hello, world</node>'
    assert_equal String, hash[:testnode].class
    assert_equal 'hello', hash[:testnode]
  end
end
