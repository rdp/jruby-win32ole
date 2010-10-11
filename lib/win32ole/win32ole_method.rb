class WIN32OLE_METHOD
  attr_accessor :oletype, :typeinfo

  def initialize(*args)
    # TODO: 2-arg missing currently unuised oletype ivar
    if args.length == 6 # Internal initializer
      @oletype,  @typeinfo, @owner_typeinfo, @desc, @docs, @index = *args
    elsif args.length == 2 # Normal constructor
      @oletype, name = WIN32OLE_TYPEValue(args[0]), SafeStringValue(args[1])
      all_methods(@oletype.typeinfo) do |ti, oti, desc, docs, index|
        if docs.name.downcase == name.downcase
          @typeinfo, @owner_typeinfo, @desc, @docs, @index = ti, oti, desc, docs, index
          break;
        end
      end
      raise WIN32OLERuntimeError.new "not found: #{name}" if !@typeinfo
    else # Error
      raise ArgumentError.new("2 for #{args.length}")
    end
  end

  def dispid
    @desc.memid
  end

  def helpcontext
    @docs.help_context
  end

  def helpstring
    @docs.doc_string
  end

  def helpfile
    @docs.help_file
  end

  def invkind
    @desc.invkind
  end

  def name
    @docs.name
  end
  alias :to_s :name

  def params
    arr = []
    @desc.parameters.to_a.each_with_index do |param, i|
      arr << WIN32OLE_PARAM.new(self, i, param)
    end
    arr
  end

  def size_opt_params
    @desc.opt_params_count
  end
  
  def size_params
    @desc.params_count
  end

  def visible?
    (@desc.flags & (FuncDesc::FUNCFLAG_FRESTRICTED | FuncDesc::FUNCFLAG_FHIDDEN |
      FuncDesc::FUNCFLAG_FNONBROWSABLE)) == 0
  end

  def inspect
    name
  end

  include WIN32OLE::Utils
end
