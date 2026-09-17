module TransactionsHelper
  def transaction_entities_for(transaction)
    entities = @entities.select(&:active?)
    if transaction.entity.present? && !transaction.entity.active?
      entities << transaction.entity
    end
    entities.uniq.sort_by(&:name)
  end
end
