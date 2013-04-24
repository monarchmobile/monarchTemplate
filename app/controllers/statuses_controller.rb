class StatusesController < ApplicationController

	def index
		@statuses = Status.all
	end

	def new
		@status = @status.new
	end

	def create
		@status = Status.new(params[:status])
		@status.save
	end
end