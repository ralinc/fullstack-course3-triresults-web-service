module Api

  class RacesController < ApplicationController

    rescue_from Mongoid::Errors::DocumentNotFound do |exception|
      @msg = "woops: cannot find race[#{params[:id]}]"

      if !request.accept || request.accept == "*/*"
        render plain: @msg, status: :not_found
      else
        render action: :error, status: :not_found
      end
    end

    rescue_from ActionView::MissingTemplate do |exception|
      render plain: "woops: unsupported content-type[#{request.accept}]", :status => 415
    end

    def index
      if !request.accept || request.accept == "*/*"
        render plain: "#{api_races_path}, offset=[#{params[:offset]}], limit=[#{params[:limit]}]"
      end
    end

    def show
      if !request.accept || request.accept == "*/*"
        render plain: api_race_path(params[:id])
      else
        @race = Race.find(params[:id])
        render :race
      end
    end

    def create
      if !request.accept || request.accept == "*/*"
        render plain: params[:race][:name]
      else
        @race = Race.new(race_params)

        if @race.save
          render plain: race_params[:name], status: :created
        else
          render json: @race.errors
        end
      end
    end

    def update
      @race = Race.find(params[:id])

      if @race.update(race_params)
        render json: @race
      else
        render json: @race.errors
      end
    end

    def destroy
      Race.find(params[:id]).destroy
      render nothing: true, status: :no_content
    end

    private

    def race_params
      params.require(:race).permit(:name, :date)
    end

  end

end
