module DepositsHelper
  def resubmit_deposit(original_deposit)
    # original_deposit = Deposit.find(params[:id])
    endpoint = Sword::Endpoints::Endpoint.get_endpoint(original_deposit.collection_slug,
                                                       original_deposit.depositor_user_id)

    path_to_deposit_contents = original_deposit.content_path

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("About to resubmit deposit for deposit id: #{original_deposit.id}:" \
                      "Collection slug: #{original_deposit.collection_slug}, " \
                      "Username: #{original_deposit.depositor_user_id}, " \
                      "Path to contents: #{path_to_deposit_contents}"
                     )

    endpoint.handle_deposit(path_to_deposit_contents)

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Following is a re-deposit:" \
                      "Title: #{endpoint.deposit_title.truncate_words(10)}, " \
                      "Files: #{endpoint.documents_to_deposit}, " \
                      "Hyacinth item pid: #{endpoint.adapter_item_identifier}, " \
                      "Hyacinth asset pids: #{endpoint.asset_pids}, " \
                      "Path to SWORD contents: #{path_to_deposit_contents}"
                     )

    # create Deposit instance to store deposit info in database
    resubmit_deposit = Deposit.new
    resubmit_deposit.depositor_user_id = @depositor_user_id
    resubmit_deposit.collection_slug = @collection_slug
    resubmit_deposit.deposit_files = endpoint.documents_to_deposit
    resubmit_deposit.title = "(RE-DEPOSIT) " + original_deposit.title
    resubmit_deposit.item_in_hyacinth = endpoint.adapter_item_identifier
    resubmit_deposit.asset_pids = endpoint.asset_pids
    resubmit_deposit.ingest_confirmed = endpoint.confirm_ingest
    resubmit_deposit.content_path = path_to_deposit_contents
    resubmit_deposit.save
  end
end
