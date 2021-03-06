
class Notification < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  scope :unread, -> { where( is_read: false ) }

  belongs_to :user

  validates(:event_id,
    :user_id,
    :notifiable_id,
    :notifiable_type,
    presence: true)

  belongs_to :notifiable, polymorphic: true

  def default_url_options
    if Rails.env.development?
      { host: "localhost:3000" }
    else
      { host: "treebnb.herokuapp.com" }
    end
  end


  def event_name
    EVENTS[self.event_id]
  end

  def icon
    @icon = ""
    case self.event_name
    when :new_user_review
      @icon = '<i class="fa fa-comments-o"></i>'
    when :new_room_review
      @icon = '<i class="fa fa-comment-o"></i>'
    when :new_room_request
      @icon = '<i class="fa fa-home"></i>'
    when :request_approved
      @icon = '<i class="fa fa-check-square-o"></i>'
    when :request_denied
      @icon = '<i class="fa fa-ban"></i>'
    when :new_message
      @icon = '<i class="fa fa-envelope-o"></i>'
    end
    return @icon
  end

  def text
    message =
    case self.event_name
      when :new_user_review
        @review = self.notifiable
        "#{ @review.author.fname } #{ @review.author.lname } reviewed your profile."
      when :new_room_review
        @review = self.notifiable
        @room = @review.reviewable
        "#{ @review.author.fname } #{ @review.author.lname } reviewed #{ @room.display_title }"
      when :new_room_request
        @request = self.notifiable
        @room = @request.room
        "#{ @request.guest.fname } #{ @request.guest.lname } has requested your listing: #{ @room.display_title }"
      when :request_approved
        @request = self.notifiable
        @room = @request.room
        "Your request to stay at #{ @room.display_title } has been accepted."
      when :request_denied
        @request = self.notifiable
        @room = @request.room
        "Your request to stay at #{ @room.display_title } has been denied."
      when :new_message
        @message = self.notifiable
        @sender = @message.sender
        "You have a new message from #{ @sender.fname } #{ @sender.lname }."
      end
    return message
  end

  def url
    @url = '#'
    case self.event_name
    when :new_user_review
      @review = self.notifiable
      @url = "#{ user_url(self.user) }"
    when :new_room_review
      @review = self.notifiable
      @room = @review.reviewable
      @url = "#{ room_url(@room) }"
    when :new_room_request
      @request = self.notifiable
      @room = @request.room
      @url = "#{ manage_room_url(@room) }"
    when :request_approved
      @request = self.notifiable
      @user = @request.guest
      @url = "#{ user_room_requests_url(@user) }"
    when :request_denied
      @request = self.notifiable
      @user = @request.guest
      @url = "#{ user_room_requests_url(@user) }"
    when :new_message
      @message = self.notifiable
      @thread = @message.thread
      @url = "#{ message_thread_url(@thread) }"
    end
    return @url
  end

end