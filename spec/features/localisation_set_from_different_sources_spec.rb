require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'locale is set based on multiple sources', type: :feature do
  def set_locale_cookie_to(locale)
    session_cookies = set_session_cookies!
    visit public_send("about_#{locale}_path")
    expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of locale
    session_cookies
  end

  context "when I visit a page" do
    it 'will set the locale cookie to en if the language is English' do
      set_locale_cookie_to('en')
    end

    it 'will set the locale cookie to cy if the page language is Welsh' do
      set_locale_cookie_to('cy')
    end

    it 'will change the value of the locale cookie when the user changes from English to Welsh' do
      set_locale_cookie_to('en')
      click_on 'Cymraeg'
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'cy'
    end
  end

  context "when submitting saml" do
    RSpec.shared_examples "submitting SAML" do |locale|
      it "will render the start page in #{locale} after SAML submission when locale cookie set to #{locale}" do
        set_locale_cookie_to(locale)
        stub_federation
        stub_api_saml_endpoint

        visit('/test-saml')
        click_button 'saml-post'

        expect(current_path).to eql(public_send("start_#{locale}_path"))
      end

      it "will render the response processing page in #{locale} after SAML response when locale cookie set to #{locale}" do
        session_cookies = set_locale_cookie_to(locale)
        stub_matching_outcome
        session_id = session_cookies[CookieNames::SESSION_ID_COOKIE_NAME]
        stub_api_authn_response(session_id)

        visit('/test-saml')
        click_button 'saml-response-post'

        expect(current_path).to eql(public_send("response_processing_#{locale}_path"))
      end
    end

    include_examples "submitting SAML", 'en'
    include_examples "submitting SAML", 'cy'

    it "will render the start page in English when no cookie or form parameters are set" do
      stub_federation
      stub_api_saml_endpoint

      visit('/test-saml')
      click_button 'saml-post'

      expect(current_path).to eql(start_en_path)
    end

    RSpec.shared_examples "submitting SAML with form params" do |form_locale, cookie_locale|
      locale_cookie_message = cookie_locale.nil? ? " is unset" : " set to #{cookie_locale}"
      it "will render the start page in #{form_locale} after SAML submission when locale cookie #{locale_cookie_message} and form param set to #{form_locale}" do
        if cookie_locale
          set_locale_cookie_to(cookie_locale)
        else
          expect(cookie_value(CookieNames::VERIFY_LOCALE)).to be_nil
        end
        stub_federation
        stub_api_saml_endpoint

        visit('/test-saml')
        click_button "saml-post-with-#{form_locale}-language"

        expect(current_path).to eql(public_send("start_#{form_locale}_path"))
      end

      it "will render the response processing page in #{form_locale} after SAML Response submission when locale cookie #{locale_cookie_message} and form param set to #{form_locale}" do
        session_cookies = set_session_cookies!
        if cookie_locale
          visit public_send("about_#{cookie_locale}_path")
          expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of cookie_locale
        else
          expect(cookie_value(CookieNames::VERIFY_LOCALE)).to be_nil
        end
        stub_matching_outcome
        session_id = session_cookies[CookieNames::SESSION_ID_COOKIE_NAME]
        stub_api_authn_response(session_id)

        visit('/test-saml')
        click_button "saml-response-post-with-#{form_locale}-language"

        expect(current_path).to eql(public_send("response_processing_#{form_locale}_path"))
      end
    end

    include_examples "submitting SAML with form params", 'en', 'en'
    include_examples "submitting SAML with form params", 'en', 'cy'
    include_examples "submitting SAML with form params", 'cy', 'en'
    include_examples "submitting SAML with form params", 'cy', 'cy'
    include_examples "submitting SAML with form params", 'cy'
    include_examples "submitting SAML with form params", 'en'
  end
end