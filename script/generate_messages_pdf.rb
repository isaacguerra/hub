require 'yaml'
require 'prawn'

# Load messages
file_path = File.join(Dir.pwd, 'config', 'locales', 'mensagens.pt-BR.yml')
data = YAML.load_file(file_path)
messages = data['pt-BR']['mensagens']

# Helper to flatten hash
def flatten_hash(hash, parent_key = '')
  hash.each_with_object({}) do |(k, v), h|
    current_key = parent_key.empty? ? k.to_s : "#{parent_key}.#{k}"
    if v.is_a?(Hash)
      h.merge!(flatten_hash(v, current_key))
    else
      h[current_key] = v
    end
  end
end

# Helper to remove unsupported characters (emojis) for PDF generation
def clean_text(str)
  # Encode to Windows-1252 (standard PDF font encoding) replacing undefined chars
  str.encode('Windows-1252', invalid: :replace, undef: :replace, replace: '')
     .encode('UTF-8')
end

flat_messages = flatten_hash(messages, 'mensagens')

# Sample data for placeholders
SAMPLES = {
  nome: "João Silva",
  whatsapp: "(96) 99123-4567",
  funcao: "Líder de Bairro",
  municipio: "Macapá",
  nova_funcao: "Coordenador Regional",
  funcao_anterior: "Líder",
  codigo: "123456",
  link: "https://app.ivone.com/auth/magic",
  status: "Pendente",
  nome_apoiador: "Maria Oliveira",
  nome_convidado: "Carlos Santos",
  erros: "Número inválido",
  horario: "14:30",
  evento: "Reunião Geral",
  local: "Sede do Partido",
  data: "15/10/2025",
  motivo: "Imprevisto pessoal",
  relato: "Visita realizada com sucesso, família apoia.",
  total_visitas: "15",
  meta: "20",
  progresso: "75%",
  bairro: "Centro",
  regiao: "Zona Sul",
  lider: "Pedro Santos",
  total: "100",
  confirmados: "80",
  pendentes: "20",
  recusados: "0",
  nome_lider: "Ana Costa",
  link_painel: "https://painel.ivone.com/123",
  validade: "30 minutos",
  ip: "192.168.1.1",
  navegador: "Chrome Mobile",
  sistema_operacional: "Android",
  data_hora: "06/12/2025 10:00",
  titulo: "Novo Evento",
  descricao: "Descrição do evento aqui.",
  tipo: "Reunião",
  endereco: "Av. FAB, 123",
  observacoes: "Trazer documento de identificação.",
  quantidade: "50",
  meta_diaria: "5",
  realizado: "3",
  porcentagem: "60%",
  dias_restantes: "10",
  total_apoiadores: "150",
  novos_hoje: "5",
  ranking_posicao: "3º",
  pontos: "1500"
}

# Generate PDF
Prawn::Document.generate("mensagens_sistema.pdf") do
  # Title
  text "Mensagens do Sistema - App Ivone", size: 24, style: :bold, align: :center
  move_down 10
  text "Documento para Revisão", size: 16, align: :center
  text "Gerado em: #{Time.now.strftime('%d/%m/%Y')}", size: 12, align: :center
  move_down 40

  flat_messages.each do |key, value|
    # Title (Key) - Humanized a bit
    # mensagens.apoiadores.novo -> Apoiadores: Novo
    human_title = key.split('.').map(&:capitalize).join(' > ')

    text human_title, size: 14, style: :bold, color: "0000FF"
    move_down 5

    # Format message
    formatted_message = value.to_s.dup

    # Clean text (remove emojis)
    formatted_message = clean_text(formatted_message)

    # Find placeholders like %{key}
    placeholders = formatted_message.scan(/%\{(\w+)\}/).flatten

    placeholders.each do |placeholder|
      sample_value = SAMPLES[placeholder.to_sym] || "[#{placeholder.upcase}]"
      formatted_message.gsub!("%{#{placeholder}}", sample_value)
    end

    # Message Body
    # Draw a box around the message
    bounding_box([ 0, cursor ], width: bounds.width) do
      stroke_color "CCCCCC"
      stroke_bounds

      pad(15) do
        indent(10) do
          text formatted_message, size: 12, leading: 4
        end
      end
    end

    move_down 20

    if cursor < 100
      start_new_page
    end
  end

  number_pages "<page> de <total>", at: [ bounds.right - 150, 0 ], width: 150, align: :right
end

puts "PDF gerado com sucesso: mensagens_sistema.pdf"
