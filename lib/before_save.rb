#before save pattern. TODO: add to tripod
module BeforeSave

  def save(opts={})
    before_save if self.valid? && defined?(:before_save)
    super(opts)
  end

  def save!(opts={})
    before_save if self.valid? && defined?(:before_save)
    super(opts)
  end

end