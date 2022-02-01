class User < ApplicationRecord
  belongs_to :company
  has_many :group_users
  has_many :groups, through: :group_users

  before_destroy :check_deletable

  validates \
    :first_name,
    :last_name,
    :email,
    presence: true

  validates \
    :email,
    uniqueness: {
      case_insensitive: true
    }

  def active
    return active?
  end

  def active=(active)
    if active
      self.archived_at = nil
    else
      self.archived_at ||= Time.now
    end
  end

  def active?
    archived_at.blank?
  end

  def archived?
    archived_at.present?
  end

  def archive!
    write_attribute(:archived_at, Time.now)
    save!
  end

  def unarchived?
    archived_at.blank?
  end

  def unarchive!
    write_attribute(:archived_at, nil)
    save!
  end

  def check_deletable
    return if deletable

    errors.add(:base, 'The specified user could not be deleted.')
    throw :abort
  end
end
