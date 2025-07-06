# iListenPro

A SwiftUI app for personal reflection and listening sessions with AI-powered responses.

## Features

- Personal reflection sessions with voice recording
- AI-powered empathetic responses using OpenAI
- Speech synthesis for audio feedback
- Session history and management
- Daily reminder notifications

## Setup

### OpenAI API Key Configuration

This app requires an OpenAI API key to function. The API key is configured securely through Xcode's environment variables.

#### For Development:

1. **Get an OpenAI API Key**:
   - Go to [OpenAI Platform](https://platform.openai.com/)
   - Create an account or sign in
   - Navigate to API Keys section
   - Create a new secret key

2. **Configure in Xcode**:
   - Open `iListenPro.xcodeproj` in Xcode
   - Select the project in the navigator
   - Go to the "iListenPro" scheme
   - Click "Edit Scheme..." 
   - Select "Run" in the left sidebar
   - Go to the "Environment Variables" section
   - Add a new environment variable:
     - **Name**: `OPENAI_API_KEY`
     - **Value**: Your OpenAI API key (starts with `sk-`)
     - **Enabled**: ✓

3. **Security Note**: 
   - The scheme file containing your API key is stored in `xcuserdata/` which is excluded from Git
   - Your API key will NOT be committed to version control
   - Each developer needs to configure their own API key

## Build and Run

1. Ensure you have Xcode 15.0 or later
2. Configure the OpenAI API key as described above
3. Build and run the project in Xcode

## Privacy and Permissions

The app requests the following permissions:
- **Microphone**: For voice recording during reflection sessions
- **Notifications**: For daily reflection reminders (set for 9 PM)

## Architecture

- **SwiftUI** for the user interface
- **Combine** for reactive programming and data flow
- **AVFoundation** for audio recording and playback
- **Speech** framework for speech recognition
- **OpenAI GPT-3.5-turbo** for generating empathetic responses

## File Structure

- `Models/`: Data models and API response structures
- `ViewModels/`: Business logic and state management
- `Views/`: SwiftUI views and UI components
- `Services/`: Audio recording, speech synthesis, and data persistence
