# Lesson Markdown renders heading ids and labelled permalink anchors. Keep both
# through `sanitize` so in-page links resolve and anchors have accessible names.
Rails.application.config.action_view.sanitized_allowed_attributes =
  Rails::HTML5::SafeListSanitizer.allowed_attributes + %w[id aria-label]
