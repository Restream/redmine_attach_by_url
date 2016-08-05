module RedmineAttachByUrl
  class AttachmentByUrlPresenter
    def initialize(attach)
      @attach = attach
    end

    def as_json
      {
        'id'             => @attach.id,
        'state'          => state(),
        'state_text'     => translated_state_text(),
        'url'            => @attach.url,
        'complete_bytes' => @attach.complete_bytes,
        'total_bytes'    => @attach.total_bytes
      }
    end

    private

    def state
      @attach.errors.any? ? AttachmentByUrl::FAILED : @attach.state
    end

    def translated_state_text
      return @attach.errors.full_messages.join('; ') if @attach.errors.any?
      @attach.state_text.blank? ?
          I18n.t(@attach.state, scope: 'message_attachment_by_url_state') :
          @attach.state_text
    end
  end
end
