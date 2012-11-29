class AttachmentByUrl < ActiveRecord::Base
  unloadable

  IN_PROGRESS = :in_progress
  COMPLETE = :complete
  FAILED = :failed

  STATES = [IN_PROGRESS, COMPLETE, FAILED]

  validates_presence_of :url, :state
  validates_inclusion_of :state, :in => STATES

end
