import os
import glob

def replace_method(content, method_signature, new_body):
    start_idx = content.find(method_signature)
    if start_idx == -1:
        return content

    # Find the opening brace of this method
    open_brace_idx = content.find('{', start_idx)
    if open_brace_idx == -1:
        return content

    brace_count = 1
    i = open_brace_idx + 1
    while i < len(content) and brace_count > 0:
        if content[i] == '{':
            brace_count += 1
        elif content[i] == '}':
            brace_count -= 1
        i += 1
    
    end_idx = i
    # Replace everything from start_idx to end_idx with new body
    return content[:start_idx] + new_body + content[end_idx:]

logic_files = glob.glob('/Users/vamshikrishnapinni/Desktop/locian 2/locian/Scene/LessonEngine/**/*Logic.swift', recursive=True)

for file in logic_files:
    with open(file, 'r') as f:
        content = f.read()

    # 1. replace playIntro
    # Different files have slightly different signatures for playIntro? Let's check. They usually start with 'static func playIntro'
    # Wait, some start with static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode)
    start_idx = content.find("static func playIntro(")
    if start_idx != -1:
        sig_end = content.find("{", start_idx)
        sig = content[start_idx:content.find("(", start_idx)+1] # "static func playIntro("
        if sig in content:
            new_intro = """static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Using Voice Override: '\\(override)'")
            AudioManager.shared.speak(segments: [.init(text: override, language: drill.voiceLanguage ?? "en-US")])
            return
        }
    }"""
            content = replace_method(content, "static func playIntro(", new_intro)

    # 2. replace playFeedback
    if "private func playFeedback(" in content:
        new_feedback = """private func playFeedback(isCorrect: Bool) {
        if isCorrect {
            playAudio()
        }
    }"""
        content = replace_method(content, "private func playFeedback(isCorrect: Bool)", new_feedback)

    with open(file, 'w') as f:
        f.write(content)

print("Methods fixed.")
