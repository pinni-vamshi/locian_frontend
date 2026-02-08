//
//  JapaneseStrings.swift
//  locian
//

import Foundation

struct JapaneseStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "カメラ",
            gallery: "ギャラリー",
            nextUp: "次へ",
            historyLog: "履歴ログ",

            moments: "瞬間",
            pastMoments: "過去の瞬間",
            noHistory: "履歴なし",
            generatingHistory: "履歴を生成中",
            generatingMoments: "生成中...",
            analyzingImage: "画像分析...",
            tapNextUpToGenerate: "次へをタップして生成",
            noUpcomingPlaces: "今後の場所なし",
            noDetails: "詳細なし",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "学習を開始",
            continueLearning: "学習を続ける",
            noPastMoments: "過去の瞬間なし",
            useCamera: "カメラを使用",
            previouslyLearning: "以前の学習",
            sunShort: "日",
            monShort: "月",
            tueShort: "火",
            wedShort: "水",
            thuShort: "木",
            friShort: "金",
            satShort: "土",
            login: "ログイン",
            register: "登録",
            settings: "設定",
            back: "戻る",
            done: "完了",
            cancel: "キャンセル",
            save: "保存",
            delete: "削除",
            add: "追加",
            remove: "削除",
            edit: "編集",
            error: "エラー",
            ok: "OK",
            welcomeLabel: "ようこそ",
            currentStreak: "現在のストリーク",
            notSet: "未設定",
            learnTab: "学習",
            addTab: "追加",
            progressTab: "進捗",
            settingsTab: "設定",
            loading: "読み込み中...",
            unknownPlace: "未知の場所",
            noLanguageAvailable: "利用可能な言語はありません",
            noInternetConnection: "インターネット接続なし",
            retry: "再試行",
            tapToGetMoments: "タップして瞬間を取得",
            startLearningThisMoment: "この瞬間から学習を開始",
            daysLabel: "日",
            noNewPlace: "新しい場所を追加",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "開始",
            typeYourMoment: "瞬間を入力...",
            imagesLabel: "画像",
            routinesLabel: "ルーチン",
            whatAreYouDoing: "今、何をしていますか？",
            chooseContext: "学習を開始するコンテキストを選択",
            typeHere: "ここに入力",
            nearbyLabel: "近く",
            noNearbyPlaces: "{noNearby}",
            addRoutine: "ルーチンを追加",
            tapToSetup: "タップして設定",
            tapToStartLearning: "タップして学習を開始")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "アプリのインターフェース",
            targetLanguages: "目標言語",
            pastLanguagesArchived: "過去の学習言語",
            theme: "テーマ",
            notifications: "通知",
            account: "アカウント",
            profile: "プロフィール",
            addLanguagePair: "言語ペアを追加",
            logout: "ログアウト",
            deleteAllData: "すべてのデータを削除",
            deleteAccount: "アカウントを完全に削除",
            selectLevel: "レベルを選択",
            proFeatures: "プロ機能",
            showSimilarWordsToggle: "類似語を表示",
            nativeLanguage: "母国 語",
            selectNativeLanguage: "母国語を選択",
            targetLanguage: "目標言語",
            selectTargetLanguage: "目標言語を選択",
            targetLanguageDescription: "学びたい言語",
            beginner: "初級",
            intermediate: "中級",
            advanced: "上級",
            currentlyLearning: "現在学習中",
            learnNewLanguage: "新しい言語を学ぶ",
            learn: "学ぶ",
            neonGreen: "ネオングリーン",
            neonFuchsia: "ネオンフクシア",
            electricIndigo: "エレクトリックインディゴ",
            graphiteBlack: "グラファイトブラック",
            student: "学生",
            softwareEngineer: "ソフトウェアエンジニア",
            teacher: "教師",
            doctor: "医師",
            artist: "アーティスト",
            businessProfessional: "ビジネスプロフェッショナル",
            salesOrMarketing: "営業またはマーケティング",
            traveler: "旅行者",
            homemaker: "主婦/主夫",
            chef: "シェフ",
            police: "警察官",
            bankEmployee: "銀行員",
            nurse: "看護師",
            designer: "デザイナー",
            engineerManager: "エンジニアリングマネージャー",
            photographer: "写真家",
            contentCreator: "コンテンツクリエイター",
            entrepreneur: "起業家",
            other: "その他",
            otherPlaces: "他の場所",
            speaks: "話す言語",
            neuralEngine: "ニューラルエンジン",
            noLanguagePairsAdded: "言語ペアが追加されていません",
            setDefault: "デフォルトに設定",
            defaultText: "デフォルト",
            user: "ユーザー",
            signOutFromAccount: "アカウントからサインアウト",
            permanentlyDeleteAccount: "アカウントを完全に削除",
            languageAddedSuccessfully: "言語が正常に追加されました",
            failedToAddLanguage: "言語の追加に失敗しました。もう一度お試しください。",
            pleaseSelectLanguage: "言語を選択してください",
            systemConfig: "システム // 設定",
            currentLevel: "現在のレベル",
            selectPhoto: "写真を選択",
            camera: "カメラ",
            photoLibrary: "フォトライブラリ",
            selectTime: "時間を選択",
            hour: "時",
            minute: "分",
            addTime: "時間を追加",
            location: "位置情報",
            diagnosticBorders: "診断境界",
            areYouSureLogout: "ログアウトしてもよろしいですか？",
            areYouSureDeleteAccount: "アカウントを完全に削除してもよろしいですか？この操作は取り消せません。",
            
            // Personalization Refresh
            refreshHeading: "更新",
            refreshSubheading: "ユーザーコンテキスト // 進化",
            refreshDescription: "あなたの瞬間は、練習に基づいて時間の経過とともによりパーソナライズされます。",
            refreshButton: "パーソナライゼーションを更新")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "ログイン",
            verify: "確認",
            selectProfession: "職業を選択",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "ユーザー名",
            phoneNumber: "電話番号",
            guestLogin: "ゲストログイン",
            selectProfessionInstruction: "開始するには職業を選択してください",
            showMore: "もっと見る",
            showLess: "少なく表示",
            forReview: "[レビュー用]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "日常生活を通じて自然に言語を学ぶ",
            awarenessHeading: "気づき",
            awarenessDescription: "周りの言葉にリアルタイムで気づく",
            breakdownHeading: "分解",
            breakdownDescription: "言葉がどのように構成されているかを理解する",
            progressHeading: "進捗",
            progressDescription: "学習の旅を追跡する",
            readyHeading: "準備完了",
            readyDescription: "今すぐ学習を開始",
            loginOrRegister: "ログインまたは登録",
            pageIndicator: "ページ",
            selectLanguageDescription: "優先言語を選択",
            whichLanguageDoYouSpeakComfortably: "どの言語を快適に話しますか?",
            chooseTheLanguageYouWantToMaster: "今日マスターしたい言語を選んでください",

            fromWhereYouStand: "自分の位置から",
            toEveryWord: "全ての",
            everyWord: "言葉へ",
            youNeed: "あなたに必要なのは",
            lessonEngine: "レッスンエンジン",
            nodesLive: "ノード稼働中",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "ホログリッド起動",
            adaCr02: "ADA_CR-02",
            your: "あなたの",
            places: "場所が、",
            lessons: "レッスンになる。",
            yourPlaces: "あなたの場所が、",
            yourLessons: " あなたのレッスンになる。",
            nearbyCafes: "近くのカフェ？",
            unlockOrderFlow: " 注文フローを解除",
            modules: "モジュール",
            activeHubs: "アクティブハブ？",
            synthesizeGym: " ジムを合成",
            vocabulary: "語彙",
            locationOpportunity: "全ての場所が学習の機会になる",
            module03: "モジュール_03",
            notJustMemorization: "単なる\n暗記ではない",
            philosophy: "哲学",
            locianTeaches: "Locianは単に言葉を教えるだけではありません。\nLocianはターゲット言語で ",
            think: "思考する",
            inTargetLanguage: "ことを教えます。",
            patternBasedLearning: "パターン学習",
            patternBasedDesc: "乾燥したルールなしで文法構造を直感的に認識します。",
            situationalIntelligence: "状況別インテリジェンス",
            situationalDesc: "環境や履歴に適応する動的なシナリオ。",
            adaptiveDrills: "適応型ドリル",
            adaptiveDesc: "レッスンエンジンが弱点を特定し、再調整します。",
            systemReady: "システム準備完了",
            quickSetup: "クイックセットアップ",
            levelB2: "レベル_B2",
            authorized: "認証済み",
            notificationsPermission: "通知",
            notificationsDesc: "近くの練習機会やストリークアラートのリアルタイム更新を取得します。",
            microphonePermission: "マイク",
            microphoneDesc: "実践的な文脈での発音採点やレッスン対話に不可欠です。",
            geolocationPermission: "位置情報",
            geolocationDesc: "没入型練習のために、カフェや図書館のような近くの「レッスンゾーン」を特定します。",
            granted: "許可されました",
            allow: "許可",
            skip: "スキップ",
            letsStart: "始めましょう",
            continueText: "続ける",
            wordTenses: "動詞の時制:",
            similarWords: "類義語:",
            wordBreakdown: "単語の構成:",
            consonant: "子音",
            vowel: "母音",
            past: "過去",
            present: "現在",
            future: "未来",
            learnWord: "学ぶ")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "進捗",
            current: "現在",
            longest: "最長",
            lastPracticed: "最後の練習",
            days: "日",
            addLanguagePairToSeeProgress: "進捗を確認するには言語ペアを追加してください",
            startPracticingMessage: "連続記録を作るには練習を始めてください",
            consistencyQuote: "一貫性は言語学習の鍵です",
            practiceDateSavingDisabled: "練習日の保存が無効になっています",
            editYourStreaks: "連続記録を編集",
            editStreaks: "連続記録を編集",
            selectDatesToAddOrRemove: "連続記録に追加または削除する日付を選択してください",
            saving: "保存中",
            statusOnFire: "ステータス: 絶好調",
            youPracticed: "練習しました ",
            yesterday: " 昨日.",
            checkInNow: "今すぐチェックイン",
            nextGoal: "次の目標",
            reward: "報酬",
            historyLogProgress: "履歴ログ",
            streakStatus: "ストリークステータス",
            streakLog: "ストリークログ",
            consistency: "一貫性",
            consistencyHigh: "アクティビティログは高いエンゲージメントを示しています。",
            consistencyMedium: "良い勢いをつけています。",
            consistencyLow: "一貫性が鍵です。頑張り続けてください。",
            reachMilestone: "%d日を目指しましょう！",
            nextMilestone: "次のマイルストーン",
            actionRequired: "アクションが必要です",
            logActivity: "アクティビティを記録",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "最長ストリック",
            streakData: "ストリックデータ",
            activeLabel: "アクティブ",
            missedLabel: "ミス",
            saveChanges: "変更を保存",
            discardChanges: "変更を破棄",
            editLabel: "編集",
            // Advanced Stats
            skillBalance: "スキルバランス",
            fluencyVelocity: "流暢さの速度",
            vocabVault: "単語バンク",
            chronotype: "クロノタイプ",
            activityDistribution: "活動分布 (24時間)",
            studiedTime: "学習時間",
            currentLabel: "現在",
            streakLabel: "ストリーク",
            longestLabel: "最長",
            earlyBird: "早起き",
            earlyBirdDesc: "朝に最も活発",
            dayWalker: "デイウォーカー",
            dayWalkerDesc: "午後に最も活発",
            nightOwl: "夜型",
            nightOwlDesc: "夜間に最も活発",
            timeMastery: "タイムマスタリー",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "読み込み中...",
            adaptiveQuiz: "アダプティブクイズ",
            adaptiveQuizDescription: "最初は誤った訳を表示し、次に正しい言葉を強調します。",
            wordCheck: "単語チェック",
            wordCheckDescription: "タイルが混ざり、次に正しい位置に収まって単語を確認します。",
            wordCheckExamplePrompt: "文字をタップして単語を正しい順序に並べ替えます。",
            quizPrompt: "正しい翻訳を選択してください。",
            answerConfirmation: "正しい単語ができました！",
            tryAgain: "おっと！再試行してください。")
    }

    var scene: SceneStrings {
        SceneStrings(
                                                                                                                                                                                                                                                                                                                                                                                            )
    }


    func getString(_ key: String) -> String {
        return key
    }
    
                                    func getString(for key: StringKey) -> String {
        switch key {
        case .notifications: return settings.notifications
        case .account: return settings.account
        case .login: return ui.login
        case .register: return ui.register
        case .settings: return ui.settings
        case .back: return ui.back
        case .done: return ui.done
        case .cancel: return ui.cancel
        case .save: return ui.save
        case .delete: return ui.delete
        case .add: return ui.add
        case .remove: return ui.remove
        case .edit: return ui.edit
        case .learnTab: return ui.learnTab
        case .addTab: return ui.addTab
        case .progressTab: return ui.progressTab
        case .settingsTab: return ui.settingsTab
        case .loading: return ui.loading
        case .user: return settings.user
        case .unknownPlace: return ui.unknownPlace
        case .noLanguageAvailable: return ui.noLanguageAvailable
        case .noInternetConnection: return ui.noInternetConnection
        case .retry: return ui.retry
        case .tapToGetMoments: return ui.tapToGetMoments
        case .startLearningThisMoment: return ui.startLearningThisMoment
        case .daysLabel: return ui.daysLabel
        case .systemLanguage: return settings.systemLanguage
        case .targetLanguages: return settings.targetLanguages
        case .pastLanguagesArchived: return settings.pastLanguagesArchived
        case .theme: return settings.theme
        case .logout: return settings.logout
        case .learnNewLanguage: return settings.learnNewLanguage
        case .profile: return settings.profile
        case .addLanguagePair: return settings.addLanguagePair
        case .deleteAllData: return settings.deleteAllData
        case .deleteAccount: return settings.deleteAccount
        case .selectLevel: return settings.selectLevel
        case .proFeatures: return settings.proFeatures
        case .showSimilarWordsToggle: return settings.showSimilarWordsToggle
        case .cameraLabel: return ui.camera
        case .galleryLabel: return ui.gallery
        case .nextUp: return ui.nextUp
        case .historyLog: return ui.historyLog

        case .moments: return ui.moments
        case .pastMoments: return ui.pastMoments
        case .welcomeLabel: return ui.welcomeLabel
        case .noUpcomingPlaces: return ui.noUpcomingPlaces
        case .noDetailsRecorded: return ui.noDetails

        case .startLearningLabel: return ui.startLearning
        case .continueLearningLabel: return ui.continueLearning
        case .noPastMomentsFor: return ui.noPastMoments
        case .useCameraToStartLearning: return ui.useCamera
        case .previouslyLearning: return ui.previouslyLearning
        case .noHistoryRecorded: return ui.noHistory
        case .tapNextUpToGenerate: return ui.tapNextUpToGenerate
        case .generatingHistory: return ui.generatingHistory
        case .generatingMoments: return ui.generatingMoments
        case .analyzingImage: return ui.analyzingImage
        case .noNewPlace: return ui.noNewPlace
        case .addNewPlaceInstruction: return ui.addNewPlaceInstruction
        case .start: return ui.start
        case .startPracticingMessage: return progress.startPracticingMessage
        case .consistencyQuote: return progress.consistencyQuote
        case .practiceDateSavingDisabled: return progress.practiceDateSavingDisabled
        case .sunShort: return ui.sunShort
        case .monShort: return ui.monShort
        case .tueShort: return ui.tueShort
        case .wedShort: return ui.wedShort
        case .thuShort: return ui.thuShort
        case .friShort: return ui.friShort
        case .satShort: return ui.satShort
        case .noLanguagePairsAdded: return settings.noLanguagePairsAdded
        case .setDefault: return settings.setDefault
        case .defaultText: return settings.defaultText
        case .signOutFromAccount: return settings.signOutFromAccount
        case .permanentlyDeleteAccount: return settings.permanentlyDeleteAccount
        case .currentLevel: return settings.currentLevel
        case .selectPhoto: return settings.selectPhoto
        case .camera: return settings.camera
        case .photoLibrary: return settings.photoLibrary
        case .selectTime: return settings.selectTime
        case .hour: return settings.hour
        case .minute: return settings.minute
        case .addTime: return settings.addTime
        case .areYouSureLogout: return settings.areYouSureLogout
        case .areYouSureDeleteAccount: return settings.areYouSureDeleteAccount
        case .nativeLanguage: return settings.nativeLanguage
        case .selectNativeLanguage: return settings.selectNativeLanguage
        case .targetLanguage: return settings.targetLanguage
        case .selectTargetLanguage: return settings.selectTargetLanguage
        case .targetLanguageDescription: return settings.targetLanguageDescription
        case .beginner: return settings.beginner
        case .intermediate: return settings.intermediate
        case .advanced: return settings.advanced
        case .currentlyLearning: return settings.currentlyLearning
        case .learn: return settings.learn
        case .neonGreen: return settings.neonGreen
        case .neonFuchsia: return settings.neonFuchsia
        case .electricIndigo: return settings.electricIndigo
        case .graphiteBlack: return settings.graphiteBlack
        case .error: return ui.error
        case .ok: return ui.ok
        case .locianHeading: return onboarding.locianHeading
        case .locianDescription: return onboarding.locianDescription
        case .awarenessHeading: return onboarding.awarenessHeading
        case .awarenessDescription: return onboarding.awarenessDescription
        case .breakdownHeading: return onboarding.breakdownHeading
        case .breakdownDescription: return onboarding.breakdownDescription
        case .progressHeading: return onboarding.progressHeading
        case .progressDescription: return onboarding.progressDescription
        case .readyHeading: return onboarding.readyHeading
        case .readyDescription: return onboarding.readyDescription
        case .loginOrRegister: return onboarding.loginOrRegister
        case .pageIndicator: return onboarding.pageIndicator
        case .selectLanguageDescription: return onboarding.selectLanguageDescription
        case .whichLanguageDoYouSpeakComfortably: return onboarding.whichLanguageDoYouSpeakComfortably
        case .chooseTheLanguageYouWantToMaster: return onboarding.chooseTheLanguageYouWantToMaster
        case .wordTenses: return onboarding.wordTenses
        case .similarWords: return onboarding.similarWords
        case .wordBreakdown: return onboarding.wordBreakdown
        case .consonant: return onboarding.consonant
        case .vowel: return onboarding.vowel
        case .adaptiveQuiz: return quiz.adaptiveQuiz
        case .adaptiveQuizDescription: return quiz.adaptiveQuizDescription
        case .wordCheck: return quiz.wordCheck
        case .wordCheckDescription: return quiz.wordCheckDescription
        case .wordCheckExamplePrompt: return quiz.wordCheckExamplePrompt
        case .quizPrompt: return quiz.quizPrompt
        case .answerConfirmation: return quiz.answerConfirmation
        case .tryAgain: return quiz.tryAgain
        case .verify: return login.verify
        case .selectProfession: return login.selectProfession
        case .selectProfessionInstruction: return login.selectProfessionInstruction
        case .showMore: return login.showMore
        case .showLess: return login.showLess
        case .forReview: return login.forReview
        case .username: return login.username
        case .phoneNumber: return login.phoneNumber
        case .guestLogin: return login.guestLogin
        case .authenticatingUser: return login.authenticatingUser
        case .bySigningInYouAgreeToOur: return login.bySigningInYouAgreeToOur
        case .termsOfService: return login.termsOfService
        case .privacyPolicy: return login.privacyPolicy
        case .selectUserProfession: return login.selectUserProfession
        case .editYourStreaks: return progress.editYourStreaks
        case .editStreaks: return progress.editStreaks
        case .selectDatesToAddOrRemove: return progress.selectDatesToAddOrRemove
        case .saving: return progress.saving
        case .student: return settings.student
        case .softwareEngineer: return settings.softwareEngineer
        case .teacher: return settings.teacher
        case .doctor: return settings.doctor
        case .artist: return settings.artist
        case .businessProfessional: return settings.businessProfessional
        case .salesOrMarketing: return settings.salesOrMarketing
        case .traveler: return settings.traveler
        case .activityDistribution: return progress.activityDistribution
        case .studiedTime: return progress.studiedTime
        case .currentLabel: return progress.currentLabel
        case .streakLabel: return progress.streakLabel
        case .longestLabel: return progress.longestLabel
        case .earlyBird: return progress.earlyBird
        case .earlyBirdDesc: return progress.earlyBirdDesc
        case .dayWalker: return progress.dayWalker
        case .dayWalkerDesc: return progress.dayWalkerDesc
        case .nightOwl: return progress.nightOwl
        case .nightOwlDesc: return progress.nightOwlDesc
        case .homemaker: return settings.homemaker
        case .chef: return settings.chef
        case .police: return settings.police
        case .bankEmployee: return settings.bankEmployee
        case .nurse: return settings.nurse
        case .designer: return settings.designer
        case .engineerManager: return settings.engineerManager
        case .photographer: return settings.photographer
        case .contentCreator: return settings.contentCreator
        case .entrepreneur: return settings.entrepreneur
        case .other: return settings.other
        case .otherPlaces: return settings.otherPlaces
        case .speaks: return settings.speaks
        case .neuralEngine: return settings.neuralEngine
        case .currentStreak: return ui.currentStreak
        case .notSet: return ui.notSet
        case .past: return onboarding.past
        case .present: return onboarding.present
        case .future: return onboarding.future
        case .learnWord: return onboarding.learnWord
        case .languageAddedSuccessfully: return settings.languageAddedSuccessfully
        case .failedToAddLanguage: return settings.failedToAddLanguage
        case .pleaseSelectLanguage: return settings.pleaseSelectLanguage
        case .systemConfig: return settings.systemConfig
        case .statusOnFire: return progress.statusOnFire
        case .youPracticed: return progress.youPracticed
        case .yesterday: return progress.yesterday
        case .checkInNow: return progress.checkInNow
        case .nextGoal: return progress.nextGoal
        case .reward: return progress.reward
        case .historyLogProgress: return progress.historyLogProgress
        case .streakStatus: return progress.streakStatus
        case .streakLog: return progress.streakLog
        case .consistency: return progress.consistency
        case .consistencyHigh: return progress.consistencyHigh
        case .consistencyMedium: return progress.consistencyMedium
        case .consistencyLow: return progress.consistencyLow
        case .progress: return progress.progress
        case .current: return progress.current
        case .longest: return progress.longest
        case .days: return progress.days
        case .reachMilestone: return progress.reachMilestone
        case .nextMilestone: return progress.nextMilestone
        case .actionRequired: return progress.actionRequired
        case .logActivity: return progress.logActivity
        case .maintainStreak: return progress.maintainStreak
        case .manualEntry: return progress.manualEntry
        case .longestStreakLabel: return progress.longestStreakLabel
        case .streakData: return progress.streakData
        case .activeLabel: return progress.activeLabel
        case .missedLabel: return progress.missedLabel
        case .saveChanges: return progress.saveChanges
        case .discardChanges: return progress.discardChanges
        case .editLabel: return progress.editLabel
        case .lastPracticed: return progress.lastPracticed
        case .addLanguagePairToSeeProgress: return progress.addLanguagePairToSeeProgress
        case .callingAI: return ui.callingAI
        case .preparingLesson: return ui.preparingLesson
        
        case .module03: return onboarding.module03
        case .notJustMemorization: return onboarding.notJustMemorization
        case .philosophy: return onboarding.philosophy
        case .locianTeaches: return onboarding.locianTeaches
        case .think: return onboarding.think
        case .inTargetLanguage: return onboarding.inTargetLanguage
        case .patternBasedLearning: return onboarding.patternBasedLearning
        case .patternBasedDesc: return onboarding.patternBasedDesc
        case .situationalIntelligence: return onboarding.situationalIntelligence
        case .situationalDesc: return onboarding.situationalDesc
        case .adaptiveDrills: return onboarding.adaptiveDrills
        case .adaptiveDesc: return onboarding.adaptiveDesc
        case .systemReady: return onboarding.systemReady
        case .quickSetup: return onboarding.quickSetup
        case .levelB2: return onboarding.levelB2
        case .authorized: return onboarding.authorized
        case .notificationsPermission: return onboarding.notificationsPermission
        case .notificationsDesc: return onboarding.notificationsDesc
        case .microphonePermission: return onboarding.microphonePermission
        case .microphoneDesc: return onboarding.microphoneDesc
        case .geolocationPermission: return onboarding.geolocationPermission
        case .geolocationDesc: return onboarding.geolocationDesc
        case .granted: return onboarding.granted
        case .allow: return onboarding.allow
        case .skip: return onboarding.skip
        case .letsStart: return onboarding.letsStart
        case .continueText: return onboarding.continueText
        case .fromWhereYouStand: return onboarding.fromWhereYouStand
        case .toEveryWord: return onboarding.toEveryWord
        case .everyWord: return onboarding.everyWord
        case .youNeed: return onboarding.youNeed
        case .lessonEngine: return onboarding.lessonEngine
        case .nodesLive: return onboarding.nodesLive
        case .locEngineVersion: return onboarding.locEngineVersion
        case .holoGridActive: return onboarding.holoGridActive
        case .adaCr02: return onboarding.adaCr02
        case .your: return onboarding.your
        case .places: return onboarding.places
        case .lessons: return onboarding.lessons
        case .yourPlaces: return onboarding.yourPlaces
        case .yourLessons: return onboarding.yourLessons
        case .nearbyCafes: return onboarding.nearbyCafes
        case .unlockOrderFlow: return onboarding.unlockOrderFlow
        case .modules: return onboarding.modules
        case .activeHubs: return onboarding.activeHubs
        case .synthesizeGym: return onboarding.synthesizeGym
        case .vocabulary: return onboarding.vocabulary
        case .locationOpportunity: return onboarding.locationOpportunity
        // Advanced Stats
        case .skillBalance: return progress.skillBalance
        case .fluencyVelocity: return progress.fluencyVelocity
        case .vocabVault: return progress.vocabVault
        case .chronotype: return progress.chronotype
        case .timeMastery: return progress.timeMastery
        case .wordsMastered: return progress.wordsMastered
        case .patternsMastered: return progress.patternsMastered
        case .avgResponseTime: return progress.avgResponseTime
        case .patternGalaxy: return progress.patternGalaxy
        case .typeYourMoment: return ui.typeYourMoment
        case .imagesLabel: return ui.imagesLabel

        // Personalization Refresh
        case .refreshHeading: return settings.refreshHeading
        case .refreshSubheading: return settings.refreshSubheading
        case .refreshDescription: return settings.refreshDescription
        case .refreshButton: return settings.refreshButton
        case .routinesLabel: return ui.routinesLabel
        case .whatAreYouDoing: return ui.whatAreYouDoing
        case .chooseContext: return ui.chooseContext
        case .typeHere: return ui.typeHere
        case .nearbyLabel: return ui.nearbyLabel
        case .noNearbyPlaces: return ui.noNearbyPlaces
        case .addRoutine: return ui.addRoutine
        case .tapToSetup: return ui.tapToSetup
        case .tapToStartLearning: return ui.tapToStartLearning
        }
    }
}
