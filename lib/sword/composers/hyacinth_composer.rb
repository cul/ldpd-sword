module Sword
module Composers
class HyacinthComposer

  # takes a DepositContent that was populated via one of the parsers
  # development heuristic: for now, will handle all attributes in DepositContent
  def compose_json(deposit_content, project)
    data = {}
    data[:project] = {string_key: project}
    data[:title] = deposit_content.title
    # puts JSON.generate data
    JSON.generate data
    
  end
end
end
end
