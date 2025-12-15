//
//  JapaneseStrings.swift
//  locian
//
//  Japanese localization strings
//

import Foundation

struct JapaneseStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "クイズ完了！",
            masteredEnvironment: "環境をマスターしました！",
            learnMoreAbout: "についてもっと学ぶ",
            backToHome: "ホームに戻る",
            next: "次へ",
            previous: "前へ",
            check: "確認",
            tryAgain: "もう一度試す",
            shuffled: "シャッフル済み",
            noQuizAvailable: "クイズがありません",
            question: "質問",
            correct: "正解",
            incorrect: "不正解",
            notAttempted: "未回答"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "私の言語",
            notifications: "通知",
            appearance: "外観",
            account: "アカウント",
            profile: "プロフィール",
            addLanguagePair: "言語ペアを追加",
            enableNotifications: "通知を有効にする",
            logout: "ログアウト",
            deleteAllData: "すべてのデータを削除",
            deleteAccount: "アカウントを削除",
            selectLevel: "レベルを選択",
            selectAppLanguage: "アプリインターフェース",
            proFeatures: "プロ機能",
            showSimilarWordsToggle: "類似語を表示",
            showWordTensesToggle: "単語の時制を表示",
            nativeLanguage: "母国語:",
            selectNativeLanguage: "あなたの母国語を選択",
            targetLanguage: "目標言語:",
            selectTargetLanguage: "学習したい言語を選択",
            nativeLanguageDescription: "あなたの母国語は、流暢に読み、書き、話すことができる言語です。これは、あなたが最も快適に感じる言語です。",
            targetLanguageDescription: "あなたの目標言語は、学習し練習したい言語です。スキルを向上させたい言語を選択してください。",
            addPair: "ペアを追加",
            adding: "追加中...",
            failedToAddLanguagePair: "言語ペアの追加に失敗しました。もう一度お試しください。",
            settingAsDefault: "デフォルトとして設定中...",
            beginner: "初級",
            intermediate: "中級",
            advanced: "上級",
            currentlyLearning: "学習中",
            otherLanguages: "その他の言語",
            learnNewLanguage: "新しい言語を学ぶ",
            learn: "学ぶ",
            tapToSelectNativeLanguage: "母国語を選択するにはタップしてください",
            neonGreen: "ネオングリーン",
            cyanMist: "シアンミスト",
            violetHaze: "バイオレットヘイズ",
            softPink: "ソフトピンク",
            pureWhite: "ピュアホワイト"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "カテゴリを探索",
            testYourself: "自分をテスト",
            slideToStartQuiz: "クイズ開始のためにスライド",
            similarWords: "類似の単語",
            wordTenses: "動詞の時制",
            wordBreakdown: "単語の分解",
            tapToSeeBreakdown: "単語をタップして分解を見る",
            tapToHideBreakdown: "単語をタップして分解を隠す",
            tapWordsToExplore: "単語をタップして翻訳を読み、探索する",
            loading: "読み込み中...",
            learnTheWord: "単語を学ぶ",
            tryFromMemory: "記憶から試す",
            adjustingTo: "調整中",
            settingPlace: "設定中",
            settingTime: "設定中",
            generatingVocabulary: "生成中",
            analyzingVocabulary: "分析中",
            analyzingCategories: "分析中",
            analyzingWords: "分析中",
            creatingQuiz: "作成中",
            organizingContent: "整理中",
            to: "へ",
            place: "場所",
            time: "時間",
            vocabulary: "語彙",
            your: "あなたの",
            interested: "興味のある",
            categories: "カテゴリ",
            words: "単語",
            quiz: "クイズ",
            content: "コンテンツ"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "こんにちは、",
            learnFromSurroundings: "周囲から学ぶ",
            learnFromSurroundingsDescription: "環境をキャプチャし、実世界のコンテキストから語彙を学ぶ",
            locianChoosing: "選択中...",
            chooseLanguages: "言語を選択",
            continueWith: "Locianが選択したものを続ける",
            slideToLearn: "学ぶためにスライド",
            recommended: "おすすめ",
            intoYourLearningFlow: "学習フローへ",
            intoYourLearningFlowDescription: "学習履歴に基づいて練習するための推奨場所",
            customSituations: "カスタム状況",
            customSituationsDescription: "独自のパーソナライズされた学習シナリオを作成して練習する",
            max: "最大",
            recentPlacesTitle: "最近の場所",
            allPlacesTitle: "すべての場所",
            recentPlacesEmpty: "語彙を生成するとここに表示されます。",
            showMore: "さらに表示",
            showLess: "折りたたむ",
            takePhoto: "写真を撮る",
            chooseFromGallery: "ギャラリーから選択",
            letLocianChoose: "Locianに選ばせる",
            lociansChoice: "Locianによる",
            cameraTileDescription: "この写真は環境を分析し、学習できる瞬間を表示します。",
            airport: "空港",
            aquarium: "水族館",
            bakery: "ベーカリー",
            beach: "ビーチ",
            bookstore: "書店",
            cafe: "カフェ",
            cinema: "映画館",
            gym: "ジム",
            hospital: "病院",
            hotel: "ホテル",
            home: "家",
            library: "図書館",
            market: "市場",
            museum: "博物館",
            office: "オフィス",
            park: "公園",
            restaurant: "レストラン",
            shoppingMall: "ショッピングモール",
            stadium: "スタジアム",
            supermarket: "スーパーマーケット",
            temple: "寺院",
            travelling: "旅行",
            university: "大学",
            addCustomPlace: "カスタム場所を追加",
            addPlace: "場所を追加",
            enterCustomPlaceName: "カスタム場所名を入力してください（最大30文字）",
            maximumCustomPlaces: "最大10個のカスタム場所",
            welcome: "ようこそ",
            user: "ユーザー",
            tapToCaptureContext: "タップしてコンテキストをキャプチャし、学習を開始します",
            customSection: "カスタム",
            examples: "例:",
            customPlacePlaceholder: "例：オフィスへの移動",
            exampleTravellingToOffice: "オフィスへの移動",
            exampleTravellingToHome: "家への移動",
            exampleExploringParis: "パリを探索",
            exampleVisitingMuseum: "博物館を訪問",
            exampleCoffeeShop: "コーヒーショップ",
            characterCount: "文字",
            situationExample1: "忙しいカフェでコーヒーを注文する",
            situationExample2: "新しい街で道を尋ねる",
            situationExample3: "市場で食料品を買い物する",
            situationExample4: "医者の予約を取る",
            situationExample5: "ホテルにチェックインする"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "ログイン",
            verify: "確認",
            selectProfession: "職業を選択",
            username: "ユーザー名",
            phoneNumber: "電話番号",
            guestLogin: "ゲストログイン",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "あなたが立つ場所から必要なすべての時制まで",
            awarenessHeading: "認識",
            awarenessDescription: "AIがあなたの周囲から学ぶ",
            inputsHeading: "入力",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "分解",
            breakdownDescription: "Locianは文を時制に分解し、単語ごとの翻訳を提供",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "準備完了",
            readyDescription: "",
            loginOrRegister: "ログイン / 登録",
            pageIndicator: " / 6",
            tapToNavigate: "左右をタップしてナビゲート",
            selectAppLanguage: "アプリ言語を選択",
            selectLanguageDescription: "この言語により、アプリのユーザーインターフェース、見出し、説明、ボタン、名前、すべてが選択した言語に変わります"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "キャンセル",
            save: "保存",
            done: "完了",
            ok: "OK",
            back: "戻る",
            next: "次へ",
            continueText: "続ける"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "カスタム",
            hint: "ヒント",
            practiceDescription: "任意の単語をタップして目標言語に翻訳します。助けが必要な場合は、ヒントボタンを使用して提案を取得してください。",
            practiceTitle: "練習",
            practiceFollowUp: "次の練習に進む",
            camera: "カメラ",
            cameraDescription: "Locianは{native}で会話を生成し、{target}への変換を練習できます。",
            useCamera: "カメラを使用",
            cameraButtonDescription: "写真から瞬間を生成",
            typeConversation: "会話を入力",
            typeConversationDescription: "Locianは{native}で会話を生成し、{target}への変換を練習できます。",
            conversationPlaceholder: "例：忙しいカフェでコーヒーを注文",
            submit: "送信",
            fullCustomText: "完全なカスタムテキスト",
            examples: "例:",
            conversationExample1: "雨の中で道を尋ねる",
            conversationExample2: "夜遅くに野菜を買う",
            conversationExample3: "混雑したオフィスで働く",
            describeConversation: "Locianに作成してほしい会話を説明してください。",
            fullTextPlaceholder: "完全なテキストまたは対話をここに入力...",
            startCustomPractice: "カスタム練習を開始"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "進捗",
            edit: "編集",
            current: "現在",
            longest: "最長",
            lastPracticed: "最後に練習した日",
            days: "日",
            addLanguagePairToSeeProgress: "言語ペアを追加して進捗を確認してください。"
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "私の言語"
        case .notifications: return "通知"
        case .aesthetics: return "美観"
        case .account: return "アカウント"
        case .appLanguage: return "アプリインターフェース"
        
        // Common
        case .login: return "ログイン /"
        case .register: return "登録"
        case .settings: return "設定"
        case .home: return "ホーム"
        case .back: return "戻る"
        case .next: return "次へ"
        case .previous: return "前へ"
        case .done: return "完了"
        case .cancel: return "キャンセル"
        case .save: return "保存"
        case .delete: return "削除"
        case .add: return "追加"
        case .remove: return "削除"
        case .edit: return "編集"
        case .continueText: return "続ける"
        
        // Quiz
        case .quizCompleted: return "クイズ完了！"
        case .sessionCompleted: return "セッション完了！"
        case .masteredEnvironment: return "環境をマスターしました！"
        case .learnMoreAbout: return "についてもっと学ぶ"
        case .backToHome: return "ホームに戻る"
        case .tryAgain: return "もう一度試す"
        case .shuffled: return "シャッフル済み"
        case .check: return "確認"
        
        // Vocabulary
        case .exploreCategories: return "カテゴリを探索"
        case .testYourself: return "自分をテスト"
        case .similarWords: return "類似語："
        case .wordTenses: return "単語の時制："
        case .tapWordsToExplore: return "単語をタップして翻訳を読み、探索する"
        case .wordBreakdown: return "単語の分解："
        
        // Scene
        case .analyzingImage: return "画像を分析中..."
        case .imageAnalysisCompleted: return "画像分析完了"
        case .imageSelected: return "画像が選択されました"
        case .placeNotSelected: return "場所が選択されていません"
        case .chooseLanguages: return "言語を選択"
        case .locianChoose: return "Locianが選択"
        
        // Settings
        case .enableNotifications: return "通知を有効にする"
        case .thisPlace: return "この場所"
        case .tapOnAnySection: return "上記のセクションをタップして設定を表示および管理"
        case .addNewLanguagePair: return "新しい言語ペアを追加"
        case .noLanguagePairsAdded: return "言語ペアがまだ追加されていません"
        case .setDefault: return "デフォルトに設定"
        case .defaultText: return "デフォルト"
        case .user: return "ユーザー"
        case .noPhone: return "電話番号なし"
        case .signOutFromAccount: return "アカウントからサインアウト"
        case .removeAllPracticeData: return "すべての練習データを削除"
        case .permanentlyDeleteAccount: return "アカウントとすべてのデータを完全に削除"
        case .currentLevel: return "現在のレベル"
        case .selectPhoto: return "写真を選択"
        case .camera: return "カメラ"
        case .photoLibrary: return "フォトライブラリ"
        case .selectTime: return "時間を選択"
        case .hour: return "時間"
        case .minute: return "分"
        case .addTime: return "時間を追加"
        case .areYouSureLogout: return "ログアウトしてもよろしいですか？"
        case .areYouSureDeleteAccount: return "アカウントを削除してもよろしいですか？この操作は元に戻せません。"
        
        // Quiz
        case .goBack: return "戻る"
        case .fillInTheBlank: return "空白を埋める："
        case .arrangeWordsInOrder: return "単語を正しい順序で並べる："
        case .tapWordsBelowToAdd: return "下の単語をタップしてここに追加"
        case .availableWords: return "利用可能な単語："
        case .correctAnswer: return "正解："
        
        // Common
        case .error: return "エラー"
        case .ok: return "OK"
        case .close: return "閉じる"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "あなたが立つ場所から必要なすべての時制まで"
        case .awarenessHeading: return "認識"
        case .awarenessDescription: return "AIがあなたの周囲から学ぶ"
        case .inputsHeading: return "入力"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "分解"
        case .breakdownDescription: return "Locianは文を時制に分解し、単語ごとの翻訳を提供"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "準備完了"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "ログイン / 登録"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "左右をタップしてナビゲート"
        case .selectAppLanguage: return "アプリ言語を選択"
        case .selectLanguageDescription: return "この言語により、アプリのユーザーインターフェース、見出し、説明、ボタン、名前、すべてが選択した言語に変わります"
        
        // Login
        case .username: return "ユーザー名"
        case .phoneNumber: return "電話番号"
        case .guestLogin: return "ゲストログイン"
        case .guestLoginDescription: return "ゲストログインは検証のためのもので、ゲストがすべてのアプリ機能にアクセスできるようにします。検証後に削除されます。"
        
        // Professions
        case .student: return "学生"
        case .softwareEngineer: return "ソフトウェアエンジニア"
        case .teacher: return "教師"
        case .doctor: return "医師"
        case .artist: return "芸術家"
        case .businessProfessional: return "ビジネスプロフェッショナル"
        case .salesOrMarketing: return "営業またはマーケティング"
        case .traveler: return "旅行者"
        case .homemaker: return "主婦"
        case .chef: return "シェフ"
        case .police: return "警察"
        case .bankEmployee: return "銀行員"
        case .nurse: return "看護師"
        case .designer: return "デザイナー"
        case .engineerManager: return "エンジニアマネージャー"
        case .photographer: return "写真家"
        case .contentCreator: return "コンテンツクリエイター"
        case .other: return "その他"
        
        // Scene Places
        case .lociansChoice: return "Locianの選択"
        case .airport: return "空港"
        case .cafe: return "カフェ"
        case .gym: return "ジム"
        case .library: return "図書館"
        case .office: return "オフィス"
        case .park: return "公園"
        case .restaurant: return "レストラン"
        case .shoppingMall: return "ショッピングモール"
        case .travelling: return "旅行"
        case .university: return "大学"
        case .addCustomPlace: return "カスタム場所を追加"
        case .enterCustomPlaceName: return "カスタム場所名を入力してください（最大30文字）"
        case .maximumCustomPlaces: return "最大10個のカスタム場所"
        case .welcome: return "ようこそ"
        case .tapToCaptureContext: return "タップしてコンテキストをキャプチャし、学習を開始します"
        case .customSection: return "カスタム"
        case .examples: return "例:"
        case .customPlacePlaceholder: return "例：オフィスへの移動"
        case .exampleTravellingToOffice: return "オフィスへの移動"
        case .exampleTravellingToHome: return "家への移動"
        case .exampleExploringParis: return "パリを探索"
        case .exampleVisitingMuseum: return "博物館を訪問"
        case .exampleCoffeeShop: return "コーヒーショップ"
        case .characterCount: return "文字"
        
        // Settings Modal Strings
        case .nativeLanguage: return "母国語:"
        case .selectNativeLanguage: return "あなたの母国語を選択"
        case .targetLanguage: return "目標言語:"
        case .selectTargetLanguage: return "学習したい言語を選択"
        case .nativeLanguageDescription: return "あなたの母国語は、流暢に読み、書き、話すことができる言語です。これは、あなたが最も快適に感じる言語です。"
        case .targetLanguageDescription: return "あなたの目標言語は、学習し練習したい言語です。スキルを向上させたい言語を選択してください。"
        case .addPair: return "ペアを追加"
        case .adding: return "追加中..."
        case .failedToAddLanguagePair: return "言語ペアの追加に失敗しました。もう一度お試しください。"
        case .settingAsDefault: return "デフォルトとして設定中..."
        case .beginner: return "初級"
        case .intermediate: return "中級"
        case .advanced: return "上級"
        case .currentlyLearning: return "学習中"
        case .otherLanguages: return "その他の言語"
        case .learnNewLanguage: return "新しい言語を学ぶ"
        case .learn: return "学ぶ"
        case .tapToSelectNativeLanguage: return "母国語を選択するにはタップしてください"
        
        // Theme color names
        case .neonGreen: return "ネオングリーン"
        case .cyanMist: return "シアンミスト"
        case .violetHaze: return "バイオレットヘイズ"
        case .softPink: return "ソフトピンク"
        case .pureWhite: return "ピュアホワイト"
        
        // Quick Look
        case .quickRecall: return "クイックリコール"
        case .startQuickPuzzle: return "クイックパズルを開始"
        case .stopPuzzle: return "パズルを停止"
        
        // Streak
        case .streak: return "ストリーク"
        case .dayStreak: return "日のストリーク"
        case .daysStreak: return "日のストリーク"
        case .editYourStreaks: return "ストリークを編集"
        case .editStreaks: return "ストリークを編集"
        case .selectDatesToAddOrRemove: return "練習日を追加または削除する日付を選択"
        case .saving: return "保存中..."
        }
    }
}

