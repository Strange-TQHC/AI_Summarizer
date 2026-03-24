# ai_summarizer

A clean, chat-based AI application built using Flutter that allows users to summarize and interact with text or PDF documents.
This project focuses on **offline-first architecture, clean UI, and real-world app flow**, making it suitable for practical usage and internship-level development.

---

## Features

- Chat-based AI interaction (ChatGPT-like UI)
- Upload PDF and extract text locally (on-device)
- Context-aware Q&A from uploaded documents
- Text summarization using AI (API-based)
- Persistent chat history using Hive (offline storage)
- Resume previous conversations
- Start new chats anytime
- Delete chats
- Smooth UX with auto-scroll and typing indicator

---

## Tech Stack

- **Flutter** (UI Development)
- **Dart**
- **Hive** (Local Database)
- **Syncfusion PDF** (PDF text extraction)
- **OpenRouter API** (AI responses)

---

## Architecture

This app follows a **chat-first architecture**:
User Input → Chat → AI Response → Stored in Hive

- Chat is the single source of truth
- Messages are stored per chat
- Document context is injected into AI prompts

---

## Project Structure

```text
lib/
├── models/
│   ├── chat.dart
│   └── message.dart
├── screens/
│   ├── chat_list_screen.dart
│   └── chat_screen.dart
├── services/
│   ├── ai_service.dart
│   ├── hive_service.dart
│   └── pdf_service.dart
└── main.dart
```

---

## Setup Instructions

### 1. Clone the repo

```bash
   git clone https://github.com/Strange-TQHC/AI_Summarizer.git
```

### 2. Navigate to project folder

```bash
   cd AI_Summarizer
```

### 3. Install dependencies

```bash
   flutter pub get
```

### 4. Add API Key
- Inside `ai_service.dart`, add your OpenRouter API key:

```dart
const String apiKey = "YOUR_API_KEY_HERE";
```

5. Run the app

```bash
   flutter run
```

---

## Key Highlights

- Clean separation of UI, logic, and storage
- Real-world chat UX (not just buttons and screens)
- Handles async API + local storage together
- Built with scalability in mind

---

## Limitations

- Requires internet for AI responses
- PDF extraction works only for selectable text (not scanned PDFs)

---

## Future Improvements

- On-device LLM integration (TinyLlama / GGUF)
- Better summarization controls
- Multi-document context

---

## Author

**KAUSHIK KALYAN BOJJA**
*(Flutter Developer)*

---

## ⭐ If you like this project

Give it a star ⭐ on GitHub
