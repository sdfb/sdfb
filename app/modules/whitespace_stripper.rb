module WhitespaceStripper

  # 
  # Remove leading and trailing whitespace from a column name
  # @param *args [Symbol] A list of column names to remove whitespace from
  # 
  # @return [Void] 
  def remove_trailing_spaces(*args)
    args.each do |column_name|
      if self.respond_to?(column_name.to_sym) && self.send(column_name)
        self.send(column_name).strip!
      end
    end
  end
end