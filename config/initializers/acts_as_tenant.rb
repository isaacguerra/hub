# Basic configuration for acts_as_tenant
# See https://github.com/ErwinM/acts_as_tenant for options

# By default do not require tenant to be set; we will set it from current logged-in apoiador
ActsAsTenant.configure do |config|
  config.require_tenant = false
end
