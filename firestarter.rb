
require 'bundler/setup'
require 'time'
require 'xgt/ruby'

class Firestarter

  attr_accessor :wif, :chain_id, :rpc

  def initialize()
    @rpc = Xgt::Ruby::Rpc.new(ENV["HOST"])
  end

  def account_exist?(address)
    account(address).any?
  end

  def account(address)
    res = rpc.call('database_api.find_accounts', { 'accounts' => [address] })
    res["accounts"]
  end

  def create_account(keys)

    # Create account
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

    signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [ENV["WIF"]], ENV["CHAIN_ID"])
    account_create_chain_response = rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])


    # Get wallet address we just created
    transaction_data = rpc.call('condenser_api.get_transaction', [account_create_chain_response['id']])
    account_names = rpc.call('condenser_api.get_account_names_by_block_num', [transaction_data['block_num']])
    account_name = account_names.first

    # [OPTIONAL] Set up a delegation for the new account
    amount = "5000"
    vesting_shares = "#{'%.6f' % amount.to_i}"

    txn = {
      'extensions' => [],
      'operations' => [[
        'delegate_vesting_shares',
      {
        'delegator' => "initminer",
        'delegatee' => account_name,
        'vesting_shares' => "#{vesting_shares} VESTS"
      }
      ]]
    }
    signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [ENV["WIF"]], ENV["CHAIN_ID"])
    account_create_chain_response = rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])

    # Return the response
    { 
      name: account_name,
      result: account_create_chain_response
    }
  end
end
