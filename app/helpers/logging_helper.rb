module LoggingHelper
  def log_received_deposit_post(collection_slug,
                                depositor_user_id,
                                path_to_deposit_contents)
    Rails.logger.warn("Received deposit POST. Collection slug: #{collection_slug}, " \
                      "Username: #{depositor_user_id}, " \
                      "Path to contents: #{path_to_deposit_contents}")
  end
  def log_deposit_result_info(title,
                              files,
                              item_pid,
                              asset_pids,
                              path_content)
    Rails.logger.warn("Title: #{title}, " \
                      "Files: #{files}, " \
                      "Hyacinth item pid: #{item_pid}, " \
                      "Hyacinth asset pids: #{asset_pids}, " \
                      "Path to SWORD contents: #{path_content}"
                     )    
  end
end
