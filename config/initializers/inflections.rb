# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "regiao", "regioes"
  inflect.irregular "funcao", "funcoes"
  inflect.irregular "apoiador", "apoiadores"
  inflect.irregular "municipio", "municipios"
  inflect.irregular "bairro", "bairros"
  inflect.irregular "evento", "eventos"
  inflect.irregular "comunicado", "comunicados"
  inflect.irregular "convite", "convites"
  inflect.irregular "linkpainel", "linkpaineis"
  inflect.irregular "veiculo", "veiculos"
  inflect.irregular "visita", "visitas"
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
