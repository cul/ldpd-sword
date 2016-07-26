json.array!(@sword_deposits) do |sword_deposit|
  json.extract! sword_deposit, :id
  json.url sword_deposit_url(sword_deposit, format: :json)
end
