module Projects
  class ApplicationRecord < ActiveRecord::Base
    # abstract_class, never primary_abstract_class: the host owns that one.
    self.abstract_class = true
  end
end
