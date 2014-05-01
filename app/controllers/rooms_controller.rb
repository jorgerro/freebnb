
class RoomsController < ApplicationController

  before_action :require_signed_in!, only: [:new, :create]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @listings = @user.listings.order("created_at DESC")
      render :user_index
    else
      if current_user
        @listings = Room.where("owner_id != ?", current_user.id)
      else
        @listings = Room.all
      end
      render :index
    end
  end

  def new
    @room = Room.new
    render :new
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      redirect_to edit_room_url(@room)
    else
      flash.now[:errors] = @room.errors.full_messages
      render :new
    end
  end

  def show
    @room = Room.find(params[:id])
    @reviews = @room.reviews.order("created_at DESC")
    @owner = @room.owner
    @requests = @room.room_requests
    render :show
  end

  def edit
    @room = Room.find(params[:id])
    render :edit
  end

  def update
    @room = Room.find(params[:id])

    if @room.update(room_params)
      if params[:pictures]
        params[:pictures][:images].each do |image|
          @room.pictures.create!({ image: image })
        end
      end

      redirect_to @room
    else
      flash.now[:errors] = @room.errors.full_messages
      render :edit
    end
  end


  private
    def room_params
      params.require(:room).permit(:owner_id, :home_type, :room_type,
      :num_possible_guests, :address_city, :address_neighborhood,
      :street_address, :address_zip_code, :title, :description,
      :num_bedrooms, :num_bathrooms, :price_per_night )
    end

end