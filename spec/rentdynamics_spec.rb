require 'securerandom'
require "spec_helper"
require "time"

RSpec.describe RentDynamics do

  it "has a version number" do
    expect(RentDynamics::VERSION).not_to be nil
  end

  it "base url defaults to production url on class initialization" do
    access_key = SecureRandom.hex
    secret_access_key = SecureRandom.hex
    rd_client = RentDynamics::Client.new(access_key, secret_access_key)
    expect(rd_client.instance_variable_get(:@base_url)).to eq('https://api.rentdynamics.com')
  end

  it "base url updates to dev if development is true on class initialization" do
    access_key = SecureRandom.hex
    secret_access_key = SecureRandom.hex
    rd_client = RentDynamics::Client.new(access_key, secret_access_key, true)
    expect(rd_client.instance_variable_get(:@base_url)).to eq('https://api-dev.rentdynamics.com')
  end

  it "nonce generator with body should calculate pre-determined nonce that matches python library calculations" do
    access_key = 'abcdefg'
    secret_access_key = 'hijklmnop'
    rd_client = RentDynamics::Client.new(access_key, secret_access_key)
    timestamp = '1589499853135'
    endpoint = '/communityGroups/2/referrerSources'
    body = {"adSourceID":2,"communityGroupID":2,"referrerID":1}
    nonce = rd_client.get_nonce(timestamp, endpoint, body)
    expect(nonce).to eq('064677157bd77eecdeba8745222a3b5e498f011a')
  end

  it "nonce generator should calculate pre-determined nonce that matches python library calculations" do
    access_key = 'abcdefg'
    secret_access_key = 'hijklmnop'
    rd_client = RentDynamics::Client.new(access_key, secret_access_key)
    timestamp = '1589499853135'
    endpoint = '/communityGroups/2/referrerSources'
    body = {"referrerID":1,"adSourceID":2,"communityGroupID":2}
    nonce = rd_client.get_nonce(timestamp, endpoint, body)
    expect(nonce).to eq('064677157bd77eecdeba8745222a3b5e498f011a')
  end

  it "sort_body should alphabetize items in a hash" do
    payload = { orange: 1, blue: 2 }
    rd_client = RentDynamics::Client.new('', '')
    sorted_body = rd_client.sort_body(payload)
    expect(sorted_body).to eq({ blue: 2, orange: 1 })
  end

  it "sort_body should handle hashes containing arrays" do
    payload = {
        'orange': 5,
        'blue': [a: 1, c: 5, b: 2]
    }
    rd_client = RentDynamics::Client.new('', '')
    sorted_body = rd_client.sort_body(payload)
    expect(sorted_body).to eq({ blue: [a: 1, b: 2, c: 5], orange: 5 })
  end

  it "sort_body should handle hashes containing hashes with number values" do
    payload = {
        'orange': 5,
        'blue': {
            'yellow': 3,
            'red': 4
        }
    }
    rd_client = RentDynamics::Client.new('', '')
    sorted_body = rd_client.sort_body(payload)
    expect(sorted_body).to eq({ blue: { 'red': 4, 'yellow': 3 }, orange: 5 })
  end

  it "sort_body should handle hashes containing hashes with string values" do
    payload = {
        'orange': '5',
        'blue': {
            'yellow': '3',
            'red': '4'
        }
    }
    rd_client = RentDynamics::Client.new('', '')
    sorted_body = rd_client.sort_body(payload)
    expect(sorted_body).to eq({ blue: { 'red': '4', 'yellow': '3' }, orange: '5' })
  end

end
