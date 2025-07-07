class ZoomController < ApplicationController
  def index
  end

  def generate_jwt
    session_name = params[:session_name]
    role = params[:role] || 0 # Default to attendee role

    begin
      jwt_token = generate_signature(session_name, role.to_i)
      render json: { jwt: jwt_token, session_name: session_name }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def video_session
    @session_name = params[:session_name]
    @jwt_token = params[:jwt]
  end

  private

  def generate_signature(session_name, role)
    sdk_key = ENV['ZOOM_SDK_KEY']
    sdk_secret = ENV['ZOOM_SDK_SECRET']

    if sdk_key.blank? || sdk_secret.blank?
      raise "Missing ZOOM_SDK_KEY or ZOOM_SDK_SECRET environment variables, please add them in .env file."
    end

    iat = (Time.current.to_i) - 30
    exp = iat + (60 * 60 * 1) # 1 hour

    header = { alg: 'HS256', typ: 'JWT' }
    payload = {
      app_key: sdk_key,
      tpc: session_name,
      role_type: role,
      version: 1,
      iat: iat,
      exp: exp
    }

    JWT.encode(payload, sdk_secret, 'HS256', header)
  end
end 