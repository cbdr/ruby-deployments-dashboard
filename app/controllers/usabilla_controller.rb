class UsabillaController < ApplicationController
  def index
    @buttons = button_names

    @feedback = []
    gather_feedback if do_feedback?
  end

  def cats
  end

  def button_names
    UsabillaApi.websites_button.retrieve(params)
  end

  def gather_feedback
    params[:days_ago] = 3
    @feedback = UsabillaApi.websites_feedback.retrieve(params)
  end

  def reformat_date(date_string)
    DateTime.iso8601(date_string).strftime('%b %d, %Y')
  end

  def do_feedback?
    params[:id].present?
  end

  def cat_information
    AdorableCat.get_cat_data
  end

  def cat_count
    if params[:count].present? && (params[:count].to_i > 10)
      params[:count].to_i
    else
      10
    end
  end
end
