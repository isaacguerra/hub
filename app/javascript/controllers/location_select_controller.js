import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["municipio", "regiao", "bairro"]

  connect() {
    // Clona as opções originais para preservar a lista completa
    // Usamos cloneNode(true) para garantir que temos cópias independentes
    this.originalRegiaoOptions = Array.from(this.regiaoTarget.options).map(opt => opt.cloneNode(true))
    this.originalBairroOptions = Array.from(this.bairroTarget.options).map(opt => opt.cloneNode(true))
    
    // Aplica o filtro inicial
    this.filterRegioes()
  }

  // Restaura o estado original ao desconectar para garantir que o Turbo Cache
  // salve a página com todas as opções disponíveis, evitando perda de dados na navegação
  disconnect() {
    this.restoreOptions(this.regiaoTarget, this.originalRegiaoOptions)
    this.restoreOptions(this.bairroTarget, this.originalBairroOptions)
  }

  filterRegioes() {
    const municipioId = this.municipioTarget.value
    const currentRegiaoValue = this.regiaoTarget.value
    
    // Limpa e reconstrói o select de regiões
    this.regiaoTarget.innerHTML = ""
    
    // Adiciona o placeholder (primeira opção)
    this.regiaoTarget.appendChild(this.originalRegiaoOptions[0].cloneNode(true))

    // Adiciona opções filtradas
    this.originalRegiaoOptions.slice(1).forEach(option => {
      const optionMunicipioId = option.dataset.municipioId
      
      // Se não tem município selecionado (value vazio), ou se o ID bate
      if (!municipioId || optionMunicipioId == municipioId) {
        this.regiaoTarget.appendChild(option.cloneNode(true))
      }
    })

    // Tenta manter a seleção
    this.regiaoTarget.value = currentRegiaoValue
    if (this.regiaoTarget.value !== currentRegiaoValue) {
      this.regiaoTarget.selectedIndex = 0
    }

    // Cascata para bairros
    this.filterBairros()
  }

  filterBairros() {
    const regiaoId = this.regiaoTarget.value
    const currentBairroValue = this.bairroTarget.value
    
    this.bairroTarget.innerHTML = ""
    this.bairroTarget.appendChild(this.originalBairroOptions[0].cloneNode(true))

    this.originalBairroOptions.slice(1).forEach(option => {
      const optionRegiaoId = option.dataset.regiaoId
      
      if (!regiaoId || optionRegiaoId == regiaoId) {
        this.bairroTarget.appendChild(option.cloneNode(true))
      }
    })

    this.bairroTarget.value = currentBairroValue
    if (this.bairroTarget.value !== currentBairroValue) {
      this.bairroTarget.selectedIndex = 0
    }
  }

  restoreOptions(selectElement, originalOptions) {
    if (!selectElement || !originalOptions) return
    selectElement.innerHTML = ""
    originalOptions.forEach(option => selectElement.appendChild(option.cloneNode(true)))
  }
}
