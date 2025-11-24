import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["municipio", "regiao", "bairro"]

  connect() {
    // Store original options to restore them later
    // We skip the first option assuming it is the placeholder "Selecione..."
    this.allRegiaoOptions = Array.from(this.regiaoTarget.querySelectorAll("option")).slice(1)
    this.allBairroOptions = Array.from(this.bairroTarget.querySelectorAll("option")).slice(1)
    
    // Initial filter based on current values (if any)
    this.filterRegioes()
  }

  filterRegioes() {
    const municipioId = this.municipioTarget.value
    const regiaoSelect = this.regiaoTarget
    const currentRegiaoValue = regiaoSelect.value

    // Clear existing options (keep placeholder)
    regiaoSelect.length = 1

    // Add filtered options
    this.allRegiaoOptions.forEach(option => {
      if (municipioId && option.dataset.municipioId == municipioId) {
        regiaoSelect.add(option.cloneNode(true))
      }
    })

    // Try to restore selection
    regiaoSelect.value = currentRegiaoValue
    // If the previously selected value is no longer valid, reset to placeholder
    if (regiaoSelect.value !== currentRegiaoValue) {
      regiaoSelect.selectedIndex = 0
    }

    // Trigger bairro filter because regiao might have changed
    this.filterBairros()
  }

  filterBairros() {
    const regiaoId = this.regiaoTarget.value
    const bairroSelect = this.bairroTarget
    const currentBairroValue = bairroSelect.value

    bairroSelect.length = 1

    this.allBairroOptions.forEach(option => {
      if (regiaoId && option.dataset.regiaoId == regiaoId) {
        bairroSelect.add(option.cloneNode(true))
      }
    })

    bairroSelect.value = currentBairroValue
    if (bairroSelect.value !== currentBairroValue) {
      bairroSelect.selectedIndex = 0
    }
  }
}
