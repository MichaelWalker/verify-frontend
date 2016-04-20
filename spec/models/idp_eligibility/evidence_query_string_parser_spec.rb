require 'spec_helper'
require 'models/idp_eligibility/evidence'
require 'models/idp_eligibility/evidence_query_string_parser'

module IdpEligibility
  describe EvidenceQueryStringParser do
    it 'should return an empty array when no parameters are found' do
      result = EvidenceQueryStringParser.parse('')
      expect(result).to eql []
    end

    it 'should ignore all keys other than selected-evidence' do
      result = EvidenceQueryStringParser.parse('blah=passport&foo=driving_licence')
      expect(result).to eql([])
    end

    it 'should return repeated parameters in an array' do
      result = EvidenceQueryStringParser.parse('selected-evidence=passport&selected-evidence=driving_licence')
      expect(result).to eql([:passport, :driving_licence])
    end

    it 'should return single parameters in an array' do
      result = EvidenceQueryStringParser.parse('selected-evidence=passport')
      expect(result).to eql([:passport])
    end

    it 'should ignore empty values' do
      result = EvidenceQueryStringParser.parse('selected-evidence=&selected-evidence=passport')
      expect(result).to eql([:passport])
    end

    it 'should drop unrecognised inputs' do
      result = EvidenceQueryStringParser.parse('selected-evidence=something')
      expect(result).to eql([])
    end

    it 'should convert landline_phone into landline' do
      result = EvidenceQueryStringParser.parse('selected-evidence=landline_phone')
      expect(result).to eql([:landline])
    end
  end
end