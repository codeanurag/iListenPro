# iListenPro 🎧

<div align="center">

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**A mindful iOS app for daily reflection and AI-powered emotional support**

*Take 3 minutes daily to reflect, record, and receive empathetic AI responses*

[Features](#features) • [Screenshots](#screenshots) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture)

</div>

---

## 🌟 Features

### 🎙️ **Voice-First Reflection**
- **3-minute guided sessions** with intuitive voice recording
- **Real-time countdown timer** with pause/resume functionality
- **Speech-to-text transcription** using Apple's Speech framework
- **Hands-free experience** for natural, flowing conversations

### 🤖 **AI-Powered Empathy**
- **OpenAI GPT-3.5-turbo integration** for contextual responses
- **Empathetic listener personality** trained for emotional support
- **Text-to-speech synthesis** for audio feedback
- **Personalized encouragement** based on your reflections

### 📱 **Thoughtful User Experience**
- **Beautiful dark theme** designed for evening reflection
- **Onboarding flow** for first-time users
- **Session history** with searchable past conversations
- **Daily notifications** (9 PM reminder) for consistent habits

### 🔒 **Privacy & Security**
- **Local data storage** with encrypted session persistence
- **Secure API key management** through environment variables
- **No data tracking** - your reflections stay private
- **Granular permissions** for microphone and notifications

## 📱 App Flow

### Main Features Overview
- **🏠 Home Screen**: Simple "How was your day?" prompt with start button
- **🎙️ Recording Session**: 3-minute timer with pause/resume controls
- **🤖 AI Reflection**: Personalized empathetic response display
- **📚 Session History**: Browse and review past conversations

> 📸 *Screenshots coming soon! Feel free to contribute by adding actual app screenshots to the `docs/` folder.*

## 🚀 Installation

### Prerequisites
- **Xcode 15.0+** (iOS 15.0+ deployment target)
- **macOS 12.0+** for development
- **OpenAI API Account** ([Get one here](https://platform.openai.com/))

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/iListenPro.git
   cd iListenPro
   ```

2. **Open in Xcode**
   ```bash
   open iListenPro.xcodeproj
   ```

3. **Configure OpenAI API Key**
   - Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
   - In Xcode: Product → Scheme → Edit Scheme...
   - Go to Run → Environment Variables
   - Add: `OPENAI_API_KEY` = `your_api_key_here`

4. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

## 💡 Usage

### Getting Started
1. **Launch the app** and complete the onboarding flow
2. **Grant permissions** for microphone and notifications
3. **Start your first session** by tapping "Start Conversation"

### Daily Reflection Flow
1. **Record**: Share your thoughts for up to 3 minutes
2. **Process**: AI transcribes and generates an empathetic response
3. **Reflect**: Read and listen to your personalized feedback
4. **Review**: Access your conversation history anytime

### Tips for Best Experience
- **Find a quiet space** for clear audio recording
- **Speak naturally** - the AI is trained to understand conversational tone
- **Use daily notifications** to build a consistent reflection habit
- **Review past sessions** to track your emotional journey

## 🏗️ Architecture

### Tech Stack
- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming and data flow
- **AVFoundation** - Audio recording and playback
- **Speech Framework** - Speech-to-text transcription
- **UserNotifications** - Daily reminder system
- **OpenAI API** - AI-powered response generation

### Project Structure
```
iListenPro/
├── 📱 Views/
│   ├── ContentView.swift           # Main app interface
│   ├── OnboardingView.swift        # First-time user flow
│   ├── SessionListView.swift       # Conversation history
│   ├── SessionDetailView.swift     # Individual session view
│   ├── ReflectionOverlay.swift     # AI response display
│   └── LoadingOverlay.swift        # Processing states
├── 🧠 ViewModels/
│   └── SessionViewModel.swift      # Core business logic
├── 📦 Models/
│   ├── Session.swift              # Data models
│   ├── SessionStore.swift         # Persistence layer
│   ├── AudioRecorder.swift        # Recording functionality
│   ├── SpeechSynthesizer.swift    # Text-to-speech
│   └── OpenAIChatResponse.swift   # API response models
├── 🎨 Utilities/
│   ├── CircularCountdownView.swift # Timer UI component
│   ├── RecordingControlsView.swift # Recording interface
│   ├── PrimaryButtonStyle.swift   # Custom button styling
│   └── SessionUIState.swift       # UI state management
└── 📋 Info.plist                  # App configuration
```

### Key Design Patterns
- **MVVM Architecture** for clean separation of concerns
- **Reactive Programming** with Combine publishers
- **Dependency Injection** through environment objects
- **State Management** with enum-based UI states

## 🔧 Configuration

### Environment Variables
- `OPENAI_API_KEY` - Your OpenAI API key for AI responses

### Customization Options
- **Session Duration**: Modify `duration` in `SessionViewModel` (default: 180 seconds)
- **Notification Time**: Update `dateComponents.hour` in `scheduleReminder()` (default: 21:00)
- **AI Model**: Change `model` parameter in API request (default: gpt-3.5-turbo)

## 🛡️ Privacy & Security

### Data Protection
- **Local Storage**: All conversations stored locally using iOS secure storage
- **No Cloud Sync**: Your data never leaves your device (except for AI processing)
- **Encrypted API Keys**: Secure environment variable management
- **Session Cleanup**: Automatic audio file cleanup after processing

### Permissions
- **Microphone**: Required for voice recording functionality
- **Notifications**: Optional for daily reflection reminders
- **Speech Recognition**: Required for transcription features

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines
- Follow Swift style guidelines
- Write unit tests for new features
- Update documentation for API changes
- Test on multiple iOS versions

## 📋 Requirements

- **iOS 15.0+**
- **Xcode 15.0+**
- **Swift 5.0+**
- **OpenAI API Key**

## 🚧 Roadmap

### Planned Features
- [ ] **Mood Tracking** - Visual mood trends over time
- [ ] **Custom Prompts** - Personalized reflection questions
- [ ] **Export Options** - Share or backup your sessions
- [ ] **Widget Support** - Home screen quick access
- [ ] **Dark/Light Theme** - System appearance adaptation
- [ ] **Accessibility** - VoiceOver and Dynamic Type support

### Known Issues
- Background recording limitations on iOS
- Network connectivity requirements for AI responses

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI** for providing the GPT API
- **Apple** for the Speech and AVFoundation frameworks
- **SwiftUI Community** for inspiration and best practices

## 📞 Support

Have questions or need help?

- 🐛 **Bug Reports**: [Open an issue](https://github.com/codeanurag/iListenPro/issues)
- 💡 **Feature Requests**: [Start a discussion](https://github.com/codeanurag/iListenPro/discussions)
- 📧 **Contact**: [codeanuragpandit@gmail.com](mailto:codeanuragpandit@gmail.com)

---

<div align="center">

**Made with ❤️ for mindful reflection**

*"A few minutes of self-care can go a long way."*

</div>
