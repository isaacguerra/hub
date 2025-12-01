import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["municipio", "regiao", "bairro", "regiaoContainer", "bairroContainer"]

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
    // Restaura visibilidade
    if (this.hasRegiaoContainerTarget) this.regiaoContainerTarget.style.display = ""
    if (this.hasBairroContainerTarget) this.bairroContainerTarget.style.display = ""
  }

  filterRegioes() {
    const municipioId = this.municipioTarget.value
    const currentRegiaoValue = this.regiaoTarget.value
    
    // Controle de visibilidade
    if (municipioId) {
      this.regiaoContainerTarget.style.display = "block"
    } else {
      this.regiaoContainerTarget.style.display = "none"
      this.regiaoTarget.value = "" // Limpa seleção se ocultar
    }

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

    // Tenta manter a seleção se ainda for válida
    if (municipioId) {
        this.regiaoTarget.value = currentRegiaoValue
        if (this.regiaoTarget.value !== currentRegiaoValue) {
          this.regiaoTarget.selectedIndex = 0
        }
    } else {
        this.regiaoTarget.selectedIndex = 0
    }

    // Cascata para bairros
    this.filterBairros()
  }

  filterBairros() {
    const regiaoId = this.regiaoTarget.value
    const currentBairroValue = this.bairroTarget.value
    
    // Controle de visibilidade
    if (regiaoId) {
      this.bairroContainerTarget.style.display = "block"
    } else {
      this.bairroContainerTarget.style.display = "none"
      this.bairroTarget.value = "" // Limpa seleção se ocultar
    }

    this.bairroTarget.innerHTML = ""
    this.bairroTarget.appendChild(this.originalBairroOptions[0].cloneNode(true))

    this.originalBairroOptions.slice(1).forEach(option => {
      const optionRegiaoId = option.dataset.regiaoId
      
      if (!regiaoId || optionRegiaoId == regiaoId) {
        this.bairroTarget.appendChild(option.cloneNode(true))
      }
    })

    if (regiaoId) {
        this.bairroTarget.value = currentBairroValue
        if (this.bairroTarget.value !== currentBairroValue) {
          this.bairroTarget.selectedIndex = 0
        }
    } else {
        this.bairroTarget.selectedIndex = 0
    }
  }

  restoreOptions(selectElement, originalOptions) {
    if (!selectElement || !originalOptions) return
    selectElement.innerHTML = ""
    originalOptions.forEach(option => selectElement.appendChild(option.cloneNode(true)))
  }
}
