class GenericJob < ApplicationJob
  queue_as :default

  def perform(mode, constant, *args)
    case mode
    when 'object'
      constant.constantize.find(args[0]).send(args[1].to_sym, *args[2..-1])
    when 'constant'
      constant.constantize.send(args[0].to_sym, *args[1..-1])
    else
      raise Kor::Exception, "unknown mode #{mode.inspect}"
    end
  end
end
