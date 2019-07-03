# frozen_string_literal: true

require 'spec_helper'

describe 'VaultApi' do
  # before(:each) do
  #   ENV['VAULT_ADDR'] = "http://127.0.0.1"
  #   ENV['VAULT_USERNAME'] = "test"
  #   ENV['VAULT_PASSWORD'] = "testpassword"
  #   ENV['VAULT_TOKEN'] = "aaaaaaaaaaabbbbbbbbbbb"
  #   ENV['VAULT_ENV'] = "development"
  # end

  # it "make connection to vault with VAULT_TOKEN" do
  #   expect(VaultApi).to receive(:token).and_return(ENV['VAULT_TOKEN']).twice
  #   expect(Vault::Client).to receive(:new).with({:address=>ENV['VAULT_ADDR'], :vault_token=> ENV['VAULT_TOKEN']})
  #   VaultApi.connection
  # end

  # it "make connection to vault with VAULT_USER and VAULT_PASSWORD" do
  #   # for mocking
  #   con = double
  #   auth = double
  #   # reset VAULT_TOKEN
  #   ENV.delete('VAULT_TOKEN')

  #   expect(con).to receive(:auth).and_return(auth)
  #   expect(auth).to receive(:userpass).with(ENV['VAULT_USER'],ENV['VAULT_PASSWORD'])
  #   expect(Vault::Client).to receive(:new).with({:address=>ENV['VAULT_ADDR']}).and_return(con)
  #   VaultApi.connection
  # end
end
