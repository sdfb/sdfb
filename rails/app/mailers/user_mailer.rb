class UserMailer < ActionMailer::Base  
  default from: "admin@6dfb.org"  
  
  def password_reset(user)  
    @user = user  
    mail :to => user.email, :subject => "Password Reset"  
  end  
end  