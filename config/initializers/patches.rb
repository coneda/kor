module Kernel
  def ArgumentArray(value)
    value.is_a?(Array) ? value : [value]
  end
end
