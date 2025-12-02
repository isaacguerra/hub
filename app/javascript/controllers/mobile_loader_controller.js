import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-loader"
export default class extends Controller {
  static targets = ["spinner"]

  connect() {
    // Escuta eventos globais do Turbo
    document.addEventListener("turbo:visit", this.show.bind(this))
    document.addEventListener("turbo:submit-start", this.show.bind(this))
    document.addEventListener("turbo:load", this.hide.bind(this))
    document.addEventListener("turbo:submit-end", this.hide.bind(this))
    
    // Garante que começa escondido
    this.hide()
  }

  disconnect() {
    document.removeEventListener("turbo:visit", this.show.bind(this))
    document.removeEventListener("turbo:submit-start", this.show.bind(this))
    document.removeEventListener("turbo:load", this.hide.bind(this))
    document.removeEventListener("turbo:submit-end", this.hide.bind(this))
  }

  show() {
    this.spinnerTarget.classList.remove("d-none")
    this.spinnerTarget.classList.add("d-flex")
  }

  hide() {
    this.spinnerTarget.classList.add("d-none")
    this.spinnerTarget.classList.remove("d-flex")
  }
}
