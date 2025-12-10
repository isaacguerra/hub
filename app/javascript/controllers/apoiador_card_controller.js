import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "select"]

  connect() {
    // Se já tiver um valor selecionado ao carregar (ex: validação falhou), carrega o card
    if (this.selectTarget.value) {
      this.loadCard()
    }
  }

  loadCard() {
    const apoiadorId = this.selectTarget.value
    
    if (!apoiadorId) {
      this.containerTarget.innerHTML = ""
      return
    }

    fetch(`/mobile/apoiadores/${apoiadorId}/card`)
      .then(response => response.text())
      .then(html => {
        this.containerTarget.innerHTML = html
      })
      .catch(error => {
        console.error("Erro ao carregar card do apoiador:", error)
        this.containerTarget.innerHTML = ""
      })
  }
}