
require 'bundler/setup'
require 'time'
require 'xgt/ruby'

class Firestarter

  attr_accessor :wif, :chain_id, :rpc

  def initialize(config)
    @wif = config["private_key"]
    @wif = "5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n"
    @chain_id = config["chain_id"]
    @rpc = Xgt::Ruby::Rpc.new(config["host"])
  end

  def account_exist?(name)
    account(name).any?
  end

  def account(name)
    res = rpc.call('database_api.find_accounts', { 'accounts' => [name] })
    res["result"]["accounts"]
  end

  def create_account(name, keys)
    now = (Time.now + 360).utc.iso8601.gsub(/Z$/, '')

    txn = {
      'expiration' => now,
      'extensions' => [],
      'operations' => [
        [
          'account_create',
          {
            'fee' => '0.000 TESTS',
            'creator' => 'initminer',
            'new_account_name' => name,
            'owner' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [ [ keys["owner"], 1 ] ],
            },
            'active' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [ [ keys["active"], 1 ] ],
            },
            'posting' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [ [ keys["posting"], 1 ] ],
            },
            'memo_key' => keys["memo"],
            'json_metadata' => '',
            'extensions' => []
          }
        ]
      ],
      'ref_block_num' => 34960,
      'ref_block_prefix' => 883395518
    }

    signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
    account_create_chain_response = rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])

    amount = "5000"
    vesting_shares = "#{'%.6f' % amount.to_i}"

    txn = {
      'extensions' => [],
      'operations' => [[
        'delegate_vesting_shares',
      {
        'delegator' => "initminer",
        'delegatee' => name,
        'vesting_shares' => "#{vesting_shares} VESTS"
      }
      ]]
    }
    signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
    account_create_chain_response = rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])

    



    { 
      name: name,
      result: account_create_chain_response
    }
  end
end
