import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["municipio", "regiao", "bairro"]

  connect() {
    console.log("Location select controller connected")
  }

  async changeMunicipio() {
    const municipioId = this.municipioTarget.value
    this.regiaoTarget.innerHTML = '<option value="">Selecione a Região</option>'
    this.bairroTarget.innerHTML = '<option value="">Selecione o Bairro</option>'
    this.regiaoTarget.disabled = true
    this.bairroTarget.disabled = true

    if (!municipioId) return

    try {
      const response = await fetch(`/municipios/${municipioId}/regioes.json`)
      if (!response.ok) throw new Error('Network response was not ok')
      const regioes = await response.json()

      regioes.forEach(regiao => {
        const option = document.createElement("option")
        option.value = regiao.id
        option.text = regiao.nome
        this.regiaoTarget.appendChild(option)
      })
      this.regiaoTarget.disabled = false
    } catch (error) {
      console.error("Error fetching regioes:", error)
    }
  }

  async changeRegiao() {
    const municipioId = this.municipioTarget.value
    const regiaoId = this.regiaoTarget.value
    this.bairroTarget.innerHTML = '<option value="">Selecione o Bairro</option>'
    this.bairroTarget.disabled = true

    if (!municipioId || !regiaoId) return

    try {
      const response = await fetch(`/municipios/${municipioId}/regioes/${regiaoId}/bairros.json`)
      if (!response.ok) throw new Error('Network response was not ok')
      const bairros = await response.json()

      bairros.forEach(bairro => {
        const option = document.createElement("option")
        option.value = bairro.id
        option.text = bairro.nome
        this.bairroTarget.appendChild(option)
      })
      this.bairroTarget.disabled = false
    } catch (error) {
      console.error("Error fetching bairros:", error)
    }
  }
}
