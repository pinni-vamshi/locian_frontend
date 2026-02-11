//
//  CyberComponents.swift
//  locian
//
//  Created to match the "Stitch" design reference.
//  Dark, neon accents, terminal-like aesthetics.
//

import SwiftUI

struct CyberColors {
    static let neonPink = ThemeColors.secondaryAccent // Official System Pink
    static let neonCyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.0)
    static let darkSurface = Color(white: 0.1)
    static let textGray = Color(white: 0.6)
    
    // Additions for Feedback
    static let success = Color.green
    static let error = Color.red
    static let neonBlue = Color.blue.opacity(0.8)
    static let neonGreen = Color(red: 0.0, green: 1.0, blue: 0.0) // Pure Green for New Vocab
}



// MARK: - 2. The Option Button (01, 02...)
// MARK: - 2. The Option Button (01, 02...)
struct CyberOption: View {
    let text: String
    var subtitle: String? = nil 
    var phonetic: String? = nil // Added for Intro Card
    let index: Int
    let isSelected: Bool
    var isCorrect: Bool? = nil 
    var showCorrectHint: Bool = false 
    var colorOverride: Color? = nil 
    let action: () -> Void
    
    private var stateColor: Color {
        if let override = colorOverride { return override }
        guard let correct = isCorrect else {
            return isSelected ? CyberColors.neonPink : .white
        }
        return correct ? .green : .red
    }
    private var accentColor: Color {
        if isCorrect != nil { return .black }
        if colorOverride != nil { return .black } 
        return isSelected ? CyberColors.neonCyan : Color.white.opacity(0.3)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Left Accent Square
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(isCorrect != nil ? .clear : Color.white)
                        .frame(width: 10, height: 10)
                        .offset(x: 1, y: 1)
                    
                    Rectangle()
                        .fill(accentColor)
                        .frame(width: 10, height: 10)
                }
                .padding(.leading, 16)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(text)
                            .font(.system(size: (colorOverride != nil) ? 24 : (isCorrect != nil ? 20 : 16), weight: (colorOverride != nil) ? .black : (isCorrect != nil ? .bold : .medium)))
                            .foregroundColor(isCorrect != nil || colorOverride != nil ? .black : .white)
                        
                        if let ph = phonetic {
                            Text(ph)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor((isCorrect != nil || colorOverride != nil) ? .black.opacity(0.5) : .gray)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    if let sub = subtitle {
                        Text(sub)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor((isCorrect != nil || colorOverride != nil) ? .black.opacity(0.7) : .gray)
                    }
                }
                
                Spacer()
                
                // Index / Checkmark
                VStack {
                    Text(String(format: "%02d", index + 1))
                        .font(.caption2)
                        .fontDesign(.monospaced)
                        .foregroundColor(isCorrect == nil && colorOverride == nil ? (isSelected ? CyberColors.neonPink : Color.white.opacity(0.2)) : .black.opacity(0.5))
                        .padding([.top, .trailing], 8)
                    
                    Spacer()
                    
                    if isSelected || isCorrect != nil {
                        Image(systemName: (isCorrect == false) ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(isCorrect != nil ? .black : stateColor)
                            .padding([.bottom, .trailing], 8)
                    }
                }
            }
            .padding(.vertical, 12)
            .frame(minHeight: 60)
            .background(
                ChamferedShape(chamferSize: 16, cornerRadius: 0)
                    .fill((isCorrect == nil && colorOverride == nil) ? Color.black.opacity(0.4) : stateColor)
            )
            .overlay(
                ZStack {
                    ChamferedShape(chamferSize: 16, cornerRadius: 0)
                        .stroke(isCorrect == nil ? (isSelected ? CyberColors.neonPink : Color.white.opacity(0.1)) : .clear, lineWidth: 1)
                    
                    if showCorrectHint {
                        ChamferedShape(chamferSize: 16, cornerRadius: 0)
                            .stroke(Color.green, lineWidth: 3)
                    }
                }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCorrect)
            .animation(.easeInOut(duration: 0.2), value: showCorrectHint)
        }
        .disabled(isCorrect != nil)
    }
}



// MARK: - 4. Lesson Prompt Header (Stitch Redesign)
struct LessonPromptHeader: View {
    let instruction: String
    let prompt: String
    let targetLanguage: String?
    var subPrompt: String? = nil
    var meaning: String? = nil // Static meaning display
    
    // NEW: Expandable Hint Mode (for Bricks)
    var hintText: String? = nil // If provided, enables expandable hint mode
    var contextSentence: String? = nil // Pattern target sentence
    @Binding var isHintExpanded: Bool
    
    // NEW: Explicit Color Control (No more boolean toggles)
    var backgroundColor: Color = .white
    var textColor: Color = .black
    
