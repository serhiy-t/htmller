module Htmller
  def self.build_hash rules, source
    if rules.is_a? Symbol
      filename = "lib/htmller_engines/#{rules.to_s}.rb"
      File.open filename, 'rt' do |file|
        (HtmllerEngine.new file.read, source.to_s).build_hash
      end
    else
      (HtmllerEngine.new rules.to_s, source.to_s).build_hash
    end
  end

  private

  DEBUG = true

  class HtmllerException < Exception
    def self.raise_with_message message = ""
      raise HtmllerException, message
    end
  end

  class Scope
    attr_accessor :node, :obj
  end

  class HtmllerEngine
    def initialize rules, source
      @rules = rules
      @source = source
      @root = Scope.new
      @context = []

      @root.node = Nokogiri::HTML(@source)
      @root.obj = {}

      push_context @root.node, @root.obj
    end

    def build_hash
      begin
        eval(@rules, binding)
      rescue HtmllerException
        raise
      rescue Exception => e
        if DEBUG
          raise
        else
          HtmllerException.raise_with_message "Unable parse rules: #{e.message}"
        end
      end

      @root.obj
    end

    def push_context node, obj
      new_scope = Scope.new
      new_scope.node = node
      new_scope.obj = obj
      @context << new_scope
    end

    def pop_context
      @context.pop
    end

    def root
      @root
    end

    def context
      @context.last
    end

    def for_scope params = {}
      if block_given? and ((params.has_key? :node) or (params.has_key? :object))
        push_context (params[:node] || context.node), (params[:object] || context.obj)
        yield
        pop_context
      end
    end

    def each query
      if block_given?
        (context.node.xpath query).each do |node|
          for_scope :node => node do
            yield
          end
        end
      end
    end

    def set field, params = {}, &block
      result = calc_object params, &block

      unless result.nil?
        context.obj[field] = result
      end
    end

    def push params = {}, &block
      result = calc_object params, &block

      unless result.nil?
        context.obj.push result
      end
    end

    private

    def calc_object params = {}
      if params.has_key? :const
        return params[:const]
      end

      result = nil

      params[:query] ||= '.'

      unless params.has_key? :value or (not ([:hash, :list, :text].include? params[:value]))
        HtmllerException.raise_with_message 'Unknown value type'
      end

      query_result = context.node.xpath params[:query]
      result_found = (not query_result.empty?)

      if params[:value] == :list
        new_list = []

        if block_given?
          query_result.each do |query_node|
            for_scope :node => query_node, :object => new_list do
              yield
            end
          end
        end

        result = new_list
      end

      if result_found
        if params[:value] == :hash
          query_node = query_result.first
          new_object = {}

          result = new_object

          if block_given?
            for_scope :node => query_node, :object => new_object do
              yield
            end
          end
        elsif params[:value] == :text
          result = query_result.first.text
        elsif params[:value] == :block
          unless block_given?
            HtmllerException.raise_with_message 'No block provided'
          end

          result = yield
        end
      end

      result
    end
  end
end
