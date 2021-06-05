require 'bundler/setup'
require 'time'
require 'xgt/ruby'

class Firestarter

  attr_accessor :wif, :chain_id, :rpc, :current_name

  def initialize()
    @rpc = Xgt::Ruby::Rpc.new(ENV["XGT_HOST"])
    @chain_id = ENV['XGT_CHAIN_ID'] \
      || "4e08b752aff5f66e1339cb8c0a8bca14c4ebb238655875db7dade86349091197"
    @current_name = ENV['XGT_NAME'] || 'XGT0000000000000000000000000000000000000000'
    @wif = ENV['WIF']
  end

  def create_wallet(keys)

    txn = {
      'extensions' => [],
      'operations' => [
        {
          'type' => 'wallet_create_operation',
          'value' => {
            'fee' => {
              'amount' => '0',
              'precision' =>  8,
              'nai' => '@@000000021'
            },
            'creator' => current_name,
            'recovery' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [[keys['recovery_public'], 1]]
            },
            'money' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [[keys['money_public'], 1]]
            },
            'social' => {
              'weight_threshold' => 1,
              'account_auths' => [],
              'key_auths' => [[keys['social_public'], 1]]
            },
            'memo_key' => keys['memo_public'],
            'json_metadata' => '',
            'extensions' => []
          }
        }
      ]
    }

    signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
    rpc.call('transaction_api.broadcast_transaction', [signed])


    # Add entries to enable mining on this wallet address
    update_txn = {
      'extensions' => [],
      'operations' => [{
        'type' => 'witness_update_operation',
        'value' => {
          'owner' => wallet_name,
          'url' => 'http://witness-category/my-witness',
          # 'block_signing_key' => keys.call['recovery_public'],
          'block_signing_key' => keys.call['witness_public'],
          'props' => {
            'account_creation_fee' => {'amount'=>'0','precision'=>8,'nai'=>'@@000000021'}
          },
          'fee' => {'amount'=>'0','precision'=>8,'nai'=>'@@000000021'}
        }
      }]
    }

    signing_keys = keys.call['recovery_private']
    signed = Xgt::Ruby::Auth.sign_transaction(rpc, update_txn, [signing_keys], chain_id)
    response = rpc.call('transaction_api.broadcast_transaction', [signed])


    { 
      'keys' => keys, 
      'create_tx_res' => id,
      'update_tx_res' => response,
    }
  end
end
