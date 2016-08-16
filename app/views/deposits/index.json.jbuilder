json.array!(@deposits) do |deposit|
  json.extract! deposit, :id
  json.url deposit_url(deposit, format: :json)
end
