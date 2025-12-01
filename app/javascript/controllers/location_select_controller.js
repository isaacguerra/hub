import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["municipio", "regiao", "bairro"]

  connect() {
    // Salva as opções originais na memória ao conectar
    this.regiaoOptions = Array.from(this.regiaoTarget.options)
    this.bairroOptions = Array.from(this.bairroTarget.options)
    
    // Aplica o filtro inicial
    this.filterRegioes()
  }

  filterRegioes() {
    const municipioId = this.municipioTarget.value
    const selectedRegiaoId = this.regiaoTarget.value
    
    // Limpa o select de regiões (mantendo apenas a primeira opção "Todas")
    this.regiaoTarget.innerHTML = ""
    this.regiaoTarget.appendChild(this.regiaoOptions[0])

    // Adiciona apenas as regiões que pertencem ao município selecionado
    // Se nenhum município estiver selecionado, mostra todas as regiões (comportamento opcional)
    // OU podemos decidir mostrar nenhuma. Aqui vou manter a lógica de mostrar apenas se coincidir,
    // mas se municipioId for vazio, mostraremos todas para permitir filtro livre se desejado,
    // ou podemos restringir.
    // Para corrigir o bug relatado: "ao selecionar municipio... esta listando todas",
    // vamos focar no filtro.
    
    this.regiaoOptions.slice(1).forEach(option => {
      const optionMunicipioId = option.dataset.municipioId
      
      // Se tem município selecionado, filtra. Se não tem, mostra tudo.
      if (!municipioId || optionMunicipioId == municipioId) {
        this.regiaoTarget.appendChild(option)
      }
    })
    
    // Tenta restaurar a seleção anterior se ainda for válida
    this.regiaoTarget.value = selectedRegiaoId
    
    // Se a seleção não for mais válida (foi removida), reseta para o valor vazio
    if (this.regiaoTarget.value !== selectedRegiaoId) {
      this.regiaoTarget.value = ""
    }

    // Atualiza os bairros baseados na nova região (ou falta dela)
    this.filterBairros()
  }

  filterBairros() {
    const regiaoId = this.regiaoTarget.value
    const selectedBairroId = this.bairroTarget.value
    
    this.bairroTarget.innerHTML = ""
    this.bairroTarget.appendChild(this.bairroOptions[0])

    this.bairroOptions.slice(1).forEach(option => {
      const optionRegiaoId = option.dataset.regiaoId
      
      if (!regiaoId || optionRegiaoId == regiaoId) {
        this.bairroTarget.appendChild(option)
      }
    })

    this.bairroTarget.value = selectedBairroId
    
    if (this.bairroTarget.value !== selectedBairroId) {
      this.bairroTarget.value = ""
    }
  }
}
