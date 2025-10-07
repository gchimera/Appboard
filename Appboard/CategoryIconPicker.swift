import SwiftUI

struct CategoryIconPicker: View {
    @Binding var selectedIcon: String
    let availableIcons: [IconOption]
    let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    struct IconOption: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let displayName: String
        let isCustom: Bool
        
        init(name: String, displayName: String, isCustom: Bool = true) {
            self.name = name
            self.displayName = displayName
            self.isCustom = isCustom
        }
    }
    
    static let defaultIcons: [IconOption] = [
        // 📂 CARTELLE E ORGANIZZAZIONE
        IconOption(name: "📁", displayName: "Generale", isCustom: false),
        IconOption(name: "📂", displayName: "Cartella", isCustom: false),
        IconOption(name: "🗂️", displayName: "Archivio", isCustom: false),
        IconOption(name: "📋", displayName: "Clipboard", isCustom: false),
        IconOption(name: "📑", displayName: "Bookmark", isCustom: false),
        IconOption(name: "🗃️", displayName: "Schedario", isCustom: false),
        
        // 💻 TECNOLOGIA E SVILUPPO
        IconOption(name: "💻", displayName: "Computer", isCustom: false),
        IconOption(name: "⚙️", displayName: "Sistema", isCustom: false),
        IconOption(name: "👨‍💻", displayName: "Sviluppo", isCustom: false),
        IconOption(name: "🔧", displayName: "Utilità", isCustom: false),
        IconOption(name: "🛠️", displayName: "Tools", isCustom: false),
        IconOption(name: "⚡", displayName: "Veloce", isCustom: false),
        IconOption(name: "🔌", displayName: "Plugin", isCustom: false),
        IconOption(name: "🖥️", displayName: "Desktop", isCustom: false),
        IconOption(name: "⌨️", displayName: "Tastiera", isCustom: false),
        IconOption(name: "🖱️", displayName: "Mouse", isCustom: false),
        IconOption(name: "🖨️", displayName: "Stampa", isCustom: false),
        IconOption(name: "💾", displayName: "Salva", isCustom: false),
        IconOption(name: "💿", displayName: "Disco", isCustom: false),
        IconOption(name: "📀", displayName: "CD", isCustom: false),
        IconOption(name: "🔋", displayName: "Batteria", isCustom: false),
        IconOption(name: "🔩", displayName: "Hardware", isCustom: false),
        
        // 🎮 GAMING E INTRATTENIMENTO
        IconOption(name: "🎮", displayName: "Giochi", isCustom: false),
        IconOption(name: "🕹️", displayName: "Joystick", isCustom: false),
        IconOption(name: "🎯", displayName: "Target", isCustom: false),
        IconOption(name: "🎲", displayName: "Dadi", isCustom: false),
        IconOption(name: "🃏", displayName: "Carte", isCustom: false),
        IconOption(name: "♟️", displayName: "Scacchi", isCustom: false),
        IconOption(name: "🎰", displayName: "Casino", isCustom: false),
        IconOption(name: "🎪", displayName: "Circo", isCustom: false),
        
        // 💼 BUSINESS E PRODUTTIVITÀ
        IconOption(name: "💼", displayName: "Business", isCustom: false),
        IconOption(name: "📊", displayName: "Analytics", isCustom: false),
        IconOption(name: "📈", displayName: "Crescita", isCustom: false),
        IconOption(name: "📉", displayName: "Trend", isCustom: false),
        IconOption(name: "💹", displayName: "Borsa", isCustom: false),
        IconOption(name: "💰", displayName: "Finanza", isCustom: false),
        IconOption(name: "💵", displayName: "Soldi", isCustom: false),
        IconOption(name: "💳", displayName: "Carta", isCustom: false),
        IconOption(name: "🏦", displayName: "Banca", isCustom: false),
        IconOption(name: "📝", displayName: "Note", isCustom: false),
        IconOption(name: "✏️", displayName: "Matita", isCustom: false),
        IconOption(name: "📄", displayName: "Doc", isCustom: false),
        IconOption(name: "📃", displayName: "Pagina", isCustom: false),
        IconOption(name: "📰", displayName: "News", isCustom: false),
        IconOption(name: "📧", displayName: "Email", isCustom: false),
        IconOption(name: "📮", displayName: "Posta", isCustom: false),
        IconOption(name: "📬", displayName: "Inbox", isCustom: false),
        IconOption(name: "📫", displayName: "Mailbox", isCustom: false),
        IconOption(name: "🗓️", displayName: "Calendario", isCustom: false),
        IconOption(name: "📅", displayName: "Date", isCustom: false),
        IconOption(name: "⏰", displayName: "Sveglia", isCustom: false),
        IconOption(name: "⏱️", displayName: "Timer", isCustom: false),
        IconOption(name: "⏲️", displayName: "Conto", isCustom: false),
        IconOption(name: "🕐", displayName: "Ore", isCustom: false),
        IconOption(name: "📌", displayName: "Pin", isCustom: false),
        IconOption(name: "📍", displayName: "Location", isCustom: false),
        IconOption(name: "✂️", displayName: "Taglia", isCustom: false),
        
        // 🎨 CREATIVITÀ E DESIGN
        IconOption(name: "🎨", displayName: "Design", isCustom: false),
        IconOption(name: "🖌️", displayName: "Pennello", isCustom: false),
        IconOption(name: "🖍️", displayName: "Pastello", isCustom: false),
        IconOption(name: "✒️", displayName: "Penna", isCustom: false),
        IconOption(name: "🖊️", displayName: "Biro", isCustom: false),
        IconOption(name: "🎭", displayName: "Teatro", isCustom: false),
        IconOption(name: "🎬", displayName: "Film", isCustom: false),
        IconOption(name: "🎥", displayName: "Video", isCustom: false),
        IconOption(name: "📹", displayName: "Camera", isCustom: false),
        IconOption(name: "📸", displayName: "Foto", isCustom: false),
        IconOption(name: "📷", displayName: "Reflex", isCustom: false),
        IconOption(name: "🖼️", displayName: "Quadro", isCustom: false),
        IconOption(name: "🌈", displayName: "Colori", isCustom: false),
        IconOption(name: "🎪", displayName: "Show", isCustom: false),
        
        // 🎵 MUSICA E AUDIO
        IconOption(name: "🎵", displayName: "Musica", isCustom: false),
        IconOption(name: "🎶", displayName: "Note", isCustom: false),
        IconOption(name: "🎤", displayName: "Microfono", isCustom: false),
        IconOption(name: "🎧", displayName: "Cuffie", isCustom: false),
        IconOption(name: "📻", displayName: "Radio", isCustom: false),
        IconOption(name: "🎸", displayName: "Chitarra", isCustom: false),
        IconOption(name: "🎹", displayName: "Piano", isCustom: false),
        IconOption(name: "🎺", displayName: "Tromba", isCustom: false),
        IconOption(name: "🎻", displayName: "Violino", isCustom: false),
        IconOption(name: "🥁", displayName: "Batteria", isCustom: false),
        IconOption(name: "🔊", displayName: "Audio", isCustom: false),
        IconOption(name: "🔉", displayName: "Volume", isCustom: false),
        IconOption(name: "🔇", displayName: "Muto", isCustom: false),
        
        // 💬 COMUNICAZIONE E SOCIAL
        IconOption(name: "💬", displayName: "Chat", isCustom: false),
        IconOption(name: "💭", displayName: "Pensiero", isCustom: false),
        IconOption(name: "🗨️", displayName: "Messaggio", isCustom: false),
        IconOption(name: "🗯️", displayName: "Fumetto", isCustom: false),
        IconOption(name: "📢", displayName: "Annuncio", isCustom: false),
        IconOption(name: "📣", displayName: "Megafono", isCustom: false),
        IconOption(name: "🔔", displayName: "Notifiche", isCustom: false),
        IconOption(name: "🔕", displayName: "Silenzioso", isCustom: false),
        IconOption(name: "📞", displayName: "Telefono", isCustom: false),
        IconOption(name: "📱", displayName: "Mobile", isCustom: false),
        IconOption(name: "☎️", displayName: "Chiamata", isCustom: false),
        IconOption(name: "📲", displayName: "Smartphone", isCustom: false),
        IconOption(name: "👥", displayName: "Gruppo", isCustom: false),
        IconOption(name: "👤", displayName: "Utente", isCustom: false),
        IconOption(name: "💌", displayName: "Amore", isCustom: false),
        
        // 📚 EDUCAZIONE E LETTURA
        IconOption(name: "📚", displayName: "Libri", isCustom: false),
        IconOption(name: "📖", displayName: "Libro", isCustom: false),
        IconOption(name: "📕", displayName: "Rosso", isCustom: false),
        IconOption(name: "📗", displayName: "Verde", isCustom: false),
        IconOption(name: "📘", displayName: "Blu", isCustom: false),
        IconOption(name: "📙", displayName: "Arancio", isCustom: false),
        IconOption(name: "🎓", displayName: "Laurea", isCustom: false),
        IconOption(name: "🏫", displayName: "Scuola", isCustom: false),
        IconOption(name: "🎒", displayName: "Zaino", isCustom: false),
        IconOption(name: "📐", displayName: "Geometria", isCustom: false),
        IconOption(name: "📏", displayName: "Righello", isCustom: false),
        IconOption(name: "🔬", displayName: "Scienza", isCustom: false),
        IconOption(name: "🔭", displayName: "Astronomia", isCustom: false),
        IconOption(name: "🧪", displayName: "Chimica", isCustom: false),
        IconOption(name: "🧬", displayName: "DNA", isCustom: false),
        IconOption(name: "🌡️", displayName: "Temperatura", isCustom: false),
        IconOption(name: "💡", displayName: "Idee", isCustom: false),
        IconOption(name: "🧠", displayName: "Cervello", isCustom: false),
        
        // 🌐 INTERNET E WEB
        IconOption(name: "🌐", displayName: "Web", isCustom: false),
        IconOption(name: "🌍", displayName: "Terra", isCustom: false),
        IconOption(name: "🌎", displayName: "Mondo", isCustom: false),
        IconOption(name: "🌏", displayName: "Globo", isCustom: false),
        IconOption(name: "🗺️", displayName: "Mappa", isCustom: false),
        IconOption(name: "🧭", displayName: "Bussola", isCustom: false),
        IconOption(name: "📡", displayName: "Satellite", isCustom: false),
        IconOption(name: "📶", displayName: "Segnale", isCustom: false),
        IconOption(name: "🔗", displayName: "Link", isCustom: false),
        IconOption(name: "🔍", displayName: "Ricerca", isCustom: false),
        IconOption(name: "🔎", displayName: "Zoom", isCustom: false),
        IconOption(name: "☁️", displayName: "Cloud", isCustom: false),
        IconOption(name: "⛅", displayName: "Nuvola", isCustom: false),
        
        // 🔒 SICUREZZA E PRIVACY
        IconOption(name: "🔒", displayName: "Sicuro", isCustom: false),
        IconOption(name: "🔓", displayName: "Aperto", isCustom: false),
        IconOption(name: "🔐", displayName: "Chiave", isCustom: false),
        IconOption(name: "🔑", displayName: "Password", isCustom: false),
        IconOption(name: "🗝️", displayName: "Accesso", isCustom: false),
        IconOption(name: "🛡️", displayName: "Scudo", isCustom: false),
        IconOption(name: "🔏", displayName: "Lucchetto", isCustom: false),
        IconOption(name: "⚠️", displayName: "Attenzione", isCustom: false),
        IconOption(name: "🚨", displayName: "Allarme", isCustom: false),
        IconOption(name: "🚫", displayName: "Vietato", isCustom: false),
        IconOption(name: "⛔", displayName: "Stop", isCustom: false),
        IconOption(name: "🔞", displayName: "18+", isCustom: false),
        
        // ⭐ PREFERITI E SPECIALI
        IconOption(name: "⭐", displayName: "Stella", isCustom: false),
        IconOption(name: "🌟", displayName: "Speciale", isCustom: false),
        IconOption(name: "✨", displayName: "Brillante", isCustom: false),
        IconOption(name: "💫", displayName: "Scintilla", isCustom: false),
        IconOption(name: "🌠", displayName: "Cadente", isCustom: false),
        IconOption(name: "⚡", displayName: "Fulmine", isCustom: false),
        IconOption(name: "🔥", displayName: "Hot", isCustom: false),
        IconOption(name: "💎", displayName: "Premium", isCustom: false),
        IconOption(name: "👑", displayName: "Re", isCustom: false),
        IconOption(name: "🏆", displayName: "Trofeo", isCustom: false),
        IconOption(name: "🥇", displayName: "Oro", isCustom: false),
        IconOption(name: "🥈", displayName: "Argento", isCustom: false),
        IconOption(name: "🥉", displayName: "Bronzo", isCustom: false),
        IconOption(name: "🎖️", displayName: "Medaglia", isCustom: false),
        IconOption(name: "🏅", displayName: "Premio", isCustom: false),
        
        // 🚀 STARTUP E INNOVAZIONE
        IconOption(name: "🚀", displayName: "Lancio", isCustom: false),
        IconOption(name: "🛸", displayName: "UFO", isCustom: false),
        IconOption(name: "🌌", displayName: "Spazio", isCustom: false),
        IconOption(name: "🪐", displayName: "Pianeta", isCustom: false),
        IconOption(name: "🌙", displayName: "Luna", isCustom: false),
        IconOption(name: "☀️", displayName: "Sole", isCustom: false),
        IconOption(name: "🔮", displayName: "Futuro", isCustom: false),
        IconOption(name: "🧲", displayName: "Magnete", isCustom: false),
        
        // 🏠 CASA E VITA
        IconOption(name: "🏠", displayName: "Casa", isCustom: false),
        IconOption(name: "🏡", displayName: "Casetta", isCustom: false),
        IconOption(name: "🏢", displayName: "Ufficio", isCustom: false),
        IconOption(name: "🏬", displayName: "Centro", isCustom: false),
        IconOption(name: "🏪", displayName: "Negozio", isCustom: false),
        IconOption(name: "🏭", displayName: "Fabbrica", isCustom: false),
        IconOption(name: "🏗️", displayName: "Cantiere", isCustom: false),
        IconOption(name: "🏛️", displayName: "Museo", isCustom: false),
        IconOption(name: "⛪", displayName: "Chiesa", isCustom: false),
        IconOption(name: "🛋️", displayName: "Divano", isCustom: false),
        IconOption(name: "🪑", displayName: "Sedia", isCustom: false),
        IconOption(name: "🚪", displayName: "Porta", isCustom: false),
        IconOption(name: "🪟", displayName: "Finestra", isCustom: false),
        IconOption(name: "🛏️", displayName: "Letto", isCustom: false),
        
        // ✈️ VIAGGI E TRASPORTI
        IconOption(name: "✈️", displayName: "Aereo", isCustom: false),
        IconOption(name: "🛫", displayName: "Decollo", isCustom: false),
        IconOption(name: "🛬", displayName: "Atterraggio", isCustom: false),
        IconOption(name: "🚁", displayName: "Elicottero", isCustom: false),
        IconOption(name: "🚂", displayName: "Treno", isCustom: false),
        IconOption(name: "🚆", displayName: "Metro", isCustom: false),
        IconOption(name: "🚇", displayName: "Tunnel", isCustom: false),
        IconOption(name: "🚊", displayName: "Tram", isCustom: false),
        IconOption(name: "🚌", displayName: "Bus", isCustom: false),
        IconOption(name: "🚕", displayName: "Taxi", isCustom: false),
        IconOption(name: "🚗", displayName: "Auto", isCustom: false),
        IconOption(name: "🚙", displayName: "SUV", isCustom: false),
        IconOption(name: "🚚", displayName: "Camion", isCustom: false),
        IconOption(name: "🚛", displayName: "TIR", isCustom: false),
        IconOption(name: "🚐", displayName: "Van", isCustom: false),
        IconOption(name: "🛻", displayName: "Pickup", isCustom: false),
        IconOption(name: "🏎️", displayName: "F1", isCustom: false),
        IconOption(name: "🚓", displayName: "Polizia", isCustom: false),
        IconOption(name: "🚑", displayName: "Ambulanza", isCustom: false),
        IconOption(name: "🚒", displayName: "Pompieri", isCustom: false),
        IconOption(name: "🚲", displayName: "Bici", isCustom: false),
        IconOption(name: "🛴", displayName: "Monopattino", isCustom: false),
        IconOption(name: "🛵", displayName: "Scooter", isCustom: false),
        IconOption(name: "🏍️", displayName: "Moto", isCustom: false),
        IconOption(name: "⛵", displayName: "Barca", isCustom: false),
        IconOption(name: "🚤", displayName: "Motoscafo", isCustom: false),
        IconOption(name: "🛥️", displayName: "Yacht", isCustom: false),
        IconOption(name: "🚢", displayName: "Nave", isCustom: false),
        IconOption(name: "⚓", displayName: "Ancora", isCustom: false),
        IconOption(name: "🧳", displayName: "Valigia", isCustom: false),
        IconOption(name: "🎫", displayName: "Biglietto", isCustom: false),
        
        // 🍕 CIBO E BEVANDE
        IconOption(name: "🍕", displayName: "Pizza", isCustom: false),
        IconOption(name: "🍔", displayName: "Burger", isCustom: false),
        IconOption(name: "🍟", displayName: "Patatine", isCustom: false),
        IconOption(name: "🌭", displayName: "Hot Dog", isCustom: false),
        IconOption(name: "🍿", displayName: "Popcorn", isCustom: false),
        IconOption(name: "🍩", displayName: "Donut", isCustom: false),
        IconOption(name: "🍪", displayName: "Biscotto", isCustom: false),
        IconOption(name: "🎂", displayName: "Torta", isCustom: false),
        IconOption(name: "🍰", displayName: "Dolce", isCustom: false),
        IconOption(name: "🧁", displayName: "Cupcake", isCustom: false),
        IconOption(name: "🍦", displayName: "Gelato", isCustom: false),
        IconOption(name: "🍨", displayName: "Coppa", isCustom: false),
        IconOption(name: "🍧", displayName: "Granita", isCustom: false),
        IconOption(name: "☕", displayName: "Caffè", isCustom: false),
        IconOption(name: "🍵", displayName: "Tè", isCustom: false),
        IconOption(name: "🧃", displayName: "Succo", isCustom: false),
        IconOption(name: "🥤", displayName: "Bibita", isCustom: false),
        IconOption(name: "🧋", displayName: "Bubble Tea", isCustom: false),
        IconOption(name: "🍺", displayName: "Birra", isCustom: false),
        IconOption(name: "🍻", displayName: "Brindisi", isCustom: false),
        IconOption(name: "🍷", displayName: "Vino", isCustom: false),
        IconOption(name: "🍾", displayName: "Champagne", isCustom: false),
        IconOption(name: "🍹", displayName: "Cocktail", isCustom: false),
        IconOption(name: "🍸", displayName: "Martini", isCustom: false),
        IconOption(name: "🥂", displayName: "Calici", isCustom: false),
        IconOption(name: "🍴", displayName: "Posate", isCustom: false),
        IconOption(name: "🍽️", displayName: "Piatto", isCustom: false),
        IconOption(name: "🥄", displayName: "Cucchiaio", isCustom: false),
        IconOption(name: "🔪", displayName: "Coltello", isCustom: false),
        
        // 🏥 SALUTE E FITNESS
        IconOption(name: "🏥", displayName: "Ospedale", isCustom: false),
        IconOption(name: "⚕️", displayName: "Medicina", isCustom: false),
        IconOption(name: "💊", displayName: "Pillola", isCustom: false),
        IconOption(name: "💉", displayName: "Siringa", isCustom: false),
        IconOption(name: "🩺", displayName: "Stetoscopio", isCustom: false),
        IconOption(name: "🩹", displayName: "Cerotto", isCustom: false),
        IconOption(name: "🩼", displayName: "Stampella", isCustom: false),
        IconOption(name: "🦷", displayName: "Dente", isCustom: false),
        IconOption(name: "💪", displayName: "Muscolo", isCustom: false),
        IconOption(name: "🏋️", displayName: "Palestra", isCustom: false),
        IconOption(name: "🤸", displayName: "Ginnastica", isCustom: false),
        IconOption(name: "🧘", displayName: "Yoga", isCustom: false),
        IconOption(name: "🚴", displayName: "Ciclismo", isCustom: false),
        IconOption(name: "🏃", displayName: "Corsa", isCustom: false),
        IconOption(name: "🧗", displayName: "Arrampicata", isCustom: false),
        IconOption(name: "⛷️", displayName: "Sci", isCustom: false),
        IconOption(name: "🏂", displayName: "Snowboard", isCustom: false),
        IconOption(name: "🏊", displayName: "Nuoto", isCustom: false),
        IconOption(name: "🏄", displayName: "Surf", isCustom: false),
        IconOption(name: "⚽", displayName: "Calcio", isCustom: false),
        IconOption(name: "🏀", displayName: "Basket", isCustom: false),
        IconOption(name: "🏈", displayName: "Football", isCustom: false),
        IconOption(name: "⚾", displayName: "Baseball", isCustom: false),
        IconOption(name: "🎾", displayName: "Tennis", isCustom: false),
        IconOption(name: "🏐", displayName: "Volley", isCustom: false),
        IconOption(name: "🏓", displayName: "Ping Pong", isCustom: false),
        IconOption(name: "🥊", displayName: "Boxe", isCustom: false),
        IconOption(name: "🥋", displayName: "Arti Marziali", isCustom: false),
        IconOption(name: "🎳", displayName: "Bowling", isCustom: false),
        IconOption(name: "⛳", displayName: "Golf", isCustom: false),
        
        // 🛒 SHOPPING E COMMERCIO
        IconOption(name: "🛒", displayName: "Carrello", isCustom: false),
        IconOption(name: "🛍️", displayName: "Shopping", isCustom: false),
        IconOption(name: "🏷️", displayName: "Tag", isCustom: false),
        IconOption(name: "💸", displayName: "Pagamento", isCustom: false),
        IconOption(name: "💳", displayName: "Card", isCustom: false),
        IconOption(name: "🧾", displayName: "Ricevuta", isCustom: false),
        IconOption(name: "📦", displayName: "Pacco", isCustom: false),
        IconOption(name: "📮", displayName: "Spedizione", isCustom: false),
        IconOption(name: "🎁", displayName: "Regalo", isCustom: false),
        IconOption(name: "🎀", displayName: "Fiocco", isCustom: false),
        IconOption(name: "🎊", displayName: "Festa", isCustom: false),
        IconOption(name: "🎉", displayName: "Party", isCustom: false),
        IconOption(name: "🎈", displayName: "Palloncino", isCustom: false),
        
        // 🧩 HOBBY E ATTIVITÀ
        IconOption(name: "🧩", displayName: "Puzzle", isCustom: false),
        IconOption(name: "🎲", displayName: "Gioco", isCustom: false),
        IconOption(name: "🧸", displayName: "Orsetto", isCustom: false),
        IconOption(name: "🪀", displayName: "Yo-yo", isCustom: false),
        IconOption(name: "🪁", displayName: "Aquilone", isCustom: false),
        IconOption(name: "🎣", displayName: "Pesca", isCustom: false),
        IconOption(name: "🧵", displayName: "Cucito", isCustom: false),
        IconOption(name: "🧶", displayName: "Lana", isCustom: false),
        IconOption(name: "🪡", displayName: "Ago", isCustom: false),
        IconOption(name: "🎼", displayName: "Spartito", isCustom: false),
        
        // 🌿 NATURA E AMBIENTE
        IconOption(name: "🌿", displayName: "Natura", isCustom: false),
        IconOption(name: "🌱", displayName: "Pianta", isCustom: false),
        IconOption(name: "🌲", displayName: "Albero", isCustom: false),
        IconOption(name: "🌳", displayName: "Quercia", isCustom: false),
        IconOption(name: "🌴", displayName: "Palma", isCustom: false),
        IconOption(name: "🌵", displayName: "Cactus", isCustom: false),
        IconOption(name: "🌾", displayName: "Grano", isCustom: false),
        IconOption(name: "🌻", displayName: "Girasole", isCustom: false),
        IconOption(name: "🌺", displayName: "Fiore", isCustom: false),
        IconOption(name: "🌹", displayName: "Rosa", isCustom: false),
        IconOption(name: "🌷", displayName: "Tulipano", isCustom: false),
        IconOption(name: "🌸", displayName: "Ciliegio", isCustom: false),
        IconOption(name: "💐", displayName: "Bouquet", isCustom: false),
        IconOption(name: "🍀", displayName: "Fortuna", isCustom: false),
        IconOption(name: "🍁", displayName: "Acero", isCustom: false),
        IconOption(name: "🍂", displayName: "Autunno", isCustom: false),
        IconOption(name: "🍃", displayName: "Foglia", isCustom: false),
        IconOption(name: "🦋", displayName: "Farfalla", isCustom: false),
        IconOption(name: "🐝", displayName: "Ape", isCustom: false),
        IconOption(name: "🐞", displayName: "Coccinella", isCustom: false),
        IconOption(name: "🦜", displayName: "Pappagallo", isCustom: false),
        IconOption(name: "🦅", displayName: "Aquila", isCustom: false),
        IconOption(name: "🦉", displayName: "Gufo", isCustom: false),
        IconOption(name: "🐶", displayName: "Cane", isCustom: false),
        IconOption(name: "🐱", displayName: "Gatto", isCustom: false),
        IconOption(name: "🐭", displayName: "Topo", isCustom: false),
        IconOption(name: "🐹", displayName: "Criceto", isCustom: false),
        IconOption(name: "🐰", displayName: "Coniglio", isCustom: false),
        IconOption(name: "🦊", displayName: "Volpe", isCustom: false),
        IconOption(name: "🐻", displayName: "Orso", isCustom: false),
        IconOption(name: "🐼", displayName: "Panda", isCustom: false),
        IconOption(name: "🐨", displayName: "Koala", isCustom: false),
        IconOption(name: "🐯", displayName: "Tigre", isCustom: false),
        IconOption(name: "🦁", displayName: "Leone", isCustom: false),
        IconOption(name: "🐮", displayName: "Mucca", isCustom: false),
        IconOption(name: "🐷", displayName: "Maiale", isCustom: false),
        IconOption(name: "🐸", displayName: "Rana", isCustom: false),
        IconOption(name: "🐵", displayName: "Scimmia", isCustom: false),
        IconOption(name: "🦍", displayName: "Gorilla", isCustom: false),
        IconOption(name: "🐧", displayName: "Pinguino", isCustom: false),
        IconOption(name: "🐦", displayName: "Uccello", isCustom: false),
        IconOption(name: "🐔", displayName: "Gallina", isCustom: false),
        IconOption(name: "🐠", displayName: "Pesce", isCustom: false),
        IconOption(name: "🐟", displayName: "Pescato", isCustom: false),
        IconOption(name: "🐡", displayName: "Palla", isCustom: false),
        IconOption(name: "🦈", displayName: "Squalo", isCustom: false),
        IconOption(name: "🐙", displayName: "Polpo", isCustom: false),
        IconOption(name: "🦀", displayName: "Granchio", isCustom: false),
        IconOption(name: "🦐", displayName: "Gambero", isCustom: false),
        IconOption(name: "🐚", displayName: "Conchiglia", isCustom: false),
        IconOption(name: "🦕", displayName: "Dinosauro", isCustom: false),
        IconOption(name: "🦖", displayName: "T-Rex", isCustom: false),
        IconOption(name: "🐉", displayName: "Drago", isCustom: false),
        IconOption(name: "🦄", displayName: "Unicorno", isCustom: false),
        
        // 🌤️ METEO
        IconOption(name: "☀️", displayName: "Sereno", isCustom: false),
        IconOption(name: "🌤️", displayName: "Parziale", isCustom: false),
        IconOption(name: "⛅", displayName: "Nuvoloso", isCustom: false),
        IconOption(name: "🌥️", displayName: "Coperto", isCustom: false),
        IconOption(name: "☁️", displayName: "Nuvole", isCustom: false),
        IconOption(name: "🌦️", displayName: "Pioggia", isCustom: false),
        IconOption(name: "🌧️", displayName: "Temporale", isCustom: false),
        IconOption(name: "⛈️", displayName: "Fulmini", isCustom: false),
        IconOption(name: "🌩️", displayName: "Lampi", isCustom: false),
        IconOption(name: "❄️", displayName: "Neve", isCustom: false),
        IconOption(name: "⛄", displayName: "Pupazzo", isCustom: false),
        IconOption(name: "☃️", displayName: "Snowman", isCustom: false),
        IconOption(name: "🌨️", displayName: "Nevicata", isCustom: false),
        IconOption(name: "💨", displayName: "Vento", isCustom: false),
        IconOption(name: "🌪️", displayName: "Tornado", isCustom: false),
        IconOption(name: "🌫️", displayName: "Nebbia", isCustom: false),
        IconOption(name: "🌬️", displayName: "Brezza", isCustom: false),
        
        // ❤️ EMOZIONI E SIMBOLI
        IconOption(name: "❤️", displayName: "Cuore", isCustom: false),
        IconOption(name: "🧡", displayName: "Arancione", isCustom: false),
        IconOption(name: "💛", displayName: "Giallo", isCustom: false),
        IconOption(name: "💚", displayName: "Verde", isCustom: false),
        IconOption(name: "💙", displayName: "Blu", isCustom: false),
        IconOption(name: "💜", displayName: "Viola", isCustom: false),
        IconOption(name: "🖤", displayName: "Nero", isCustom: false),
        IconOption(name: "🤍", displayName: "Bianco", isCustom: false),
        IconOption(name: "🤎", displayName: "Marrone", isCustom: false),
        IconOption(name: "💔", displayName: "Spezzato", isCustom: false),
        IconOption(name: "💖", displayName: "Brillante", isCustom: false),
        IconOption(name: "💗", displayName: "Crescente", isCustom: false),
        IconOption(name: "💓", displayName: "Battito", isCustom: false),
        IconOption(name: "💕", displayName: "Due", isCustom: false),
        IconOption(name: "💞", displayName: "Rotante", isCustom: false),
        IconOption(name: "✅", displayName: "Fatto", isCustom: false),
        IconOption(name: "✔️", displayName: "Check", isCustom: false),
        IconOption(name: "❌", displayName: "Errore", isCustom: false),
        IconOption(name: "❎", displayName: "X", isCustom: false),
        IconOption(name: "➕", displayName: "Più", isCustom: false),
        IconOption(name: "➖", displayName: "Meno", isCustom: false),
        IconOption(name: "✖️", displayName: "Per", isCustom: false),
        IconOption(name: "➗", displayName: "Diviso", isCustom: false),
        IconOption(name: "♾️", displayName: "Infinito", isCustom: false),
        IconOption(name: "🔄", displayName: "Ricarica", isCustom: false),
        IconOption(name: "🔃", displayName: "Rotazione", isCustom: false),
        IconOption(name: "🔁", displayName: "Ripeti", isCustom: false),
        IconOption(name: "🔂", displayName: "Loop", isCustom: false),
        IconOption(name: "▶️", displayName: "Play", isCustom: false),
        IconOption(name: "⏸️", displayName: "Pausa", isCustom: false),
        IconOption(name: "⏹️", displayName: "Stop", isCustom: false),
        IconOption(name: "⏺️", displayName: "Record", isCustom: false),
        IconOption(name: "⏭️", displayName: "Avanti", isCustom: false),
        IconOption(name: "⏮️", displayName: "Indietro", isCustom: false),
        IconOption(name: "⏩", displayName: "Fast", isCustom: false),
        IconOption(name: "⏪", displayName: "Rewind", isCustom: false),
        IconOption(name: "🔀", displayName: "Shuffle", isCustom: false),
        IconOption(name: "↗️", displayName: "Crescita", isCustom: false),
        IconOption(name: "↘️", displayName: "Calo", isCustom: false),
        IconOption(name: "⬆️", displayName: "Su", isCustom: false),
        IconOption(name: "⬇️", displayName: "Giù", isCustom: false),
        IconOption(name: "⬅️", displayName: "Sinistra", isCustom: false),
        IconOption(name: "➡️", displayName: "Destra", isCustom: false),
        IconOption(name: "↩️", displayName: "Ritorna", isCustom: false),
        IconOption(name: "↪️", displayName: "Vai", isCustom: false),
        IconOption(name: "ℹ️", displayName: "Info", isCustom: false),
        IconOption(name: "❓", displayName: "Aiuto", isCustom: false),
        IconOption(name: "❔", displayName: "Domanda", isCustom: false),
        IconOption(name: "❗", displayName: "Importante", isCustom: false),
        IconOption(name: "❕", displayName: "Esclamativo", isCustom: false)
    ]
    
    init(selectedIcon: Binding<String>, availableIcons: [IconOption]? = nil) {
        self._selectedIcon = selectedIcon
        self.availableIcons = availableIcons ?? CategoryIconPicker.defaultIcons
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scegli un'icona")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(availableIcons) { icon in
                        IconSelectionButton(
                            icon: icon,
                            isSelected: selectedIcon == icon.name,
                            onSelect: {
                                selectedIcon = icon.name
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 300)
        }
    }
}

private struct IconSelectionButton: View {
    let icon: CategoryIconPicker.IconOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    }
                    
                    if icon.isCustom {
                        Image(icon.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    } else {
                        Text(icon.name)
                            .font(.system(size: 20))
                    }
                }
                
                Text(icon.displayName)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 60, height: 24)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @Previewable @State var selectedIcon = "📁"
    
    return VStack {
        CategoryIconPicker(selectedIcon: $selectedIcon)
        
        Text("Icona selezionata: \(selectedIcon)")
            .padding()
    }
    .frame(width: 500, height: 450)
    .padding()
}
