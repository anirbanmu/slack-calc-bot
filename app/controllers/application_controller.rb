# frozen_string_literal: true

# Base controller
class ApplicationController < ActionController::API
  def no_content
    head :no_content
  end
end