    // NEW: Mode Indicator (e.g. "GHOST REHEARSAL")
    var modeLabel: String? = nil
    
    var onReplay: (() -> Void)? = nil
    
    // Default initializer without binding (for non-expandable usage)
    init(
        instruction: String,
        prompt: String,
        targetLanguage: String?,
        subPrompt: String? = nil,
        meaning: String? = nil,
        backgroundColor: Color = .white,
        textColor: Color = .black,
        modeLabel: String? = nil,
        onReplay: (() -> Void)? = nil
    ) {
        self.instruction = instruction
        self.prompt = prompt
        self.targetLanguage = targetLanguage
        self.subPrompt = subPrompt
        self.meaning = meaning
        self.hintText = nil
        self._isHintExpanded = .constant(false)
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.modeLabel = modeLabel
        self.onReplay = onReplay
    }
    
    // Expandable hint initializer (for Bricks)
    init(
        instruction: String,
        prompt: String,
        targetLanguage: String?,
        hintText: String,
        meaningText: String,
        contextSentence: String?,
        isHintExpanded: Binding<Bool>,
        backgroundColor: Color = .white,
        textColor: Color = .black,
        modeLabel: String? = nil
    ) {
        self.instruction = instruction
        self.prompt = prompt
        self.targetLanguage = targetLanguage
        self.subPrompt = nil
        self.meaning = meaningText
        self.hintText = hintText
        self.contextSentence = contextSentence
        self._isHintExpanded = isHintExpanded
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.modeLabel = modeLabel
        self.onReplay = nil
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // 1. Instruction Label
                HStack(alignment: .center, spacing: 8) {
                    Text(instruction.uppercased())
                        .font(.system(size: 12, weight: .black, design: .monospaced)) // Bold/Black font
                        .foregroundColor(.black)
                        .tracking(1.0)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(CyberColors.neonCyan) // Cyan Background
                    
                    if let modeLabel = modeLabel {
                        Text(modeLabel.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .tracking(1.0)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(CyberColors.neonBlue) // Distinct Blue for Mode
                    }
                }
                
                // 2. Main Prompt Text or Replay Button
                if let replay = onReplay {
                    Button(action: { replay() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 28, weight: .black))
                            Text("TAP TO REPLAY")
                                .font(.system(size: 20, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(backgroundColor)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(prompt)
                            .font(.system(size: 38, weight: .black))
                            .foregroundColor(textColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(backgroundColor)
                        
                        if let sub = subPrompt, !sub.isEmpty {
                            Text(sub)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black) // Always black text
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.white) // ALWAYS WHITE BACKGROUND for meaning
                        }
                        
                        // Expandable Hint Mode (with chevron)
                        if let hint = hintText, let meaningText = meaning, !meaningText.isEmpty {
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    isHintExpanded.toggle()
                                }
                            }) {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(CyberColors.neonPink)
                                        .rotationEffect(.degrees(isHintExpanded ? 180 : 0))
                                        .padding(.top, 2)
                                    
                                    if isHintExpanded {
                                        // Two lines: meaning (top), target (bottom)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(meaningText)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                            
                                            if let sentence = contextSentence, !sentence.isEmpty {
                                                Text(sentence)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(.black.opacity(0.7))
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                    } else {
                                        Text(hint)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.black)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(CyberColors.neonGreen)
                                .cornerRadius(0)
                            }
                            .buttonStyle(.plain)
                        }
                        // Static Meaning Text (Small Pill) - when no hint mode
                        else if let meaning = meaning, !meaning.isEmpty, hintText == nil {
                            Text(meaning)
                                .font(.system(size: 15, weight: .bold)) // Requested size 15
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white)
                                .cornerRadius(2)
                        }
                    }
                }
                
                // 3. Target Metadata
                if let target = targetLanguage, !target.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "character.bubble.fill")
                            .font(.system(size: 14))
                            .foregroundColor(CyberColors.textGray)
                        
                        Text("TARGET: \(target.uppercased())")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberColors.textGray)
                            .tracking(1)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.leading, 24) // Space for the line
            .overlay(
                // Left Side: Solid Theme Line with White Shade Offset
                ZStack(alignment: .topLeading) {
                    // The White "Shade" / Offset line (Dropdown Effect)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 4)
                        .offset(x: 1, y: 1)
                    
                    // The Main Theme Line (Static Pink)
                    Rectangle()
                        .fill(CyberColors.neonPink)
                        .frame(width: 4)
                }
                .fixedSize(horizontal: true, vertical: false)
                , alignment: .leading
            )
            
            Spacer()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 5. Cyber Proceed Button (Redesign)
