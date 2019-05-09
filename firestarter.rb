
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

  def create_account(name)
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
              'key_auths' => [
                [
                  'TST7xue5ESY1xHhDZj6dw2igXCwoHobA3cnxffacvp4XMzwfzLZu4',
                  1
                ]
              ]
            },
            'active' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [
                [
                  'TST6Yp3zeaYNU7XJF2MxoHhDcWT4vGgVkzTLEvhMY6g5tvmwzn3tN',
                  1
                ]
              ]
            },
            'posting' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [
                [
                  'TST5Q7ZdopjQWZMwiyZk11W5Yhvsfu1PG3f4qsQN58A7XfHP34Hig',
                  1
                ]
              ]
            },
            'memo_key' => 'TST5u69JnHZ3oznnwn71J6VA4r5oVJX6Xu3dpbFVoHpJoZXnbDfaW',
            'json_metadata' => '',
            'extensions' => []
          }
        ]
      ],
      'ref_block_num' => 34960,
      'ref_block_prefix' => 883395518
    }

    signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
    rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])
  end
end
