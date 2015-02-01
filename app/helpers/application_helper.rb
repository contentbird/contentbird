module ApplicationHelper
  def advanced_mode?
    current_user && current_user.advanced?
  end
  def t_advanced key
    advanced_mode? ? t("#{key}_advanced") : t(key)
  end
  def can_display_type? type
    advanced_mode? || !type.by_platform? || type.available_to_basic_users?
  end
  def logo_must_blink?
    current_user && ANNOUNCEMENT_CODE.present? && session['announcement_seen'] != ANNOUNCEMENT_CODE && !current_user.announcement_clicked?(ANNOUNCEMENT_CODE)
  end
end