struct CyberProceedButton: View {
    let action: () -> Void
    var label: String = "ANSWER_CONFIRMED"
    var title: String = "PROCEED"
    var color: Color = .blue
    var systemImage: String = "arrow.right"
    var isEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 0) {
            // Text Content (Static)
            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.black.opacity(0.5))
                
                Text(title.uppercased())
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // The actual button (The Icon part)
            LocianButton(
                action: action,
                backgroundColor: .black,
                foregroundColor: color,
                shadowColor: color,
                shadowOffset: 3.0,
                borderWidth: 0.0,
                borderColor: .clear
            ) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .black))
                    .frame(width: 25, height: 25)
            }
            .disabled(!isEnabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ChamferedShape(chamferSize: 12, cornerRadius: 0)
                .fill(Color.white)
        )
        .padding(.horizontal)
    }
}
// MARK: - 7. Grid Pattern Decoration
struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 20
        
        for x in stride(from: 0, through: rect.width, by: step) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        for y in stride(from: 0, through: rect.height, by: step) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

// MARK: - 8. Tech Frame Border
struct TechFrameBorder: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Corners
            corner(at: .topLeading)
            corner(at: .topTrailing)
            corner(at: .bottomLeading)
            corner(at: .bottomTrailing)
            
            // Sub-borders
            Rectangle()
                .stroke(isSelected ? .black.opacity(0.1) : Color.white.opacity(0.05), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private func corner(at position: Alignment) -> some View {
        let size: CGFloat = 8
        let color = isSelected ? .black : CyberColors.neonCyan
        
        ZStack {
            // Uniform L-shaped corners for all 4 positions
            Rectangle()
                .fill(color)
                .frame(width: 2, height: size)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position)
            Rectangle()
                .fill(color)
                .frame(width: size, height: 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position)
        }
    }
}

// MARK: - 9. Cyber Grid Background
struct CyberGridBackground: View {
    var body: some View {
        GridPattern()
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
            .ignoresSafeArea()
    }
}

// MARK: - 11. MCQ Components (Shared)
struct MCQSelectionGrid: View {
    let options: [String]
    let selectedOption: String?
    let correctOption: String?
    let isAnswered: Bool
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isThisCorrect: Bool? = {
                    guard isAnswered else { return nil }
                    // Show green for correct option, red for wrong selected option
                    if option == correctOption { return true }
                    if selectedOption == option { return false }
                    return nil
                }()
                
                CyberOption(
                    text: option,
                    index: index,
                    isSelected: selectedOption == option,
                    isCorrect: isThisCorrect,
                    showCorrectHint: (isAnswered && option == correctOption),
                    action: { onSelect(option) }
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 10. Typing Components (Shared)
struct TypingInputArea: View {
    @Binding var text: String
    let placeholder: String
    let isCorrect: Bool?
    let isDisabled: Bool
    
    var body: some View {
        let bgColor: Color
        if let correct = isCorrect {
            bgColor = correct ? Color.green : Color.red
        } else {
            bgColor = Color.gray.opacity(0.2)
        }
        
        return TextField(placeholder, text: $text)
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
            .padding(12)
            .frame(height: 56)
            .background(bgColor)
            .overlay(
                Rectangle()
                    .frame(width: 7)
                    .foregroundColor(CyberColors.neonCyan),
                alignment: .leading
            )
            .disabled(isDisabled)
            .padding(.leading, 5)
            .padding(.trailing, 20)
    }
}

struct TypingCorrectionView: View {
    let correctAnswer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CORRECT SOLUTION")
                .font(.caption)
                .tracking(1)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            Text(correctAnswer)
                 .font(.system(size: 20, weight: .bold, design: .monospaced))
                 .foregroundColor(.black)
                 .padding(.horizontal, 10)
                 .padding(.vertical, 5)
                 .background(CyberColors.neonGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

// MARK: - 12. Inline Components
struct InlineTypingInputArea: View {
    @Binding var text: String
    let targetWord: String
    let isCorrect: Bool?
    let isDisabled: Bool
    
    var body: some View {
        let underlineColor: Color
        if let correct = isCorrect {
            underlineColor = correct ? CyberColors.success : CyberColors.error
        } else {
            underlineColor = CyberColors.neonCyan
        }

        return ZStack(alignment: .bottom) {
            // 1. Hidden Measurement Text (Forces ZStack to targetWord's exact width)
            Text(targetWord)
                .font(.system(size: 24, weight: .bold)) // Must match TextField
                .foregroundColor(.clear)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.horizontal, 2) // Slight breathing room for the caret
            
            // 2. The actual input field
            TextField("", text: $text)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .disabled(isDisabled)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .baselineOffset(-2) // Sync baseline
            
            // 3. The Underline
            Rectangle()
                .frame(height: 3)
                .foregroundColor(underlineColor)
                .offset(y: 4)
        }
    }
}
