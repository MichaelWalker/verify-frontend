require 'feature_helper'
require 'api_test_helper'
describe 'pages redirect with see other', type: :request do
  it 'sets a see other for redirects' do
    set_stub_federation_in_session
    stub_api_saml_endpoint
    post '/SAML2/SSO', 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state'
    expect(response.status).to eql 303
  end
end
