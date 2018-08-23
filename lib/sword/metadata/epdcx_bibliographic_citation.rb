# http://purl.org/eprint/terms/bibliographicCitation
module Sword
  module Metadata
    class EpdcxBibliographicCitation
      attr_accessor :issue,
                    :publish_year,
                    :start_page,
                    :title,
                    :volume
    end
  end
end
