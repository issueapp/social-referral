# http://my.rails-royce.org/2010/07/21/email-validation-in-ruby-on-rails-without-regexp/
require 'mail'
 
class EmailValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    begin
      email = Mail::Address.new(value)
      valid = email.domain && email.address == value
      t = email.__send__(:tree)
      valid &&= t.domain.dot_atom_text.elements.size > 1
    rescue Exception => e
      valid = false
    end

    record.errors[attribute] << (options[:message] || "is invalid") unless valid
  end
end
