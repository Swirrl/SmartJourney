#before save pattern. TODO: add to tripod
module BeforeSave

  def save(opts={})
    call_before_save
    super(opts)
  end

  def save!(opts={})
    call_before_save
    super(opts)
  end

  def call_before_save
    if defined?(:before_save)
      Rails.logger.debug "before save defined"
      if self.valid?
        Rails.logger.debug("valid")
        before_save
      else
        Rails.logger.debug("invalid")
        Rails.logger.debug(self.errors.messages.inspect)
      end
    else
      Rails.logger.debug "before save not defined"
    end
  end

end