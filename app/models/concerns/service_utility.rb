module ServiceUtility

  def self.valid_float?(str)
    !!Float(str) rescue false
  end
end

