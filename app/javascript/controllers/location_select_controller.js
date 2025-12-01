import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["municipio", "regiao", "bairro", "regiaoContainer", "bairroContainer"]

  connect() {
    // Evita inicialização duplicada se o connect rodar múltiplas vezes sem disconnect
    if (this.initialized) return
    this.initialized = true

    // Clona as opções originais para preservar a lista completa
    this.originalRegiaoOptions = Array.from(this.regiaoTarget.options).map(opt => opt.cloneNode(true))
    this.originalBairroOptions = Array.from(this.bairroTarget.options).map(opt => opt.cloneNode(true))
    
    // Aplica o filtro inicial
    this.filterRegioes()

    // Garante limpeza antes do cache do Turbo para evitar salvar estado filtrado
    this.cleanup = this.cleanup.bind(this)
    document.addEventListener("turbo:before-cache", this.cleanup)
  }

  disconnect() {
    this.cleanup()
    document.removeEventListener("turbo:before-cache", this.cleanup)
    this.initialized = false
  }

  cleanup() {
    // Restaura todas as opções e visibilidade original
    this.restoreOptions(this.regiaoTarget, this.originalRegiaoOptions)
    this.restoreOptions(this.bairroTarget, this.originalBairroOptions)
    
    if (this.hasRegiaoContainerTarget) this.regiaoContainerTarget.style.display = ""
    if (this.hasBairroContainerTarget) this.bairroContainerTarget.style.display = ""
  }

  filterRegioes() {
    const municipioId = this.municipioTarget.value
    const currentRegiaoValue = this.regiaoTarget.value
    
    // Controle de visibilidade
    if (this.hasRegiaoContainerTarget) {
      if (municipioId) {
        this.regiaoContainerTarget.style.display = "block"
      } else {
        this.regiaoContainerTarget.style.display = "none"
        this.regiaoTarget.value = "" 
      }
    }

    // Limpa e reconstrói o select de regiões
    this.regiaoTarget.innerHTML = ""
    
    // Adiciona o placeholder (primeira opção)
    if (this.originalRegiaoOptions.length > 0) {
      this.regiaoTarget.appendChild(this.originalRegiaoOptions[0].cloneNode(true))
    }

    // Adiciona opções filtradas
    this.originalRegiaoOptions.slice(1).forEach(option => {
      const optionMunicipioId = option.dataset.municipioId
      
      if (!municipioId || optionMunicipioId == municipioId) {
        this.regiaoTarget.appendChild(option.cloneNode(true))
      }
    })

    // Tenta manter a seleção
    if (municipioId) {
        this.regiaoTarget.value = currentRegiaoValue
        // Se o valor selecionado não existe mais na lista filtrada, reseta
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
    if (this.hasBairroContainerTarget) {
      if (regiaoId) {
        this.bairroContainerTarget.style.display = "block"
      } else {
        this.bairroContainerTarget.style.display = "none"
        this.bairroTarget.value = ""
      }
    }

    this.bairroTarget.innerHTML = ""
    if (this.originalBairroOptions.length > 0) {
      this.bairroTarget.appendChild(this.originalBairroOptions[0].cloneNode(true))
    }

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
