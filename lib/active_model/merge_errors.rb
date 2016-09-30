ActiveModel::Errors.class_eval do
  def <<(other)
    copy_messages_from(other)
    copy_details_from(other)

    self
  end

  private

  def copy_details_from(other)
    details.merge!(other.details) do |_, val_one, val_two|
      [*val_one] + [*val_two]
    end
  end

  def copy_messages_from(other)
    messages.merge!(other.messages) do |_, val_one, val_two|
      [*val_one] + [*val_two]
    end
  end
end
