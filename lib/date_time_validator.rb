module DateTimeValidator
  def is_valid_datetime?(dt)
    if dt
      begin
        dt = dt.is_a?(DateTime) ? dt : DateTime.parse(dt)
      rescue ArgumentError
        Rails.logger.debug "#{dt.inspect} is invalid"
        false
      end
      Rails.logger.debug "#{dt.inspect} is valid"
      true
    else
      false
    end

  end
end