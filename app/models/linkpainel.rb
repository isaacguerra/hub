# == Schema Information
# Linkpainel representa um atalho/painel compartilhado por um Apoiador

class Linkpainel < ApplicationRecord
  acts_as_tenant :projeto

  belongs_to :apoiador

  validates :slug, presence: true, uniqueness: true
  validates :url, presence: true
  validates :status, presence: true
end
