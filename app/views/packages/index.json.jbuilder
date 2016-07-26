json.array!(@packages) do |package|
  json.extract! package, :id
  json.url package_url(package, format: :json)
end
