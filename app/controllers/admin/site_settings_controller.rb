module Admin
  class SiteSettingsController < BaseController
    before_action :set_setting

    def edit
      @tab = params[:tab].presence || "brand"
    end

    def update
      @tab = params[:tab].presence || "brand"
      if @setting.update(setting_params)
        redirect_to edit_admin_site_setting_path(tab: @tab), notice: "Settings saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_setting
      @setting = SiteSetting.current
    end

    def setting_params
      permitted = params.require(:site_setting).permit(
        # Identity
        :site_name, :tagline, :meta_description, :logo_mark, :logo_wordmark, :logo_image, :og_image,
        # Contact + socials
        :contact_email, :contact_phone, :instagram_url, :tiktok_url, :x_url, :whatsapp_url,
        # Brand
        :primary_color, :ember_color, :accent_color, :ink_color, :ash_color, :smoke_color,
        :display_font, :body_font,
        # Hero
        :hero_eyebrow, :hero_live_label, :hero_headline_line1, :hero_headline_line2,
        :hero_headline_accent, :hero_subtitle, :hero_cta_primary, :hero_cta_secondary, :hero_footer_mark,
        # Sections
        :vibe_eyebrow, :vibe_headline, :vibe_body,
        :dishes_eyebrow, :dishes_headline,
        :experiences_eyebrow, :experiences_headline,
        :testimonial_quote, :testimonial_author,
        :cta_headline, :cta_body,
        :about_eyebrow, :about_headline, :about_body,
        :contact_eyebrow, :contact_headline, :contact_body,
        :footer_tagline
      )

      # Color inputs come in as "#E8341A"; strip the leading # before saving
      %i[primary_color ember_color accent_color ink_color ash_color smoke_color].each do |key|
        permitted[key] = permitted[key].to_s.delete("#").upcase if permitted[key].present?
      end

      # Section toggles come as a hash of "1"/"0"
      if params[:site_setting][:sections].is_a?(ActionController::Parameters)
        toggles = params[:site_setting][:sections].permit(*SiteSetting::SECTION_KEYS).to_h
        permitted[:sections] = SiteSetting::SECTION_KEYS.index_with do |k|
          ActiveModel::Type::Boolean.new.cast(toggles[k.to_s] || toggles[k])
        end.stringify_keys
      end

      permitted
    end
  end
end
