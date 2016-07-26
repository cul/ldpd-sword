json.array!(@depositors) do |depositor|
  json.extract! depositor, :id
  json.url depositor_url(depositor, format: :json)
end
