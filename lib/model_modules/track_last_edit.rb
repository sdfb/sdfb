module TrackLastEdit

 def self.included(base)
    base.attr_accessible :last_edit
    base.serialize :last_edit, Array
    base.before_create :initialize_last_edit
    base.before_create :check_if_approved
    base.before_update :check_if_approved_and_update_edit
  end

  protected 
  
  def initialize_last_edit
    self.last_edit = nil
  end

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def check_if_approved_and_update_edit
    new_last_edit = []
    new_last_edit.push(self.approved_by.to_i)
    new_last_edit.push(Time.now)
    self.last_edit = new_last_edit

    # update approval
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end
