
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
    @wifs = ENV['XGT_WIFS'] \
      &.split(';') \
      &.map { |pair| pair.split(':') } \
      &.map { |pair| [pair[0], pair[1].split(',')] } \
      &.to_h \
      || default_wifs

  end

  def current_wifs
    @wifs[current_name] || []
  end

  def create_wallet(keys)
    txn = {
      'operations' => [{
        'type' => 'wallet_create_operation',
        'value' => {
          'fee' => {
            'amount' => '0',
            'precision' => 8,
            'nai' => '@@000000021'
          },
          # 'creator' => keys['wallet_name'],
          'creator' => keys['wallet_name'],
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
        }
      }]
    }

    id = rpc.broadcast_transaction(txn, current_wifs, chain_id)

    { 
      'keys' => keys, 
      'id' => id 
    }
  end
end
