import glob
import re

logic_files = glob.glob('/Users/vamshikrishnapinni/Desktop/locian 2/locian/Scene/LessonEngine/**/*Logic.swift', recursive=True)

def strip_array(content, array_names):
    for name in array_names:
        # Match `private static let <name> = [ ... ]`
        # Because we can have nested arrays, we can use a simple brace/bracket matcher,
        # but regex with greedy might be dangerous. Let's do string matching for the opening bracket.
        pattern = r'(?:private\s+)?static\s+let\s+' + name + r'\s*(?:\:\s*\[[^\]]+\]\s*)?=\s*\['
        match = re.search(pattern, content)
        if match:
            start_idx = match.start()
            open_bracket_idx = content.find('[', start_idx)
            bracket_count = 1
            i = open_bracket_idx + 1
            while i < len(content) and bracket_count > 0:
                if content[i] == '[': bracket_count += 1
                elif content[i] == ']': bracket_count -= 1
                i += 1
            content = content[:start_idx] + content[i:]
    return content

def replace_method(content, method_start_str, replacement_body):
    match = re.search(method_start_str, content)
    if not match:
        return content
    start_idx = match.start()
    
    # We must find the closing brace.
    open_brace_idx = content.find('{', start_idx)
    if open_brace_idx == -1: return content
    
    brace_count = 1
    i = open_brace_idx + 1
    while i < len(content) and brace_count > 0:
        if content[i] == '{': brace_count += 1
        elif content[i] == '}': brace_count -= 1
        i += 1
        
    return content[:start_idx] + replacement_body + content[i:]

for file in logic_files:
    with open(file, 'r') as f:
        content = f.read()

    # Strip voice variation arrays
    content = strip_array(content, ['introRecipes', 'correctRecipes', 'wrongRecipes', 'fullIntroVoices', 'correctVoices', 'wrongVoices', 'introVariations', 'correctVariations', 'wrongVariations'])

    # Strip allStaticSegmentsWithPaths block entirely
    match = re.search(r'static\s+var\s+allStaticSegmentsWithPaths', content)
    if match:
        start_idx = match.start()
        # if there are preceding comments, remove them too
        comment_start = content.rfind('/// Helper', max(0, start_idx-200), start_idx)
        if comment_start != -1:
            start_idx = comment_start
            
        open_brace = content.find('{', start_idx)
        if open_brace != -1:
            brace_count = 1
            i = open_brace + 1
            while i < len(content) and brace_count > 0:
                if content[i] == '{': brace_count += 1
                elif content[i] == '}': brace_count -= 1
                i += 1
            content = content[:start_idx] + content[i:]

    # Replace playIntro exactly
    pattern_intro = """static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Using Voice Override: '\\(override)'")
            AudioManager.shared.speak(segments: [.init(text: override, language: drill.voiceLanguage ?? "en-US")])
        }
    }"""
    content = replace_method(content, r'static\s+func\s+playIntro\(drill:\s*DrillState,\s*engine:\s*LessonEngine,\s*mode:\s*DrillMode\)', pattern_intro)

    # Replace playFeedback exactly
    pattern_feedback = """private func playFeedback(isCorrect: Bool) {
        if isCorrect {
            playAudio()
        }
    }"""
    content = replace_method(content, r'private\s+func\s+playFeedback\(isCorrect:\s*Bool\)', pattern_feedback)
    
    # Some older files might use static func playFeedback(drill:, engine:, isCorrect:) 
    # Let's replace that if it exists
    pattern_feedback_static = """static func playFeedback(drill: DrillState, engine: LessonEngine, isCorrect: Bool) {
        if isCorrect {
            let text = drill.drillData.target
            let language = engine.lessonData?.target_language ?? "es-ES"
            AudioManager.shared.speak(segments: [.init(text: text, language: language)])
        }
    }"""
    content = replace_method(content, r'static\s+func\s+playFeedback\(drill:\s*DrillState,\s*engine:\s*LessonEngine,\s*isCorrect:\s*Bool\)', pattern_feedback_static)


    with open(file, 'w') as f:
        f.write(content)

print("Drill voice logic successfully cleaned.")
