module DateTimeValidator
  def is_valid_datetime?(dt)
    if dt
      begin
        dt = dt.is_a?(DateTime) ? dt : DateTime.parse(dt)
      rescue ArgumentError => e
        Rails.logger.debug "#{dt.inspect} is invalid"
        return false
      end
      Rails.logger.debug "#{dt.inspect} is valid"
      return dt
    else
      return false
    end

  end
end