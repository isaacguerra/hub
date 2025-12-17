class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  
  around_perform do |job, block|
    tenant = nil

    # Prefer explicit projeto_id passed as first arg (common pattern in our jobs/tests)
    if job.arguments.present? && job.arguments.first.is_a?(Hash) && job.arguments.first[:projeto_id]
      tenant = Projeto.find_by(id: job.arguments.first[:projeto_id])
    end

    # Fallback to current apoiador if available
    tenant ||= Current.apoiador&.projeto

    if tenant
      ActsAsTenant.with_tenant(tenant) { block.call }
    else
      # No tenant available — run without scoping
      block.call
    end
  ensure
    ActsAsTenant.current_tenant = nil
  end
end
